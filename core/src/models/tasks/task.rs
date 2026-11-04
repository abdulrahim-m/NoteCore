use chrono::{DateTime, Datelike, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{Error, SqlitePool, prelude::FromRow, types::Json};

use crate::models::{repo::{ListRequest, Model, SearchParams}, settings::Settings};


#[derive(PartialEq, Debug, Clone, Serialize, Deserialize)]
pub enum Weekday {
    Sunday,
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday
}

impl Weekday {
    fn num_days_from_monday(&self) -> u8 {
        match self {
            Weekday::Sunday => 6,
            Weekday::Monday => 0,
            Weekday::Tuesday => 1,
            Weekday::Wednesday => 2,
            Weekday::Thursday => 3,
            Weekday::Friday => 4,
            Weekday::Saturday => 5,
        }
    }
}

#[derive(PartialEq, Debug, Clone, Serialize, Deserialize)]
pub enum Schedule {
    Daily { hour: u8 },
    EveryNDays { days: u32, hour: u8 },
    Weekly { days_of_week: Vec<Weekday>, hour: u8 }, 
    Monthly { day_of_month: u8, hour: u8 },
    Yearly { month: u8, day_of_month: u8, hour: u8 },
}

impl Schedule {
    pub fn time_until_next(&self, base: DateTime<Utc>, created_at: DateTime<Utc>) -> chrono::Duration {
        match self {
            Schedule::Daily { hour } => {
                let today = base.date_naive();
                if let Some(candidate_naive) = today.and_hms_opt(*hour as u32, 0, 0) {
                    let candidate_utc = candidate_naive.and_utc();
                    if candidate_utc >= base {
                        return candidate_utc - base;
                    }
                }
                let tomorrow = today + chrono::Duration::days(1);
                let candidate_tomorrow = tomorrow.and_hms_opt(*hour as u32, 0, 0).unwrap();
                candidate_tomorrow.and_utc() - base
            }
            Schedule::EveryNDays { days, hour } => {
                let days_i64 = *days as i64;
                if days_i64 <= 0 {
                    return chrono::Duration::zero();
                }
                let base_naive = base.naive_utc();
                let created_naive = created_at.naive_utc();
                let diff_days = (base_naive.date() - created_naive.date()).num_days();
                let remainder = diff_days.rem_euclid(days_i64);
                let days_to_add = if remainder == 0 {
                    let today_occ = base_naive.date().and_hms_opt(*hour as u32, 0, 0).unwrap();
                    if today_occ >= base_naive { 0 } else { days_i64 }
                } else {
                    days_i64 - remainder
                };
                let target_date = base_naive.date() + chrono::Duration::days(days_to_add);
                let target_naive = target_date.and_hms_opt(*hour as u32, 0, 0).unwrap();
                target_naive.and_utc() - base
            }
            Schedule::Weekly { days_of_week, hour } => {
                if days_of_week.is_empty() {
                    return chrono::Duration::MAX;
                }

                let current_wd = base.date_naive().weekday();
                let mut min_duration: Option<chrono::Duration> = None;

                for target_wd in days_of_week {
                    let days_ahead = (target_wd.num_days_from_monday() as i32 - current_wd.num_days_from_monday() as i32).rem_euclid(7);
                    let mut target_date = base.date_naive() + chrono::Duration::days(days_ahead as i64);
                    let mut candidate_naive = target_date.and_hms_opt(*hour as u32, 0, 0).unwrap();
                    let mut candidate_utc = candidate_naive.and_utc();

                    if candidate_utc < base {
                        target_date = target_date + chrono::Duration::weeks(1);
                        candidate_naive = target_date.and_hms_opt(*hour as u32, 0, 0).unwrap();
                        candidate_utc = candidate_naive.and_utc();
                    }

                    let duration = candidate_utc - base;
                    match min_duration {
                        None => min_duration = Some(duration),
                        Some(current_min) => {
                            if duration < current_min {
                                min_duration = Some(duration);
                            }
                        }
                    }
                }

                min_duration.unwrap_or_else(|| chrono::Duration::MAX)
            }
            Schedule::Monthly { day_of_month, hour } => {
                let mut year = base.date_naive().year();
                let mut month = base.date_naive().month();
                let target_day = *day_of_month as u32;
                
                loop {
                    if let Some(d) = chrono::NaiveDate::from_ymd_opt(year, month, target_day) {
                        if let Some(candidate_naive) = d.and_hms_opt(*hour as u32, 0, 0) {
                            let candidate_utc = candidate_naive.and_utc();
                            if candidate_utc >= base {
                                return candidate_utc - base;
                            }
                        }
                    }
                    month += 1;
                    if month > 12 {
                        month = 1;
                        year += 1;
                    }
                }
            }
            Schedule::Yearly { month, day_of_month, hour } => {
                let mut year = base.date_naive().year();
                let target_month = *month as u32;
                let target_day = *day_of_month as u32;
                loop {
                    if let Some(d) = chrono::NaiveDate::from_ymd_opt(year, target_month, target_day) {
                        if let Some(candidate_naive) = d.and_hms_opt(*hour as u32, 0, 0) {
                            let candidate_utc = candidate_naive.and_utc();
                            if candidate_utc >= base {
                                return candidate_utc - base;
                            }
                        }
                    }
                    year += 1;
                }
            }
        }
    }
}

#[derive(PartialEq, Debug, Clone, sqlx::Type, Serialize, Deserialize)]
#[sqlx(rename_all = "lowercase")]
pub enum Type {
    Periodic,
    OneTime,
}

#[derive(Debug, Clone, sqlx::Type, PartialEq, Eq)]
#[sqlx(rename_all = "lowercase")]
pub enum Priority {
    Lowest,
    Low,
    Medium,
    High,
    Highest,
}

impl Priority {
    pub fn as_str(&self) -> &'static str {
        match self {
            Priority::Lowest => "lowest",
            Priority::Low => "low",
            Priority::Medium => "medium",
            Priority::High => "high",
            Priority::Highest => "highest",
        }
    }

    pub fn from_str(s: &str) -> Option<Self> {
        match s {
            "lowest" => Some(Priority::Lowest),
            "low" => Some(Priority::Low),
            "medium" => Some(Priority::Medium),
            "high" => Some(Priority::High),
            "highest" => Some(Priority::Highest),
            _ => None,
        }
    }
}

impl Serialize for Priority {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_str(self.as_str())
    }
}

impl<'de> Deserialize<'de> for Priority {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        Priority::from_str(&s).ok_or_else(|| serde::de::Error::custom(format!("unknown priority: {}", s)))
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskOptions {
    pub priority: Option<Priority>,
    pub due_date: Option<String>,
    pub schedule: Option<Schedule>,
    pub check_list: Option<Vec<SubTask>>,
}

#[derive(Debug, Clone, FromRow)]
pub struct Task {
    pub id: i64,
    pub title: String,
    pub description: String,
    pub task_type: Type,
    pub done: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub options: Json<TaskOptions>,
    pub tags: Json<Vec<i64>>
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubTask {
    pub text: String,
    pub checked: bool
}

#[derive(Debug, Clone, Default)]
pub struct TaskSearchParams {
    pub text: Option<String>,
    pub tags: Option<Vec<i64>>,
    pub created_before: Option<DateTime<Utc>>,
    pub created_after: Option<DateTime<Utc>>,
    pub priority: Option<Priority>,
    pub due_date_before: Option<DateTime<Utc>>,
    pub due_date_after: Option<DateTime<Utc>>,
}

impl Task {
    pub fn new(title: &str, description: &str, task_type: Type, options: TaskOptions, tags: Vec<i64>) -> Self {
        Self {
            id: 0,
            title: title.to_string(),
            description: description.to_string(),
            task_type,
            done: false,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            options: Json(options),
            tags: Json(tags),
        }
    }

    /// Checks all completed periodic tasks and resets their status to unfinished if their reset period has passed.
    pub async fn update_periodic_status(pool: &SqlitePool) -> Result<(), Error> {
        let reset_hour: u8 = Settings::get(pool, "reset_time")
            .await
            .unwrap_or(None)
            .and_then(|v| v.parse::<u8>().ok())
            .unwrap_or(0);

        let mut tasks: Vec<Task> = sqlx::query_as(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE task_type = ? AND done = ?"
        )
        .bind(Type::Periodic)
        .bind(true)
        .fetch_all(pool)
        .await?;

        let now = Utc::now();

        if tasks.is_empty() {
            return Ok(());
        }

        for task in &mut tasks {
            let adjusted_updated = task.updated_at - chrono::Duration::hours(reset_hour as i64);
            let adjusted_now = now - chrono::Duration::hours(reset_hour as i64);

            if adjusted_now.date_naive() > adjusted_updated.date_naive() {
                task.done = false;
                if let Some(check_list) = &mut task.options.check_list {
                    for subtask in check_list {
                        subtask.checked = false;
                    }
                }
                task.update(pool).await?;
            }
        }

        Ok(())
    }

    pub async fn custom_search(
        pool: &SqlitePool,
        params: TaskSearchParams,
        list: Option<ListRequest>,
        status: Option<bool>
    ) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE 1=1"
        );

        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND (title LIKE ");
            query_builder.push_bind(pattern.clone());
            query_builder.push(" OR description LIKE ");
            query_builder.push_bind(pattern);
            query_builder.push(")");
        }

        if let Some(after) = params.created_after {
            query_builder.push(" AND created_at >= ");
            query_builder.push_bind(after);
        }

        if let Some(before) = params.created_before {
            query_builder.push(" AND created_at <= ");
            query_builder.push_bind(before);
        }

        if let Some(priority) = &params.priority {
            query_builder.push(" AND json_extract(options, '$.priority') = ");
            query_builder.push_bind(priority.as_str());
        }

        if let Some(after) = &params.due_date_after {
            query_builder.push(" AND json_extract(options, '$.due_date') >= ");
            query_builder.push_bind(after);
        }

        if let Some(before) = &params.due_date_before {
            query_builder.push(" AND json_extract(options, '$.due_date') <= ");
            query_builder.push_bind(before);
        }

        if let Some(tag_ids) = &params.tags {
            for tag_id in tag_ids {
                query_builder.push(" AND EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ");
                query_builder.push_bind(*tag_id);
                query_builder.push(")");
            }
        }

        if let Some(done_status) = status {
            query_builder.push(" AND done = ");
            query_builder.push_bind(done_status);
        }

        query_builder.push(" ORDER BY created_at DESC");

        if let Some(req) = list {
            let offset = (req.current_page - 1) * req.limit;
            query_builder.push(" LIMIT ");
            query_builder.push_bind(req.limit);
            query_builder.push(" OFFSET ");
            query_builder.push_bind(offset);
        }

        let tasks = query_builder
            .build_query_as::<Task>()
            .fetch_all(pool)
            .await?;

        Ok(tasks)
    }

    pub async fn get_typed_list(
        pool: &SqlitePool, 
        list: Option<ListRequest>, 
        periodic: bool, 
        schedule_by: DateTime<Utc>,
        status: Option<bool>
    ) -> Result<Vec<Self>, Error> {
        let task_type = if periodic { Type::Periodic } else { Type::OneTime };

        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE task_type = "
        );
        query_builder.push_bind(task_type);

        if let Some(done_status) = status {
            query_builder.push(" AND done = ");
            query_builder.push_bind(done_status);
        }

        // If not periodic, order by created_at DESC and apply pagination directly in SQL        
        if !periodic {
            query_builder.push(" ORDER BY created_at DESC");

            if let Some(l) = list {
                let offset = (l.current_page - 1) * l.limit;
                query_builder.push(" LIMIT ");
                query_builder.push_bind(l.limit);
                query_builder.push(" OFFSET ");
                query_builder.push_bind(offset);
            }

            let rows: Vec<Task> = query_builder
                .build_query_as()
                .fetch_all(pool)
                .await?;
            
            return Ok(rows);
        }

        // If periodic, fetch all matching tasks, sort by proximity to schedule_by, then paginate in memory
        let rows: Vec<Task> = query_builder
            .build_query_as()
            .fetch_all(pool)
            .await?;

        let mut rows = rows;
        rows.sort_by(|a, b| {
            let duration_a = a.options.schedule.as_ref()
                .map(|s| s.time_until_next(schedule_by, a.created_at))
                .unwrap_or_else(|| chrono::Duration::MAX);
            let duration_b = b.options.schedule.as_ref()
                .map(|s| s.time_until_next(schedule_by, b.created_at))
                .unwrap_or_else(|| chrono::Duration::MAX);
            duration_a.cmp(&duration_b)
        });

        if let Some(l) = list {
            let start = ((l.current_page - 1) * l.limit) as usize;
            if start >= rows.len() {
                return Ok(Vec::new());
            }
            let end = (start + l.limit as usize).min(rows.len());
            Ok(rows[start..end].to_vec())
        } else {
            Ok(rows)
        }
    }
}

impl Model for Task {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM tasks")
            .fetch_one(pool)
            .await?;
        Ok(count.0)
    }

    async fn get_all(pool: &SqlitePool, list: Option<ListRequest>) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks ORDER BY created_at DESC"
        );

        if let Some(l) = list {
            let offset = (l.current_page - 1) * l.limit;
            query_builder.push(" LIMIT ");
            query_builder.push_bind(l.limit);
            query_builder.push(" OFFSET ");
            query_builder.push_bind(offset);
        }

        let rows: Vec<Task> = query_builder
            .build_query_as()
            .fetch_all(pool)
            .await?;
        
        Ok(rows)
    }

    async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error> {
        let task = sqlx::query_as(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE id = ?"
        )
        .bind(id)
        .fetch_one(pool)
        .await?;
        
        Ok(task)
    }

    async fn search(pool: &SqlitePool, params: SearchParams, list: Option<ListRequest>) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE 1=1"
        );

        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND (title LIKE ");
            query_builder.push_bind(pattern.clone());
            query_builder.push(" OR description LIKE ");
            query_builder.push_bind(pattern);
            query_builder.push(")");
        }

        if let Some(after) = params.created_after {
            query_builder.push(" AND created_at >= ");
            query_builder.push_bind(after);
        }

        if let Some(before) = params.created_before {
            query_builder.push(" AND created_at <= ");
            query_builder.push_bind(before);
        }

        if let Some(tag_ids) = &params.tags {
            for tag_id in tag_ids {
                query_builder.push(" AND EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ");
                query_builder.push_bind(*tag_id);
                query_builder.push(")");
            }
        }

        query_builder.push(" ORDER BY created_at DESC");

        if let Some(req) = list {
            let offset = (req.current_page - 1) * req.limit;
            query_builder.push(" LIMIT ");
            query_builder.push_bind(req.limit);
            query_builder.push(" OFFSET ");
            query_builder.push_bind(offset);
        }

        let rows = query_builder
            .build_query_as::<Task>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }

    async fn create(&mut self, pool: &SqlitePool) -> Result<(), Error> {
        self.created_at = Utc::now();
        self.updated_at = Utc::now();

        let query = "
            INSERT INTO tasks (title, description, task_type, done, created_at, updated_at, options, tags) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ";

        let result = sqlx::query(query)
            .bind(&self.title)
            .bind(&self.description)
            .bind(&self.task_type)
            .bind(self.done)
            .bind(self.created_at)
            .bind(self.updated_at)
            .bind(&self.options)
            .bind(&self.tags)
            .execute(pool)
            .await?;

        self.id = result.last_insert_rowid();
        Ok(())
    }

    async fn update(&mut self, pool: &SqlitePool) -> Result<(), Error> {
        self.updated_at = Utc::now();

        let query = "
            UPDATE tasks 
            SET title = ?, description = ?, task_type = ?, done = ?, updated_at = ?, options = ?, tags = ? 
            WHERE id = ?
        ";

        sqlx::query(query)
            .bind(&self.title)
            .bind(&self.description)
            .bind(&self.task_type)
            .bind(self.done)
            .bind(self.updated_at)
            .bind(&self.options)
            .bind(&self.tags)
            .bind(self.id)
            .execute(pool)
            .await?;

        Ok(())
    }

    async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error> {
        sqlx::query("DELETE FROM tasks WHERE id = ?")
            .bind(id)
            .execute(pool)
            .await?;

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::{TimeZone, Duration};

    async fn setup_test_pool() -> SqlitePool {
        let pool = SqlitePool::connect("sqlite::memory:").await.unwrap();
        
        sqlx::query(
            "CREATE TABLE IF NOT EXISTS app_settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );"
        )
        .execute(&pool)
        .await
        .unwrap();

        sqlx::query(
            "CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                task_type TEXT NOT NULL,
                done BOOLEAN NOT NULL,
                created_at DATETIME NOT NULL,
                updated_at DATETIME NOT NULL,
                options TEXT NOT NULL,
                tags TEXT NOT NULL
            );"
        )
        .execute(&pool)
        .await
        .unwrap();

        pool
    }

    #[tokio::test]
    async fn test_schedule_time_until_next() {
        let base = Utc.with_ymd_and_hms(2026, 6, 1, 10, 0, 0).unwrap();
        let created = base;

        let daily = Schedule::Daily { hour: 14 };
        let duration = daily.time_until_next(base, created);
        assert_eq!(duration, Duration::hours(4));

        let daily_tomorrow = Schedule::Daily { hour: 8 };
        let duration_t = daily_tomorrow.time_until_next(base, created);
        assert_eq!(duration_t, Duration::hours(22));

        let every_n = Schedule::EveryNDays { days: 2, hour: 10 };
        let duration_n = every_n.time_until_next(base, created);
        assert_eq!(duration_n, Duration::zero());

        let weekly = Schedule::Weekly { days_of_week: vec![Weekday::Tuesday], hour: 12 };
        let duration_w = weekly.time_until_next(base, created);
        assert_eq!(duration_w, Duration::hours(26));

        let monthly = Schedule::Monthly { day_of_month: 15, hour: 10 };
        let duration_m = monthly.time_until_next(base, created);
        assert_eq!(duration_m, Duration::days(14));

        let yearly = Schedule::Yearly { month: 6, day_of_month: 1, hour: 12 };
        let duration_y = yearly.time_until_next(base, created);
        assert_eq!(duration_y, Duration::hours(2));
    }

    #[tokio::test]
    async fn test_task_new_and_model_crud() {
        let pool = setup_test_pool().await;

        let options = TaskOptions {
            priority: Some(Priority::High),
            due_date: Some("2026-06-10T12:00:00Z".to_string()),
            schedule: None,
            check_list: Some(vec![SubTask { text: "Sub 1".to_string(), checked: false }]),
        };

        let mut task = Task::new("Test Title", "Test Desc", Type::OneTime, options, vec![1, 2]);
        assert_eq!(task.id, 0);
        assert!(!task.done);

        task.create(&pool).await.unwrap();
        assert!(task.id > 0);

        let count = Task::get_count(&pool).await.unwrap();
        assert_eq!(count, 1);

        let fetched = Task::get_by_id(&pool, task.id).await.unwrap();
        assert_eq!(fetched.title, "Test Title");
        assert_eq!(fetched.description, "Test Desc");
        assert_eq!(fetched.task_type, Type::OneTime);

        let mut fetched_task = fetched;
        fetched_task.title = "Updated Title".to_string();
        fetched_task.done = true;
        fetched_task.update(&pool).await.unwrap();

        let updated_check = Task::get_by_id(&pool, task.id).await.unwrap();
        assert_eq!(updated_check.title, "Updated Title");
        assert!(updated_check.done);

        let all_tasks = Task::get_all(&pool, None).await.unwrap();
        assert_eq!(all_tasks.len(), 1);

        let list_req = ListRequest { current_page: 1, pages_count: 0, limit: 10 };
        let paged_tasks = Task::get_all(&pool, Some(list_req)).await.unwrap();
        assert_eq!(paged_tasks.len(), 1);

        let search_params = SearchParams {
            text: Some("Updated".to_string()),
            tags: Some(vec![1]),
            created_after: None,
            created_before: None,
        };
        let search_results = Task::search(&pool, search_params, None).await.unwrap();
        assert_eq!(search_results.len(), 1);

        Task::delete(&pool, task.id).await.unwrap();
        let count_after = Task::get_count(&pool).await.unwrap();
        assert_eq!(count_after, 0);
    }

    #[tokio::test]
    async fn test_custom_search_variations() {
        let pool = setup_test_pool().await;

        let options1 = TaskOptions {
            priority: Some(Priority::Highest),
            due_date: Some("2026-06-05".to_string()),
            schedule: None,
            check_list: None,
        };
        let mut t1 = Task::new("Alpha Task", "Description one", Type::OneTime, options1, vec![10]);
        t1.done = true;
        t1.create(&pool).await.unwrap();

        let options2 = TaskOptions {
            priority: Some(Priority::Low),
            due_date: Some("2026-06-20".to_string()),
            schedule: None,
            check_list: None,
        };
        let mut t2 = Task::new("Beta Task", "Description two", Type::OneTime, options2, vec![20]);
        t2.done = false;
        t2.create(&pool).await.unwrap();

        let params_text = TaskSearchParams {
            text: Some("Alpha".to_string()),
            ..Default::default()
        };
        let res_text = Task::custom_search(&pool, params_text, None, None).await.unwrap();
        assert_eq!(res_text.len(), 1);
        assert_eq!(res_text[0].title, "Alpha Task");

        let params_prio = TaskSearchParams {
            priority: Some(Priority::Low),
            ..Default::default()
        };
        let res_prio = Task::custom_search(&pool, params_prio, None, None).await.unwrap();
        assert_eq!(res_prio.len(), 1);
        assert_eq!(res_prio[0].title, "Beta Task");

        let params_due = TaskSearchParams {
            due_date_after: Some(Utc.with_ymd_and_hms(2026, 6, 1, 0, 0, 0).unwrap()),
            due_date_before: Some(Utc.with_ymd_and_hms(2026, 6, 10, 0, 0, 0).unwrap()),
            ..Default::default()
        };
        let res_due = Task::custom_search(&pool, params_due, None, None).await.unwrap();
        assert_eq!(res_due.len(), 1);
        assert_eq!(res_due[0].title, "Alpha Task");

        let params_tags = TaskSearchParams {
            tags: Some(vec![20]),
            ..Default::default()
        };
        let res_tags = Task::custom_search(&pool, params_tags, None, None).await.unwrap();
        assert_eq!(res_tags.len(), 1);
        assert_eq!(res_tags[0].title, "Beta Task");

        let res_status = Task::custom_search(&pool, Default::default(), None, Some(true)).await.unwrap();
        assert_eq!(res_status.len(), 1);
        assert_eq!(res_status[0].title, "Alpha Task");

        let params_mixed = TaskSearchParams {
            text: Some("Task".to_string()),
            priority: Some(Priority::Highest),
            ..Default::default()
        };
        let list_req = ListRequest { current_page: 1, pages_count: 0, limit: 1 };
        let res_mixed = Task::custom_search(&pool, params_mixed, Some(list_req), Some(true)).await.unwrap();
        assert_eq!(res_mixed.len(), 1);
        assert_eq!(res_mixed[0].title, "Alpha Task");
    }

    #[tokio::test]
    async fn test_get_typed_list() {
        let pool = setup_test_pool().await;

        let options_periodic = TaskOptions {
            priority: None,
            due_date: None,
            schedule: Some(Schedule::Daily { hour: 8 }),
            check_list: None,
        };
        let mut t_periodic = Task::new("Periodic Task", "Desc", Type::Periodic, options_periodic, vec![]);
        t_periodic.create(&pool).await.unwrap();

        let options_onetime = TaskOptions {
            priority: None,
            due_date: None,
            schedule: None,
            check_list: None,
        };
        let mut t_onetime = Task::new("OneTime Task", "Desc", Type::OneTime, options_onetime, vec![]);
        t_onetime.create(&pool).await.unwrap();

        let base_time = Utc.with_ymd_and_hms(2026, 6, 1, 10, 0, 0).unwrap();

        let periodic_list = Task::get_typed_list(&pool, None, true, base_time, None).await.unwrap();
        assert_eq!(periodic_list.len(), 1);
        assert_eq!(periodic_list[0].title, "Periodic Task");

        let onetime_list = Task::get_typed_list(&pool, Some(ListRequest { current_page: 1, pages_count: 0, limit: 5 }), false, base_time, Some(false)).await.unwrap();
        assert_eq!(onetime_list.len(), 1);
        assert_eq!(onetime_list[0].title, "OneTime Task");
    }

    #[tokio::test]
    async fn test_update_periodic_status() {
        let pool = setup_test_pool().await;

        Settings::set(&pool, "reset_time", "2").await.unwrap();

        let options = TaskOptions {
            priority: None,
            due_date: None,
            schedule: Some(Schedule::Daily { hour: 5 }),
            check_list: Some(vec![SubTask { text: "Sub".to_string(), checked: true }]),
        };

        let mut task = Task::new("Old Periodic", "Desc", Type::Periodic, options, vec![]);
        task.done = true;
        task.create(&pool).await.unwrap();

        let past_time = Utc::now() - Duration::days(2);
        sqlx::query("UPDATE tasks SET updated_at = ? WHERE id = ?")
            .bind(past_time)
            .bind(task.id)
            .execute(&pool)
            .await
            .unwrap();

        Task::update_periodic_status(&pool).await.unwrap();

        let refreshed = Task::get_by_id(&pool, task.id).await.unwrap();
        assert!(!refreshed.done);
        assert!(!refreshed.options.check_list.clone().unwrap()[0].checked);
    }
}
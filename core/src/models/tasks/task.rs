use chrono::{DateTime, Datelike, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{Error, SqlitePool, prelude::FromRow, types::Json};

use crate::models::{repo::{ListRequest, Model, SearchParams}};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Schedule {
    Daily { hour: u8 },
    EveryNDays { days: u32, hour: u8 },
    Weekly { day_of_week: u8, hour: u8 },
    Monthly { day_of_month: u8, hour: u8 },
    Yearly { month: u8, day_of_month: u8, hour: u8 },
}

impl Schedule {
    /// Calculates the time duration until the next scheduled occurrence relative to `base`.
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
            Schedule::Weekly { day_of_week, hour } => {
                let current_dow = base.date_naive().weekday().number_from_monday() as u8 - 1;
                let target_dow = *day_of_week;
                let days_ahead = (target_dow as i32 - current_dow as i32).rem_euclid(7);
                let mut target_date = base.date_naive() + chrono::Duration::days(days_ahead as i64);
                let target_naive = target_date.and_hms_opt(*hour as u32, 0, 0).unwrap();
                let target_utc = target_naive.and_utc();
                if target_utc >= base {
                    target_utc - base
                } else {
                    target_date = target_date + chrono::Duration::weeks(1);
                    let target_naive2 = target_date.and_hms_opt(*hour as u32, 0, 0).unwrap();
                    target_naive2.and_utc() - base
                }
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

#[derive(Debug, Clone, sqlx::Type)]
#[sqlx(rename_all = "lowercase")]
pub enum Type {
    Periodic,
    OneTime,
}

#[derive(Debug, Clone, sqlx::Type, Serialize, Deserialize)]
#[sqlx(rename_all = "lowercase")]
pub enum Priority {
    Lowest,
    Low,
    Medium,
    High,
    Highest
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TaskOptions {
    pub priority: Option<Priority>,
    pub due_date: Option<String>,
    pub schedule: Option<Schedule>,
    pub check_list: Option<Vec<String>>,
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

    pub async fn get_typed_list(
        pool: &SqlitePool, 
        list: Option<ListRequest>, 
        periodic: bool, 
        schedule_by: DateTime<Utc>
    ) -> Result<Vec<Self>, Error> {
        let task_type = if periodic { Type::Periodic } else { Type::OneTime };

        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE task_type = "
        );
        query_builder.push_bind(task_type);

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
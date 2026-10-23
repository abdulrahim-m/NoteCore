use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{Error, SqlitePool, prelude::FromRow, types::Json};

use crate::models::repo::{List, Model, SearchParams};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Schedule {
    Daily { hour: u8 },
    EveryNDays { days: u32, hour: u8 },
    Weekly { day_of_week: u8, hour: u8 },
    Monthly { day_of_month: u8, hour: u8 },
    Yearly { month: u8, day_of_month: u8, hour: u8 },
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

impl Model for Task {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM tasks")
            .fetch_one(pool)
            .await?;
        Ok(count.0)
    }

    async fn get_all(pool: &SqlitePool, list: List) -> Result<Vec<Self>, Error> {
        let query = "
            SELECT id, title, description, task_type, done, created_at, updated_at, options, tags 
            FROM tasks 
            ORDER BY created_at DESC
            LIMIT ? OFFSET ?";

        let offset = (list.current_page - 1) * list.limit;
        
        let rows: Vec<Task> = sqlx::query_as(query)
            .bind(list.limit)
            .bind(offset)
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

    async fn search(pool: &SqlitePool, params: SearchParams) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, title, description, task_type, done, created_at, updated_at, options, tags FROM tasks WHERE 1=1"
        );

        // Filter by text
        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND (title LIKE ");
            query_builder.push_bind(pattern.clone());
            query_builder.push(" OR description LIKE ");
            query_builder.push_bind(pattern);
            query_builder.push(")");
        }

        // Filter by creation date range
        if let Some(after) = params.created_after {
            query_builder.push(" AND created_at >= ");
            query_builder.push_bind(after);
        }

        if let Some(before) = params.created_before {
            query_builder.push(" AND created_at <= ");
            query_builder.push_bind(before);
        }

        // Filter by tags
        if let Some(tag_ids) = &params.tags {
            for tag_id in tag_ids {
                query_builder.push(" AND EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ");
                query_builder.push_bind(*tag_id);
                query_builder.push(")");
            }
        }

        query_builder.push(" ORDER BY created_at DESC");

        let rows = query_builder
            .build_query_as::<Task>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }

    async fn create(&mut self, pool: &SqlitePool) -> Result<i64, Error> {
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

        Ok(result.last_insert_rowid())
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
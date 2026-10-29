use chrono::{DateTime, Utc};
use sqlx::{Error, SqlitePool, prelude::FromRow};

use crate::models::repo::{ListRequest, Model, SearchParams};

#[derive(Debug, Clone, FromRow)]
pub struct Tag {
    pub id: i64,
    pub name: String,
    pub created_at: DateTime<Utc>,
}

impl Tag {
    pub async fn get_with_ids(pool: &SqlitePool, ids: Vec<i64>) -> Result<Vec<Self>, Error> {
        if ids.is_empty() {
            return Ok(Vec::new());
        }

        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, name, created_at FROM tags WHERE id IN ("
        );

        let mut separated = query_builder.separated(", ");
        for id in &ids {
            separated.push_bind(id);
        }
        separated.push_unseparated(")");

        let rows = query_builder
            .build_query_as::<Tag>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }
}

impl Model for Tag {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM tags")
            .fetch_one(pool)
            .await?;
        Ok(count.0)
    }

    async fn get_all(pool: &SqlitePool, list: Option<ListRequest>) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, name, created_at FROM tags ORDER BY created_at DESC"
        );

        if let Some(l) = list {
            let offset = (l.current_page - 1) * l.limit;
            query_builder.push(" LIMIT ");
            query_builder.push_bind(l.limit);
            query_builder.push(" OFFSET ");
            query_builder.push_bind(offset);
        }

        let rows: Vec<Tag> = query_builder
            .build_query_as()
            .fetch_all(pool)
            .await?;
        
        Ok(rows)
    }

    async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error> {
        let tag = sqlx::query_as("SELECT id, name, created_at FROM tags WHERE id = ?")
            .bind(id)
            .fetch_one(pool)
            .await?;
        Ok(tag)
    }

    async fn search(pool: &SqlitePool, params: SearchParams, list: Option<ListRequest>) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, name, created_at FROM tags WHERE 1=1"
        );

        // Filter by tag name text search
        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND name LIKE ");
            query_builder.push_bind(pattern);
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

        query_builder.push(" ORDER BY created_at DESC");

        if let Some(req) = list {
            let offset = (req.current_page - 1) * req.limit;
            query_builder.push(" LIMIT ");
            query_builder.push_bind(req.limit);
            query_builder.push(" OFFSET ");
            query_builder.push_bind(offset);
        }

        let rows = query_builder
            .build_query_as::<Tag>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }

    async fn create(&mut self, pool: &SqlitePool) -> Result<(), Error> {
        self.created_at = Utc::now();

        let query = "
            INSERT INTO tags (name, created_at) 
            VALUES (?, ?)
        ";

        let result = sqlx::query(query)
            .bind(&self.name)
            .bind(self.created_at)
            .execute(pool)
            .await?;

        self.id = result.last_insert_rowid();
        Ok(())
    }

    async fn update(&mut self, pool: &SqlitePool) -> Result<(), Error> {
        let query = "
            UPDATE tags 
            SET name = ? 
            WHERE id = ?
        ";

        sqlx::query(query)
            .bind(&self.name)
            .bind(self.id)
            .execute(pool)
            .await?;

        Ok(())
    }

    async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error> {
        sqlx::query("DELETE FROM tags WHERE id = ?")
            .bind(id)
            .execute(pool)
            .await?;

        Ok(())
    }
}
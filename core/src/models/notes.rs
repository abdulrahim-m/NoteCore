use chrono::{DateTime, Utc};
use sqlx::{Error, SqlitePool, prelude::FromRow, types::Json};

use crate::models::repo::{List, Model, SearchParams};

#[derive(Debug, Clone, FromRow)]
pub struct NoteGroup {
    pub id: i64,
    pub name: String,
    pub placing: i64,
}

impl Model for NoteGroup {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM note_groups")
            .fetch_one(pool)
            .await?;
        Ok(count.0)
    }

    async fn get_all(pool: &SqlitePool, list: List) -> Result<Vec<Self>, Error> {
        let query = "
            SELECT id, name, placing FROM note_groups 
            ORDER BY placing ASC
            LIMIT ? OFFSET ?";

        let offset = (list.current_page - 1) * list.limit;
        
        let rows: Vec<NoteGroup> = sqlx::query_as(query)
            .bind(list.limit)
            .bind(offset)
            .fetch_all(pool)
            .await?;
        
        Ok(rows)
    }

    async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error> {
        let group = sqlx::query_as("SELECT id, name, placing FROM note_groups WHERE id = ?")
            .bind(id)
            .fetch_one(pool)
            .await?;
        Ok(group)
    }

    async fn search(pool: &SqlitePool, params: SearchParams) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, name, placing FROM note_groups WHERE 1=1"
        );

        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND name LIKE ");
            query_builder.push_bind(pattern);
        }

        query_builder.push(" ORDER BY placing ASC");

        let rows = query_builder
            .build_query_as::<NoteGroup>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }

    async fn create(&mut self, pool: &SqlitePool) -> Result<i64, Error> {
        let query = "
            INSERT INTO note_groups (name, placing) 
            VALUES (?, ?)
        ";

        let result = sqlx::query(query)
            .bind(&self.name)
            .bind(self.placing)
            .execute(pool)
            .await?;

        Ok(result.last_insert_rowid())
    }

    async fn update(&mut self, pool: &SqlitePool) -> Result<(), Error> {
        let query = "
            UPDATE note_groups 
            SET name = ?, placing = ? 
            WHERE id = ?
        ";

        sqlx::query(query)
            .bind(&self.name)
            .bind(self.placing)
            .bind(self.id)
            .execute(pool)
            .await?;

        Ok(())
    }

    async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error> {
        sqlx::query("DELETE FROM note_groups WHERE id = ?")
            .bind(id)
            .execute(pool)
            .await?;

        Ok(())
    }
}

#[derive(Debug, Clone, FromRow)]
pub struct Note {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub content: String,
    pub tags: Json<Vec<i64>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl Model for Note {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM notes")
            .fetch_one(pool)
            .await?;
        Ok(count.0)
    }

    async fn get_all(pool: &SqlitePool, list: List) -> Result<Vec<Self>, Error> {
        let query = "
            SELECT id, group_id, title, content, tags, created_at, updated_at FROM notes 
            ORDER BY created_at DESC
            LIMIT ? OFFSET ?";

        let offset = (list.current_page - 1) * list.limit;
        
        let rows: Vec<Note> = sqlx::query_as(query)
            .bind(list.limit)
            .bind(offset)
            .fetch_all(pool)
            .await?;
        
        Ok(rows)
    }

    async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error> {
        let note = sqlx::query_as(
            "SELECT id, group_id, title, content, tags, created_at, updated_at FROM notes WHERE id = ?"
        )
        .bind(id)
        .fetch_one(pool)
        .await?;
        Ok(note)
    }

    async fn search(pool: &SqlitePool, params: SearchParams) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, group_id, title, content, tags, created_at, updated_at FROM notes WHERE 1=1"
        );

        // Filter by text search across title or content
        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND (title LIKE ");
            query_builder.push_bind(pattern.clone());
            query_builder.push(" OR content LIKE ");
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

        // Filter by tag IDs using SQLite's JSON extension
        if let Some(tag_ids) = &params.tags {
            for tag_id in tag_ids {
                query_builder.push(" AND EXISTS (SELECT 1 FROM json_each(tags) WHERE value = ");
                query_builder.push_bind(*tag_id);
                query_builder.push(")");
            }
        }

        query_builder.push(" ORDER BY created_at DESC");

        let rows = query_builder
            .build_query_as::<Note>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }

    async fn create(&mut self, pool: &SqlitePool) -> Result<i64, Error> {
        self.created_at = Utc::now();
        self.updated_at = Utc::now();

        let query = "
            INSERT INTO notes (group_id, title, content, tags, created_at, updated_at) 
            VALUES (?, ?, ?, ?, ?, ?)
        ";

        let result = sqlx::query(query)
            .bind(self.group_id)
            .bind(&self.title)
            .bind(&self.content)
            .bind(&self.tags)
            .bind(self.created_at)
            .bind(self.updated_at)
            .execute(pool)
            .await?;

        Ok(result.last_insert_rowid())
    }

    async fn update(&mut self, pool: &SqlitePool) -> Result<(), Error> {
        self.updated_at = Utc::now();

        let query = "
            UPDATE notes 
            SET group_id = ?, title = ?, content = ?, tags = ?, updated_at = ? 
            WHERE id = ?
        ";

        sqlx::query(query)
            .bind(self.group_id)
            .bind(&self.title)
            .bind(&self.content)
            .bind(&self.tags)
            .bind(self.updated_at)
            .bind(self.id)
            .execute(pool)
            .await?;

        Ok(())
    }

    async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error> {
        sqlx::query("DELETE FROM notes WHERE id = ?")
            .bind(id)
            .execute(pool)
            .await?;

        Ok(())
    }
}
use chrono::{DateTime, Utc};
use sqlx::{Error, SqlitePool, prelude::FromRow, types::Json};

use crate::models::repo::{List, Model, SearchParams};

#[derive(Debug, Clone, FromRow)]
pub struct ShortNoteSection {
    pub id: i64,
    pub name: String,
    pub tags: Json<Vec<i64>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl Model for ShortNoteSection {
    async fn get_count(pool: &SqlitePool) -> Result<i64, Error> {
        let count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM short_note_sections")
            .fetch_one(pool)
            .await?;
        Ok(count.0)
    }

    async fn get_all(pool: &SqlitePool, list: List) -> Result<Vec<Self>, Error> {
        let query = "
            SELECT id, name, tags, created_at, updated_at FROM short_note_sections 
            ORDER BY created_at DESC
            LIMIT ? OFFSET ?";

        let offset = (list.current_page - 1) * list.limit;
        
        let rows: Vec<ShortNoteSection> = sqlx::query_as(query)
            .bind(list.limit)
            .bind(offset)
            .fetch_all(pool)
            .await?;
        
        Ok(rows)
    }

    async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error> {
        let section = sqlx::query_as(
            "SELECT id, name, tags, created_at, updated_at FROM short_note_sections WHERE id = ?"
        )
        .bind(id)
        .fetch_one(pool)
        .await?;
        Ok(section)
    }

    async fn search(pool: &SqlitePool, params: SearchParams) -> Result<Vec<Self>, Error> {
        let mut query_builder = sqlx::QueryBuilder::new(
            "SELECT id, name, tags, created_at, updated_at FROM short_note_sections WHERE 1=1"
        );

        if let Some(text) = &params.text {
            let pattern = format!("%{}%", text);
            query_builder.push(" AND name LIKE ");
            query_builder.push_bind(pattern);
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

        let rows = query_builder
            .build_query_as::<ShortNoteSection>()
            .fetch_all(pool)
            .await?;

        Ok(rows)
    }

    async fn create(&mut self, pool: &SqlitePool) -> Result<i64, Error> {
        self.created_at = Utc::now();
        self.updated_at = Utc::now();

        let query = "
            INSERT INTO short_note_sections (name, tags, created_at, updated_at) 
            VALUES (?, ?, ?, ?)
        ";

        let result = sqlx::query(query)
            .bind(&self.name)
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
            UPDATE short_note_sections 
            SET name = ?, tags = ?, updated_at = ? 
            WHERE id = ?
        ";

        sqlx::query(query)
            .bind(&self.name)
            .bind(&self.tags)
            .bind(self.updated_at)
            .bind(self.id)
            .execute(pool)
            .await?;

        Ok(())
    }

    async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error> {
        sqlx::query("DELETE FROM short_note_sections WHERE id = ?")
            .bind(id)
            .execute(pool)
            .await?;

        Ok(())
    }
}

#[derive(Debug, Clone, FromRow)]
pub struct ShortNoteItem {
    pub id: i64,
    pub section_id: i64,
    pub content: String,
}

impl ShortNoteItem {
    pub async fn get_by_section(pool: &SqlitePool, section_id: i64) -> Result<Vec<Self>, Error> {
        let items = sqlx::query_as(
            "SELECT id, section_id, content FROM short_note_items WHERE section_id = ? ORDER BY id ASC"
        )
        .bind(section_id)
        .fetch_all(pool)
        .await?;
        Ok(items)
    }

    pub async fn get_by_id(pool: &SqlitePool, id: i64) -> Result<Self, Error> {
        let item = sqlx::query_as(
            "SELECT id, section_id, content FROM short_note_items WHERE id = ?"
        )
        .bind(id)
        .fetch_one(pool)
        .await?;
        Ok(item)
    }

    pub async fn create(&self, pool: &SqlitePool) -> Result<i64, Error> {
        let query = "
            INSERT INTO short_note_items (section_id, content) 
            VALUES (?, ?)
        ";

        let result = sqlx::query(query)
            .bind(self.section_id)
            .bind(&self.content)
            .execute(pool)
            .await?;

        Ok(result.last_insert_rowid())
    }

    pub async fn update(&self, pool: &SqlitePool) -> Result<(), Error> {
        let query = "
            UPDATE short_note_items 
            SET content = ? 
            WHERE id = ?
        ";

        sqlx::query(query)
            .bind(&self.content)
            .bind(self.id)
            .execute(pool)
            .await?;

        Ok(())
    }

    pub async fn delete(pool: &SqlitePool, id: i64) -> Result<(), Error> {
        sqlx::query("DELETE FROM short_note_items WHERE id = ?")
            .bind(id)
            .execute(pool)
            .await?;

        Ok(())
    }
}
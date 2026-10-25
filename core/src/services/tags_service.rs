use std::sync::Arc;
use sqlx::SqlitePool;
use chrono::Utc;

use crate::{
    models::{
        tags::{tags::Tag, ui_tags::UITag},
        repo::{ListRequest, Model},
    },
    utils::app_error::Result,
};

#[derive(Debug, Clone)]
pub struct TagsService {
    pool: Arc<SqlitePool>,
}

impl TagsService {
    pub fn new(pool: Arc<SqlitePool>) -> Self {
        TagsService { pool }
    }

    // --- Getters ---

    pub async fn get_list(&self, req: Option<ListRequest>) -> Result<Vec<UITag>> {
        let tags = Tag::get_all(&self.pool, req).await?;
        let ui_tags = tags.iter().map(UITag::from).collect();
        Ok(ui_tags)
    }

    // --- Creates ---

    pub async fn create_tag(&self, name: &str) -> Result<UITag> {
        let mut tag = Tag {
            id: 0,
            name: name.to_string(),
            created_at: Utc::now(),
        };
        
        tag.create(&self.pool).await?;
        
        Ok(UITag::from(&tag))
    }

    // --- Deletions ---

    pub async fn delete_tag(&self, id: i64) -> Result<()> {
        Tag::delete(&self.pool, id).await?;
        Ok(())
    }
}
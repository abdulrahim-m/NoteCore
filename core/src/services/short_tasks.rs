use std::sync::Arc;
use sqlx::SqlitePool;
use crate::{
    models::{
        repo::{ListRequest, Model, SearchParams}, tags::{tags::Tag, ui_tags::UITag}, tasks::{short_tasks::{ShortTaskItem, ShortTaskSection}, ui_short_tasks::{UIShortTaskItem, UIShortTaskSection}},
    }, utils::app_error::{AppError, ErrorType, Result},
};

#[derive(Debug, Clone)]
pub struct ShortTasksService {
    pool: Arc<SqlitePool>,
}

impl ShortTasksService {
    pub fn new(pool: Arc<SqlitePool>) -> Self {
        ShortTasksService { pool }
    }

    // --- Getters ---

    pub async fn get_section(&self, section_id: i64) -> Result<UIShortTaskSection> {
        let section = ShortTaskSection::get_by_id(&self.pool, section_id).await?;
        let items = ShortTaskItem::get_by_section(&self.pool, section_id).await?;
        
        self.map_ui_section(section, items).await
    }

    pub async fn get_all_sections(&self, req: Option<ListRequest>) -> Result<Vec<UIShortTaskSection>> {
        let sections = ShortTaskSection::get_all(&self.pool, req).await?;
        let mut res = Vec::new();

        for section in sections {
            let items = ShortTaskItem::get_by_section(&self.pool, section.id).await?;
            let ui_section = self.map_ui_section(section, items).await?;
            res.push(ui_section);
        }

        Ok(res)
    }

    pub async fn search(&self, params: SearchParams) -> Result<Vec<UIShortTaskSection>> {
        let sections = ShortTaskSection::search(&self.pool, params).await?;
        let mut res = Vec::new();

        for section in sections {
            let items = ShortTaskItem::get_by_section(&self.pool, section.id).await?;
            let ui_section = self.map_ui_section(section, items).await?;
            res.push(ui_section);
        }

        Ok(res)
    }

    // --- Creates ---

    pub async fn create_section(&self, title: &str, tags: Vec<i64>) -> Result<UIShortTaskSection> {
        let mut section = ShortTaskSection::new(title, tags);
        section.create(&self.pool).await?;
        
        self.map_ui_section(section, Vec::new()).await
    }

    pub async fn create_item(&self, section_id: i64, text: String) -> Result<UIShortTaskItem> {
        let mut item = ShortTaskItem::new(section_id, text);
        item.create(&self.pool).await?;
        
        Ok(UIShortTaskItem::from(item))
    }

    // --- Updates ---

    pub async fn update_section_title(&self, id: i64, title: String) -> Result<()> {
        let mut section = ShortTaskSection::get_by_id(&self.pool, id).await?;
        section.title = title;
        section.update(&self.pool).await?;
        Ok(())
    }

    pub async fn update_section_tags(&self, section_id: i64, tag_ids: Vec<i64>) -> Result<()> {
        let mut section = ShortTaskSection::get_by_id(&self.pool, section_id).await?;
        section.tags.0 = tag_ids;
        section.update(&self.pool).await?;
        Ok(())
    }

    pub async fn update_item_text(&self, id: i64, text: String) -> Result<()> {
        let mut item = ShortTaskItem::get_by_id(&self.pool, id).await?;
        item.text = text;
        item.update(&self.pool).await?;
        Ok(())
    }

    pub async fn toggle_item_done(&self, id: i64) -> Result<bool> {
        let mut item = ShortTaskItem::get_by_id(&self.pool, id).await?;
        item.done = !item.done;
        item.update(&self.pool).await?;
        Ok(item.done)
    }

    // --- Deletions ---

    pub async fn delete_section(&self, id: i64, force: bool) -> Result<()> {
        let section = ShortTaskSection::get_by_id(&self.pool, id).await?;

        if section.listed_items != 0 && !force {
            return Err(AppError::new("Short task section is not empty", ErrorType::Forbidden));
        }

        ShortTaskSection::delete(&self.pool, id).await?;
        Ok(())
    }

    pub async fn delete_item(&self, id: i64) -> Result<()> {
        ShortTaskItem::delete(&self.pool, id).await?;
        Ok(())
    }

    // --- Helpers ---

    async fn map_ui_section(
        &self,
        section: ShortTaskSection,
        items: Vec<ShortTaskItem>,
    ) -> Result<UIShortTaskSection> {
        let tags = Tag::get_with_ids(&self.pool, section.tags.0).await?;
        let ui_tags = tags
            .iter()
            .map(|t| UITag {
                id: t.id,
                name: t.name.clone(),
                created_at: t.created_at,
            })
            .collect();

        let ui_items = items
            .into_iter()
            .map(UIShortTaskItem::from)
            .collect();

        Ok(UIShortTaskSection {
            id: section.id,
            title: section.title,
            listed_items: section.listed_items,
            tags: ui_tags,
            items: ui_items,
            created_at: section.created_at,
            updated_at: section.updated_at,
        })
    }
}
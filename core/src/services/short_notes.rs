use std::sync::Arc;
use sqlx::SqlitePool;
use crate::{
    models::{
        notes::{short_notes::{ShortNoteItem, ShortNoteSection}, ui_short_notes::{UIShortNoteItem, UIShortNoteListItem, UIShortNoteSection}}, repo::{List, Model, SearchParams}, tags::{tags::Tag, ui_tags::UITag},
    }, utils::app_error::{AppError, ErrorType, Result},
};

pub struct ShortNotesService {
    pool: Arc<SqlitePool>,
}

impl ShortNotesService {
    pub fn new(pool: Arc<SqlitePool>) -> Self {
        ShortNotesService { pool }
    }

    // --- Getters ---

    pub async fn get_section(&self, section_id: i64) -> Result<UIShortNoteSection> {
        let section = ShortNoteSection::get_by_id(&self.pool, section_id).await?;
        let items = ShortNoteItem::get_by_section(&self.pool, section_id).await?;
        
        self.map_ui_section(section, items).await
    }

    pub async fn search(&self, params: SearchParams) -> Result<Vec<UIShortNoteListItem>> {
        let sections = ShortNoteSection::search(&self.pool, params).await?;
        let mut res = Vec::new();

        for section in sections {
            let tags = Tag::get_with_ids(&self.pool, section.tags.0.clone()).await?;
            let ui_section = ShortNotesService::map_list_item(section, tags);
            res.push(ui_section);
        }

        Ok(res)
    }

    pub async fn get_all_sections(&self, req: Option<List>) -> Result<Vec<UIShortNoteListItem>> {
        let sections = ShortNoteSection::get_all(&self.pool, req).await?;
        let mut res = Vec::new();

        for section in sections {
            let tags = Tag::get_with_ids(&self.pool, section.tags.0.clone()).await?;
            let ui_section = ShortNotesService::map_list_item(section, tags);
            res.push(ui_section);
        }

        Ok(res)
    }

    // --- Creates ---

    pub async fn create_section(&self, name: &str, tags: Vec<i64>) -> Result<UIShortNoteSection> {
        let mut section = ShortNoteSection::new(name, tags);
        section.create(&self.pool).await?;
        self.map_ui_section(section, Vec::new()).await
    }

    pub async fn create_item(&self, section_id: i64, content: String) -> Result<UIShortNoteItem> {
        let mut item = ShortNoteItem::new(section_id, content);
        item.create(&self.pool).await?;
        Ok(UIShortNoteItem::from(item))
    }

    // --- Updates ---

    pub async fn update_section_name(&self, id: i64, name: String) -> Result<()> {
        let mut section = ShortNoteSection::get_by_id(&self.pool, id).await?;
        section.name = name;
        section.update(&self.pool).await?;
        Ok(())
    }

    pub async fn update_section_tags(&self, section_id: i64, tag_ids: Vec<i64>) -> Result<()> {
        let mut section = ShortNoteSection::get_by_id(&self.pool, section_id).await?;
        section.tags.0 = tag_ids;
        section.update(&self.pool).await?;
        Ok(())
    }

    pub async fn update_item_content(&self, id: i64, content: String) -> Result<()> {
        let mut item = ShortNoteItem::get_by_id(&self.pool, id).await?;
        item.content = content;
        item.update(&self.pool).await?;
        Ok(())
    }

    // --- Deletions ---

    pub async fn delete_section(&self, id: i64, force: bool) -> Result<()> {
        let section = ShortNoteSection::get_by_id(&self.pool, id).await?;

        if section.listed_items != 0 && !force {
            return Err(AppError::new("Short note section is not empty", ErrorType::Forbidden));
        }

        ShortNoteSection::delete(&self.pool, id).await?;
        Ok(())
    }

    pub async fn delete_item(&self, id: i64) -> Result<()> {
        ShortNoteItem::delete(&self.pool, id).await?;
        Ok(())
    }

    // --- Helpers ---

    async fn map_ui_section(
        &self,
        section: ShortNoteSection,
        items: Vec<ShortNoteItem>,
    ) -> Result<UIShortNoteSection> {
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
            .map(|i| UIShortNoteItem {
                id: i.id,
                section_id: i.section_id,
                content: i.content,
            })
            .collect();

        Ok(UIShortNoteSection {
            id: section.id,
            name: section.name,
            listed_items: section.listed_items,
            tags: ui_tags,
            items: ui_items,
            created_at: section.created_at,
            updated_at: section.updated_at,
        })
    }

    fn map_list_item(section: ShortNoteSection, tags: Vec<Tag>) -> UIShortNoteListItem {
        let ui_tags = tags
            .iter()
            .map(|t| UITag {
                id: t.id,
                name: t.name.clone(),
                created_at: t.created_at,
            })
            .collect();

        UIShortNoteListItem {
            id: section.id,
            name: section.name,
            listed_items: section.listed_items,
            tags: ui_tags,
            created_at: section.created_at,
            updated_at: section.updated_at,
        }
    }
}
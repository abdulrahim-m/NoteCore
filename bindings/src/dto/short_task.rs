use chrono::{DateTime, Utc};
use notecore::models::tasks::ui_short_tasks::{UIShortTaskItem, UIShortTaskSection};

use super::tag::{map_tags, TagDto};

#[derive(Debug, Clone)]
pub struct ShortTaskItemDto {
    pub id: i64,
    pub section_id: i64,
    pub text: String,
    pub done: bool,
}

impl From<UIShortTaskItem> for ShortTaskItemDto {
    fn from(i: UIShortTaskItem) -> Self {
        ShortTaskItemDto {
            id: i.id,
            section_id: i.section_id,
            text: i.text,
            done: i.done,
        }
    }
}

#[derive(Debug, Clone)]
pub struct ShortTaskSectionDto {
    pub id: i64,
    pub title: String,
    pub listed_items: i64,
    pub tags: Vec<TagDto>,
    pub items: Vec<ShortTaskItemDto>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<UIShortTaskSection> for ShortTaskSectionDto {
    fn from(s: UIShortTaskSection) -> Self {
        ShortTaskSectionDto {
            id: s.id,
            title: s.title,
            listed_items: s.listed_items,
            tags: map_tags(s.tags),
            items: s.items.into_iter().map(ShortTaskItemDto::from).collect(),
            created_at: s.created_at,
            updated_at: s.updated_at,
        }
    }
}

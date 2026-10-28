use chrono::{DateTime, Utc};
use notecore::models::notes::ui_short_notes::{
    UIShortNoteItem, UIShortNoteListItem, UIShortNoteSection,
};

use super::tag::{map_tags, TagDto};

#[derive(Debug, Clone)]
pub struct ShortNoteItemDto {
    pub id: i64,
    pub section_id: i64,
    pub content: String,
}

impl From<UIShortNoteItem> for ShortNoteItemDto {
    fn from(i: UIShortNoteItem) -> Self {
        ShortNoteItemDto {
            id: i.id,
            section_id: i.section_id,
            content: i.content,
        }
    }
}

#[derive(Debug, Clone)]
pub struct ShortNoteSectionDto {
    pub id: i64,
    pub name: String,
    pub listed_items: i64,
    pub tags: Vec<TagDto>,
    pub items: Vec<ShortNoteItemDto>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<UIShortNoteSection> for ShortNoteSectionDto {
    fn from(s: UIShortNoteSection) -> Self {
        ShortNoteSectionDto {
            id: s.id,
            name: s.name,
            listed_items: s.listed_items,
            tags: map_tags(s.tags),
            items: s.items.into_iter().map(ShortNoteItemDto::from).collect(),
            created_at: s.created_at,
            updated_at: s.updated_at,
        }
    }
}

/// A section without its items (card overview).
#[derive(Debug, Clone)]
pub struct ShortNoteSectionListItemDto {
    pub id: i64,
    pub name: String,
    pub listed_items: i64,
    pub tags: Vec<TagDto>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<UIShortNoteListItem> for ShortNoteSectionListItemDto {
    fn from(s: UIShortNoteListItem) -> Self {
        ShortNoteSectionListItemDto {
            id: s.id,
            name: s.name,
            listed_items: s.listed_items,
            tags: map_tags(s.tags),
            created_at: s.created_at,
            updated_at: s.updated_at,
        }
    }
}

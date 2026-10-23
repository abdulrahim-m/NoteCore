use chrono::{DateTime, Utc};

use crate::models::{notes::short_notes::ShortNoteItem, tags::ui_tags::UITag};

pub struct UIShortNoteSection {
    pub id: i64,
    pub name: String,
    pub listed_items: i64,
    pub tags: Vec<UITag>,
    pub items: Vec<UIShortNoteItem>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub struct UIShortNoteListItem {
    pub id: i64,
    pub name: String,
    pub listed_items: i64,
    pub tags: Vec<UITag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub struct UIShortNoteItem {
    pub id: i64,
    pub section_id: i64,
    pub content: String,
}

impl UIShortNoteItem {
    pub fn from(i: ShortNoteItem) -> Self {
        Self { id: i.id, section_id: i.section_id, content: i.content }
    }
}
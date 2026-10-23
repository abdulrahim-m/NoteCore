use chrono::{DateTime, Utc};

use crate::models::tags::UITag;

pub struct UIShortNoteSection {
    pub id: i64,
    pub name: String,
    pub tags: Vec<UITag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub struct UIShortNoteItem {
    pub id: i64,
    pub section_id: i64,
    pub content: String,
}
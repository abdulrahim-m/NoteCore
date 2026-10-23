use chrono::{DateTime, Utc};

use crate::models::{tags::ui_tags::UITag, tasks::short_tasks::ShortTaskItem};


pub struct UIShortTaskSection {
    pub id: i64,
    pub title: String,
    pub listed_items: i64,
    pub tags: Vec<UITag>,
    pub items: Vec<UIShortTaskItem>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub struct UIShortTaskItem {
    pub id: i64,
    pub section_id: i64,
    pub text: String,
    pub done: bool,
}

impl UIShortTaskItem {
    pub fn from(i: ShortTaskItem) -> Self {
        Self { id: i.id, section_id: i.section_id, text: i.text, done: i.done }
    }
}
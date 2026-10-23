use chrono::{DateTime, Utc};

use crate::models::tags::UITag;



pub struct UIShortTaskSection {
    pub id: i64,
    pub title: String,
    pub tags: Vec<UITag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

pub struct UIShortTaskItem {
    pub id: i64,
    pub section_id: i64,
    pub text: String,
    pub done: bool,
}
use chrono::{DateTime, Utc};

use crate::models::{tags::ui_tags::UITag, tasks::task::{TaskOptions, Type}};

pub struct UITask {
    pub id: i64,
    pub title: String,
    pub description: String,
    pub task_type: Type,
    pub done: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub options: TaskOptions,
    pub tags: Vec<UITag>
}
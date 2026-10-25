use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;

use crate::api::models::ui_tags::RTag;

#[frb(non_final)]
pub struct RShortTaskSection {
    pub id: i64,
    pub title: String,
    pub listed_items: i64,
    pub tags: Vec<RTag>,
    pub items: Vec<RShortTaskItem>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[frb(non_final)]
pub struct RShortTaskItem {
    pub id: i64,
    pub section_id: i64,
    pub text: String,
    pub done: bool,
}

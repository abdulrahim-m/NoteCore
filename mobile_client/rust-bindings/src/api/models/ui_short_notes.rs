use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;

use crate::api::models::ui_tags::RTag;

#[frb(non_final)]
pub struct RShortNoteSection {
    pub id: i64,
    pub name: String,
    pub listed_items: i64,
    pub tags: Vec<RTag>,
    pub items: Vec<RShortNoteItem>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[frb(non_final)]
pub struct RShortNoteListItem {
    pub id: i64,
    pub name: String,
    pub listed_items: i64,
    pub tags: Vec<RTag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[frb(non_final)]
pub struct RShortNoteItem {
    pub id: i64,
    pub section_id: i64,
    pub content: String,
}
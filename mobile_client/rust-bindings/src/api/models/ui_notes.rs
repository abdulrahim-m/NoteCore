use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;

use crate::api::models::ui_tags::RTag;

#[frb(non_final)]
pub struct RNoteGroup {
    pub id: i64,
    pub name: String,
    pub listed_notes: i64,
    pub placing: i64,
}

#[frb(non_final)]
pub struct RNote {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub content: String,
    pub tags: Vec<RTag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[frb(non_final)]
pub struct RNoteListItem {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub preview: String,
    pub tags: Vec<RTag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
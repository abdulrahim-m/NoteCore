use chrono::{DateTime, Utc};

use crate::models::tags::tags::Tag;

pub struct UITag {
    pub id: i64,
    pub name: String,
    pub created_at: DateTime<Utc>,
}

impl UITag {
    pub fn from(t: &Tag) -> Self {
        UITag { id: t.id, name: t.name.clone(), created_at: t.created_at }
    }
}
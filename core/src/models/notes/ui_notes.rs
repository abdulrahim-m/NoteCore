use chrono::{DateTime, Utc};

use crate::models::tags::UITag;

pub struct UINoteGroup {
    pub id: i64,
    pub name: String,
    pub placing: i64,
}

impl UINoteGroup {
    pub fn new() -> Self {
        UINoteGroup { id: 0, name: String::new(), placing: 0 }
    }
}

pub struct UINote {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub content: String,
    pub tags: Vec<UITag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl UINote {
    pub fn new() -> Self {
        UINote { 
            id: 0, 
            group_id: None, 
            title: "untitled".to_string(), 
            content: String::new(), 
            tags: Vec::new(), 
            created_at: Utc::now(), 
            updated_at: Utc::now()
        }       
    }
}

pub struct UINoteListItem {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub preview: String,
    pub tags: Vec<UITag>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}
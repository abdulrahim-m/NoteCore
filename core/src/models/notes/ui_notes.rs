use chrono::{DateTime, Utc};

use crate::models::{notes::notes::{Note, NoteGroup}, tags::{tags::Tag, ui_tags::UITag}};

pub struct UINoteGroup {
    pub id: i64,
    pub name: String,
    pub listed_notes: i64,
    pub placing: i64,
}

impl UINoteGroup {
    pub fn from(group: NoteGroup) -> Self {
        UINoteGroup { id: group.id, name: group.name.clone(), listed_notes: group.listed_notes, placing: group.placing }
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
    pub fn from(n: Note, tags: Vec<Tag>) -> Self {
        UINote { 
            id: n.id, 
            group_id: n.group_id, 
            title: n.title, 
            content: n.content, 
            tags: tags.iter().map(|t| UITag::from(t)).collect(),
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
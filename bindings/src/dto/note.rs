use chrono::{DateTime, Utc};
use notecore::models::notes::ui_notes::{UINote, UINoteGroup, UINoteListItem};

use super::tag::{map_tags, TagDto};

#[derive(Debug, Clone)]
pub struct NoteGroupDto {
    pub id: i64,
    pub name: String,
    pub listed_notes: i64,
    pub placing: i64,
}

impl From<UINoteGroup> for NoteGroupDto {
    fn from(g: UINoteGroup) -> Self {
        NoteGroupDto {
            id: g.id,
            name: g.name,
            listed_notes: g.listed_notes,
            placing: g.placing,
        }
    }
}

#[derive(Debug, Clone)]
pub struct NoteDto {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub content: String,
    pub tags: Vec<TagDto>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<UINote> for NoteDto {
    fn from(n: UINote) -> Self {
        NoteDto {
            id: n.id,
            group_id: n.group_id,
            title: n.title,
            content: n.content,
            tags: map_tags(n.tags),
            created_at: n.created_at,
            updated_at: n.updated_at,
        }
    }
}

#[derive(Debug, Clone)]
pub struct NoteListItemDto {
    pub id: i64,
    pub group_id: Option<i64>,
    pub title: String,
    pub preview: String,
    pub tags: Vec<TagDto>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<UINoteListItem> for NoteListItemDto {
    fn from(n: UINoteListItem) -> Self {
        NoteListItemDto {
            id: n.id,
            group_id: n.group_id,
            title: n.title,
            preview: n.preview,
            tags: map_tags(n.tags),
            created_at: n.created_at,
            updated_at: n.updated_at,
        }
    }
}

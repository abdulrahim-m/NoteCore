use chrono::{DateTime, Utc};
use notecore::models::tags::ui_tags::UITag;

#[derive(Debug, Clone)]
pub struct TagDto {
    pub id: i64,
    pub name: String,
    pub created_at: DateTime<Utc>,
}

impl From<UITag> for TagDto {
    fn from(t: UITag) -> Self {
        TagDto {
            id: t.id,
            name: t.name,
            created_at: t.created_at,
        }
    }
}

pub(crate) fn map_tags(tags: Vec<UITag>) -> Vec<TagDto> {
    tags.into_iter().map(TagDto::from).collect()
}

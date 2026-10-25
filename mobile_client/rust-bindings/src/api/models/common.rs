use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

#[frb]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RListRequest {
    pub current_page: i64,
    pub pages_count: i64,
    pub limit: i64,
}

impl From<RListRequest> for notecore::models::repo::ListRequest {
    fn from(r: RListRequest) -> Self {
        Self {
            limit: r.limit,
            current_page: r.current_page,
            pages_count: r.pages_count
        }
    }
}

#[frb]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RSearchParams {
    pub text: Option<String>,
    pub tags: Option<Vec<i64>>,
    pub created_before: Option<DateTime<Utc>>,
    pub created_after: Option<DateTime<Utc>>
}

impl From<RSearchParams> for notecore::models::repo::SearchParams {
    fn from(s: RSearchParams) -> Self {
        Self { 
            text: s.text,
            tags: s.tags,
            created_before: s.created_before,
            created_after: s.created_after
        }
    }
}
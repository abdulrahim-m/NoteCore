use chrono::{DateTime, Utc};
use notecore::models::repo::{ListRequest, SearchParams};

use crate::error::ApiError;

/// Pagination request.
#[derive(Debug, Clone)]
pub struct ListRequestDto {
    /// 1-based page number.
    pub current_page: i64,
    /// Page size.
    pub limit: i64,
}

impl TryFrom<ListRequestDto> for ListRequest {
    type Error = ApiError;

    fn try_from(r: ListRequestDto) -> Result<Self, Self::Error> {
        // The core computes `offset = (current_page - 1) * limit`, so a page below 1
        // would produce a negative OFFSET. Reject it at the boundary.
        if r.current_page < 1 {
            return Err(ApiError::validation("current_page must be >= 1"));
        }
        if r.limit < 1 {
            return Err(ApiError::validation("limit must be >= 1"));
        }
        Ok(ListRequest {
            current_page: r.current_page,
            // Not read by the core's queries; it is not part of the bridged request.
            pages_count: 0,
            limit: r.limit,
        })
    }
}

pub(crate) fn list_request_opt(
    req: Option<ListRequestDto>,
) -> Result<Option<ListRequest>, ApiError> {
    req.map(ListRequest::try_from).transpose()
}

#[derive(Debug, Clone)]
pub struct SearchParamsDto {
    pub text: Option<String>,
    /// Every listed tag id must be present on a match (AND semantics).
    pub tags: Option<Vec<i64>>,
    pub created_before: Option<DateTime<Utc>>,
    pub created_after: Option<DateTime<Utc>>,
}

impl From<SearchParamsDto> for SearchParams {
    fn from(p: SearchParamsDto) -> Self {
        SearchParams {
            text: p.text,
            tags: p.tags,
            created_before: p.created_before,
            created_after: p.created_after,
        }
    }
}

use flutter_rust_bridge::frb;
use notecore::services::tags_service::TagsService;

use crate::dto::query::{list_request_opt, ListRequestDto};
use crate::dto::tag::TagDto;
use crate::error::ApiError;

/// Tags shared by notes, tasks and their short variants.
#[frb(opaque)]
pub struct TagsApi {
    service: TagsService,
}

impl TagsApi {
    pub(crate) fn new(service: TagsService) -> Self {
        Self { service }
    }

    /// `req = None` returns every tag.
    pub async fn get_list(&self, req: Option<ListRequestDto>) -> Result<Vec<TagDto>, ApiError> {
        let list = self.service.get_list(list_request_opt(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn create_tag(&self, name: String) -> Result<TagDto, ApiError> {
        Ok(self.service.create_tag(&name).await?.into())
    }

    pub async fn delete_tag(&self, id: i64) -> Result<(), ApiError> {
        Ok(self.service.delete_tag(id).await?)
    }
}

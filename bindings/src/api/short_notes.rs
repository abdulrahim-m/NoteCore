use flutter_rust_bridge::frb;
use notecore::models::repo::ListRequest;
use notecore::services::short_notes::ShortNotesService;

use crate::dto::query::{list_request_opt, ListRequestDto, SearchParamsDto};
use crate::dto::short_note::{ShortNoteItemDto, ShortNoteSectionDto, ShortNoteSectionListItemDto};
use crate::error::ApiError;

/// Short-note sections and their items.
#[frb(opaque)]
pub struct ShortNotesApi {
    service: ShortNotesService,
}

impl ShortNotesApi {
    pub(crate) fn new(service: ShortNotesService) -> Self {
        Self { service }
    }

    // --- Get ---

    pub async fn get_section(&self, section_id: i64) -> Result<ShortNoteSectionDto, ApiError> {
        Ok(self.service.get_section(section_id).await?.into())
    }

    /// `req = None` returns every section.
    pub async fn get_all_sections(
        &self,
        req: Option<ListRequestDto>,
    ) -> Result<Vec<ShortNoteSectionListItemDto>, ApiError> {
        let list = self.service.get_all_sections(list_request_opt(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn search(
        &self,
        params: SearchParamsDto,
        req: ListRequestDto,
    ) -> Result<Vec<ShortNoteSectionListItemDto>, ApiError> {
        let list = self.service.search(params.into(), ListRequest::try_from(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    // --- Create ---

    pub async fn create_section(
        &self,
        name: String,
        tag_ids: Vec<i64>,
    ) -> Result<ShortNoteSectionDto, ApiError> {
        Ok(self.service.create_section(&name, tag_ids).await?.into())
    }

    pub async fn create_item(
        &self,
        section_id: i64,
        content: String,
    ) -> Result<ShortNoteItemDto, ApiError> {
        Ok(self.service.create_item(section_id, content).await?.into())
    }

    // --- Update ---

    pub async fn update_section_name(&self, id: i64, name: String) -> Result<(), ApiError> {
        Ok(self.service.update_section_name(id, name).await?)
    }

    pub async fn update_section_tags(
        &self,
        section_id: i64,
        tag_ids: Vec<i64>,
    ) -> Result<(), ApiError> {
        Ok(self.service.update_section_tags(section_id, tag_ids).await?)
    }

    pub async fn update_item_content(&self, id: i64, content: String) -> Result<(), ApiError> {
        Ok(self.service.update_item_content(id, content).await?)
    }

    // --- Delete ---

    /// Fails with `ApiErrorKind::Forbidden` if the section has items and `force` is false.
    pub async fn delete_section(&self, id: i64, force: bool) -> Result<(), ApiError> {
        Ok(self.service.delete_section(id, force).await?)
    }

    pub async fn delete_item(&self, id: i64) -> Result<(), ApiError> {
        Ok(self.service.delete_item(id).await?)
    }
}

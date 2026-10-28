use flutter_rust_bridge::frb;
use notecore::services::short_tasks::ShortTasksService;

use crate::dto::query::{list_request_opt, ListRequestDto, SearchParamsDto};
use crate::dto::short_task::{ShortTaskItemDto, ShortTaskSectionDto};
use crate::error::ApiError;

/// Short-task sections (checklists) and their items.
#[frb(opaque)]
pub struct ShortTasksApi {
    service: ShortTasksService,
}

impl ShortTasksApi {
    pub(crate) fn new(service: ShortTasksService) -> Self {
        Self { service }
    }

    // --- Get ---

    pub async fn get_section(&self, section_id: i64) -> Result<ShortTaskSectionDto, ApiError> {
        Ok(self.service.get_section(section_id).await?.into())
    }

    /// `req = None` returns every section (each with its items).
    pub async fn get_all_sections(
        &self,
        req: Option<ListRequestDto>,
    ) -> Result<Vec<ShortTaskSectionDto>, ApiError> {
        let list = self.service.get_all_sections(list_request_opt(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn search(
        &self,
        params: SearchParamsDto,
    ) -> Result<Vec<ShortTaskSectionDto>, ApiError> {
        let list = self.service.search(params.into()).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    // --- Create ---

    pub async fn create_section(
        &self,
        title: String,
        tag_ids: Vec<i64>,
    ) -> Result<ShortTaskSectionDto, ApiError> {
        Ok(self.service.create_section(&title, tag_ids).await?.into())
    }

    pub async fn create_item(
        &self,
        section_id: i64,
        text: String,
    ) -> Result<ShortTaskItemDto, ApiError> {
        Ok(self.service.create_item(section_id, text).await?.into())
    }

    // --- Update ---

    pub async fn update_section_title(&self, id: i64, title: String) -> Result<(), ApiError> {
        Ok(self.service.update_section_title(id, title).await?)
    }

    pub async fn update_section_tags(
        &self,
        section_id: i64,
        tag_ids: Vec<i64>,
    ) -> Result<(), ApiError> {
        Ok(self.service.update_section_tags(section_id, tag_ids).await?)
    }

    pub async fn update_item_text(&self, id: i64, text: String) -> Result<(), ApiError> {
        Ok(self.service.update_item_text(id, text).await?)
    }

    /// Flips the item's `done` flag and returns the new value.
    pub async fn toggle_item_done(&self, id: i64) -> Result<bool, ApiError> {
        Ok(self.service.toggle_item_done(id).await?)
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

use flutter_rust_bridge::frb;
use notecore::models::repo::ListRequest;
use notecore::services::tasks::TasksService;

use crate::dto::query::{list_request_opt, ListRequestDto, SearchParamsDto};
use crate::dto::task::{TaskDto, TaskOptionsDto, TaskTypeDto};
use crate::error::ApiError;

/// Full tasks (priority, due date, schedule, check list).
#[frb(opaque)]
pub struct TasksApi {
    service: TasksService,
}

impl TasksApi {
    pub(crate) fn new(service: TasksService) -> Self {
        Self { service }
    }

    // --- Get ---

    pub async fn get_task(&self, id: i64) -> Result<TaskDto, ApiError> {
        Ok(self.service.get_task(id).await?.into())
    }

    /// `req = None` returns every task.
    pub async fn get_list(&self, req: Option<ListRequestDto>) -> Result<Vec<TaskDto>, ApiError> {
        let list = self.service.get_list(list_request_opt(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    pub async fn search_tasks(&self, params: SearchParamsDto, req: ListRequestDto) -> Result<Vec<TaskDto>, ApiError> {
        let list = self.service.search_tasks(params.into(), ListRequest::try_from(req)?).await?;
        Ok(list.into_iter().map(Into::into).collect())
    }

    // --- Create ---

    pub async fn create_task(
        &self,
        title: String,
        description: String,
        task_type: TaskTypeDto,
        options: TaskOptionsDto,
        tag_ids: Vec<i64>,
    ) -> Result<TaskDto, ApiError> {
        let task = self
            .service
            .create_task(&title, &description, task_type.into(), options.into(), tag_ids)
            .await?;
        Ok(task.into())
    }

    // --- Update ---

    pub async fn update_task_details(
        &self,
        id: i64,
        title: String,
        description: String,
        task_type: TaskTypeDto,
    ) -> Result<(), ApiError> {
        Ok(self
            .service
            .update_task_details(id, title, description, task_type.into())
            .await?)
    }

    /// Flips the task's `done` flag and returns the new value.
    pub async fn toggle_done(&self, id: i64) -> Result<bool, ApiError> {
        Ok(self.service.toggle_done(id).await?)
    }

    pub async fn update_options(&self, id: i64, options: TaskOptionsDto) -> Result<(), ApiError> {
        Ok(self.service.update_options(id, options.into()).await?)
    }

    pub async fn update_tags(&self, id: i64, tag_ids: Vec<i64>) -> Result<(), ApiError> {
        Ok(self.service.update_tags(id, tag_ids).await?)
    }

    // --- Delete ---

    pub async fn delete_task(&self, id: i64) -> Result<(), ApiError> {
        Ok(self.service.delete_task(id).await?)
    }
}

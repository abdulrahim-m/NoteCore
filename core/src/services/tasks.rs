use std::sync::Arc;
use sqlx::SqlitePool;

use crate::{
    models::{
        tasks::{
            task::{Task, TaskOptions, Type},
            ui_task::UITask,
        },
        repo::{ListRequest, Model, SearchParams},
        tags::{tags::Tag, ui_tags::UITag},
    },
    utils::app_error::Result,
};

#[derive(Debug, Clone)]
pub struct TasksService {
    pool: Arc<SqlitePool>,
}

impl TasksService {
    pub fn new(pool: Arc<SqlitePool>) -> Self {
        TasksService { pool }
    }

    // --- Getters ---

    pub async fn get_task(&self, id: i64) -> Result<UITask> {
        let task = Task::get_by_id(&self.pool, id).await?;
        self.map_ui_task(task).await
    }

    pub async fn get_list(&self, req: Option<ListRequest>) -> Result<Vec<UITask>> {
        let tasks = Task::get_all(&self.pool, req).await?;
        let mut res = Vec::new();
        for task in tasks {
            res.push(self.map_ui_task(task).await?);
        }
        Ok(res)
    }

    pub async fn search_tasks(&self, params: SearchParams, list: ListRequest) -> Result<Vec<UITask>> {
        let tasks = Task::search(&self.pool, params, Some(list)).await?;
        let mut res = Vec::new();
        for task in tasks {
            res.push(self.map_ui_task(task).await?);
        }
        Ok(res)
    }

    // --- Creates ---

    pub async fn create_task(&self, title: &str, description: &str, task_type: Type, options: TaskOptions, tags: Vec<i64>) -> Result<UITask> {
        let mut task = Task::new(title, description, task_type, options, tags);
        task.create(&self.pool).await?;
        self.map_ui_task(task).await
    }

    // --- Updates ---

    pub async fn update_task_details(&self, id: i64, title: String, description: String, task_type: Type) -> Result<()> {
        let mut task = Task::get_by_id(&self.pool, id).await?;
        task.title = title;
        task.description = description;
        task.task_type = task_type;
        task.update(&self.pool).await?;
        Ok(())
    }

    pub async fn toggle_done(&self, id: i64) -> Result<bool> {
        let mut task = Task::get_by_id(&self.pool, id).await?;
        task.done = !task.done;
        task.update(&self.pool).await?;
        Ok(task.done)
    }

    pub async fn update_options(&self, id: i64, options: TaskOptions) -> Result<()> {
        let mut task = Task::get_by_id(&self.pool, id).await?;
        task.options = sqlx::types::Json(options);
        task.update(&self.pool).await?;
        Ok(())
    }

    pub async fn update_tags(&self, id: i64, tag_ids: Vec<i64>) -> Result<()> {
        let mut task = Task::get_by_id(&self.pool, id).await?;
        task.tags = sqlx::types::Json(tag_ids);
        task.update(&self.pool).await?;
        Ok(())
    }

    // --- Deletions ---

    pub async fn delete_task(&self, id: i64) -> Result<()> {
        Task::delete(&self.pool, id).await?;
        Ok(())
    }

    // --- Helpers ---

    async fn map_ui_task(&self, task: Task) -> Result<UITask> {
        let raw_tags = Tag::get_with_ids(&self.pool, task.tags.0).await?;
        let ui_tags = raw_tags
            .iter()
            .map(|t| UITag {
                id: t.id,
                name: t.name.clone(),
                created_at: t.created_at,
            })
            .collect();

        Ok(UITask {
            id: task.id,
            title: task.title,
            description: task.description,
            task_type: task.task_type,
            done: task.done,
            created_at: task.created_at,
            updated_at: task.updated_at,
            options: task.options.0,
            tags: ui_tags,
        })
    }
}
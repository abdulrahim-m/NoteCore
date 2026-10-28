pub mod notes;
pub mod short_notes;
pub mod short_tasks;
pub mod tags;
pub mod tasks;

use std::sync::Arc;

use flutter_rust_bridge::frb;
use notecore::models::settings::Settings;
use notecore::services::{
    database_manager::DatabaseManager, notes::NotesService, short_notes::ShortNotesService,
    short_tasks::ShortTasksService, tags_service::TagsService, tasks::TasksService,
};
use sqlx::SqlitePool;

use crate::error::ApiError;

use self::{
    notes::NotesApi, short_notes::ShortNotesApi, short_tasks::ShortTasksApi, tags::TagsApi,
    tasks::TasksApi,
};

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[frb(opaque)]
pub struct NoteCore {
    pool: Arc<SqlitePool>,
    notes: NotesService,
    short_notes: ShortNotesService,
    tasks: TasksService,
    short_tasks: ShortTasksService,
    tags: TagsService,
}

impl NoteCore {
    pub async fn open(base_path: String) -> Result<NoteCore, ApiError> {
        let pool = Arc::new(DatabaseManager::init(base_path).await?);

        Ok(NoteCore {
            notes: NotesService::new(pool.clone()),
            short_notes: ShortNotesService::new(pool.clone()),
            tasks: TasksService::new(pool.clone()),
            short_tasks: ShortTasksService::new(pool.clone()),
            tags: TagsService::new(pool.clone()),
            pool,
        })
    }

    pub async fn close(&self) {
        self.pool.close().await;
    }

    // --- Feature APIs ---

    #[frb(sync)]
    pub fn notes(&self) -> NotesApi {
        NotesApi::new(self.notes.clone())
    }

    #[frb(sync)]
    pub fn short_notes(&self) -> ShortNotesApi {
        ShortNotesApi::new(self.short_notes.clone())
    }

    #[frb(sync)]
    pub fn tasks(&self) -> TasksApi {
        TasksApi::new(self.tasks.clone())
    }

    #[frb(sync)]
    pub fn short_tasks(&self) -> ShortTasksApi {
        ShortTasksApi::new(self.short_tasks.clone())
    }

    #[frb(sync)]
    pub fn tags(&self) -> TagsApi {
        TagsApi::new(self.tags.clone())
    }

    // --- Settings ---

    pub async fn get_setting(&self, key: String) -> Result<Option<String>, ApiError> {
        Ok(Settings::get_setting(&self.pool, &key).await?)
    }

    pub async fn set_setting(&self, key: String, value: String) -> Result<(), ApiError> {
        Ok(Settings::set(&self.pool, &key, &value).await?)
    }
}

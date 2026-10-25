use std::sync::Arc;
use notecore::{
    services::{
        database_manager::DatabaseManager,
        notes::NotesService,
        short_notes::ShortNotesService,
        short_tasks::ShortTasksService,
        tags_service::TagsService,
        tasks::TasksService,
    },
    utils::app_error::Result,
};

use crate::api::map::*;
use crate::api::models::{
    common::{RListRequest, RSearchParams},
    ui_notes::{RNote, RNoteGroup, RNoteListItem},
    ui_short_notes::{RShortNoteSection, RShortNoteListItem, RShortNoteItem},
    ui_short_tasks::{RShortTaskSection, RShortTaskItem},
    ui_tags::RTag,
    ui_task::{RTask, RType, RTaskOptions},
};

#[flutter_rust_bridge::frb(opaque)]
#[derive(Clone)]
pub struct BridgeManager {
    tasks: TasksService,
    short_tasks: ShortTasksService,
    notes: NotesService,
    short_notes: ShortNotesService,
    tags: TagsService,
}

#[flutter_rust_bridge::frb]
impl BridgeManager {
    pub async fn init(db_path: String) -> Result<Self> {
        let pool = DatabaseManager::init(db_path).await.map_err(|e| {
            notecore::utils::app_error::AppError::new(&e.to_string(), notecore::utils::app_error::ErrorType::Internal)
        })?;
        let arc_pool = Arc::new(pool);
        
        Ok(Self { 
            tasks: TasksService::new(arc_pool.clone()),
            short_tasks: ShortTasksService::new(arc_pool.clone()),
            notes: NotesService::new(arc_pool.clone()),
            short_notes: ShortNotesService::new(arc_pool.clone()),
            tags: TagsService::new(arc_pool.clone()),
        })
    }

    // ==================== TASKS SERVICE ====================

    pub async fn get_task(&self, id: i64) -> Result<RTask> {
        let task = self.tasks.get_task(id).await?;
        Ok(map_task(task))
    }

    pub async fn get_tasks_list(&self, req: Option<RListRequest>) -> Result<Vec<RTask>> {
        let tasks = self.tasks.get_list(req.map(|r| r.into())).await?;
        Ok(tasks.into_iter().map(map_task).collect())
    }

    pub async fn search_tasks(&self, params: RSearchParams) -> Result<Vec<RTask>> {
        let tasks = self.tasks.search_tasks(params.into()).await?;
        Ok(tasks.into_iter().map(map_task).collect())
    }

    pub async fn create_task(
        &self,
        title: String,
        description: String,
        task_type: RType,
        options: RTaskOptions,
        tags: Vec<i64>,
    ) -> Result<RTask> {
        let task = self.tasks.create_task(
            &title, 
            &description, 
            task_type.into(), 
            options.into(), 
            tags
        ).await?;
        Ok(map_task(task))
    }

    pub async fn update_task_details(&self, id: i64, title: String, description: String, task_type: RType) -> Result<()> {
        self.tasks.update_task_details(id, title, description, task_type.into()).await
    }

    pub async fn toggle_task_done(&self, id: i64) -> Result<bool> {
        self.tasks.toggle_done(id).await
    }

    pub async fn update_task_options(&self, id: i64, options: RTaskOptions) -> Result<()> {
        self.tasks.update_options(id, options.into()).await
    }

    pub async fn update_task_tags(&self, id: i64, tag_ids: Vec<i64>) -> Result<()> {
        self.tasks.update_tags(id, tag_ids).await
    }

    pub async fn delete_task(&self, id: i64) -> Result<()> {
        self.tasks.delete_task(id).await
    }

    // ==================== TAGS SERVICE ====================

    pub async fn get_tags_list(&self, req: Option<RListRequest>) -> Result<Vec<RTag>> {
        let tags = self.tags.get_list(req.map(|r| r.into())).await?;
        Ok(tags.into_iter().map(map_tag).collect())
    }

    pub async fn create_tag(&self, name: String) -> Result<RTag> {
        let tag = self.tags.create_tag(&name).await?;
        Ok(map_tag(tag))
    }

    pub async fn delete_tag(&self, id: i64) -> Result<()> {
        self.tags.delete_tag(id).await
    }

    // ==================== SHORT TASKS SERVICE ====================

    pub async fn get_short_task_section(&self, section_id: i64) -> Result<RShortTaskSection> {
        let section = self.short_tasks.get_section(section_id).await?;
        Ok(map_short_task_section(section))
    }

    pub async fn get_all_short_task_sections(&self, req: Option<RListRequest>) -> Result<Vec<RShortTaskSection>> {
        let sections = self.short_tasks.get_all_sections(req.map(|r| r.into())).await?;
        Ok(sections.into_iter().map(map_short_task_section).collect())
    }

    pub async fn search_short_tasks(&self, params: RSearchParams) -> Result<Vec<RShortTaskSection>> {
        let sections = self.short_tasks.search(params.into()).await?;
        Ok(sections.into_iter().map(map_short_task_section).collect())
    }

    pub async fn create_short_task_section(&self, title: String, tags: Vec<i64>) -> Result<RShortTaskSection> {
        let section = self.short_tasks.create_section(&title, tags).await?;
        Ok(map_short_task_section(section))
    }

    pub async fn create_short_task_item(&self, section_id: i64, text: String) -> Result<RShortTaskItem> {
        let item = self.short_tasks.create_item(section_id, text).await?;
        Ok(map_short_task_item(item))
    }

    pub async fn update_short_task_section_title(&self, id: i64, title: String) -> Result<()> {
        self.short_tasks.update_section_title(id, title).await
    }

    pub async fn update_short_task_section_tags(&self, section_id: i64, tag_ids: Vec<i64>) -> Result<()> {
        self.short_tasks.update_section_tags(section_id, tag_ids).await
    }

    pub async fn update_short_task_item_text(&self, id: i64, text: String) -> Result<()> {
        self.short_tasks.update_item_text(id, text).await
    }

    pub async fn toggle_short_task_item_done(&self, id: i64) -> Result<bool> {
        self.short_tasks.toggle_item_done(id).await
    }

    pub async fn delete_short_task_section(&self, id: i64, force: bool) -> Result<()> {
        self.short_tasks.delete_section(id, force).await
    }

    pub async fn delete_short_task_item(&self, id: i64) -> Result<()> {
        self.short_tasks.delete_item(id).await
    }

    // ==================== SHORT NOTES SERVICE ====================

    pub async fn get_short_note_section(&self, section_id: i64) -> Result<RShortNoteSection> {
        let section = self.short_notes.get_section(section_id).await?;
        Ok(map_short_note_section(section))
    }

    pub async fn get_all_short_note_sections(&self, req: Option<RListRequest>) -> Result<Vec<RShortNoteListItem>> {
        let list = self.short_notes.get_all_sections(req.map(|r| r.into())).await?;
        Ok(list.into_iter().map(map_short_note_list_item).collect())
    }

    pub async fn search_short_notes(&self, params: RSearchParams) -> Result<Vec<RShortNoteListItem>> {
        let list = self.short_notes.search(params.into()).await?;
        Ok(list.into_iter().map(map_short_note_list_item).collect())
    }

    pub async fn create_short_note_section(&self, name: String, tags: Vec<i64>) -> Result<RShortNoteSection> {
        let section = self.short_notes.create_section(&name, tags).await?;
        Ok(map_short_note_section(section))
    }

    pub async fn create_short_note_item(&self, section_id: i64, content: String) -> Result<RShortNoteItem> {
        let item = self.short_notes.create_item(section_id, content).await?;
        Ok(map_short_note_item(item))
    }

    pub async fn update_short_note_section_name(&self, id: i64, name: String) -> Result<()> {
        self.short_notes.update_section_name(id, name).await
    }

    pub async fn update_short_note_section_tags(&self, section_id: i64, tag_ids: Vec<i64>) -> Result<()> {
        self.short_notes.update_section_tags(section_id, tag_ids).await
    }

    pub async fn update_short_note_item_content(&self, id: i64, content: String) -> Result<()> {
        self.short_notes.update_item_content(id, content).await
    }

    pub async fn delete_short_note_section(&self, id: i64, force: bool) -> Result<()> {
        self.short_notes.delete_section(id, force).await
    }

    pub async fn delete_short_note_item(&self, id: i64) -> Result<()> {
        self.short_notes.delete_item(id).await
    }

    // ==================== NOTES SERVICE ====================

    pub async fn get_note(&self, id: i64) -> Result<RNote> {
        let note = self.notes.get_note(id).await?;
        Ok(map_note(note))
    }

    pub async fn get_notes_list(&self, req: RListRequest) -> Result<Vec<RNoteListItem>> {
        let list = self.notes.get_list(req.into()).await?;
        Ok(list.into_iter().map(map_note_list_item).collect())
    }

    pub async fn get_notes_list_group(&self, req: RListRequest, group_id: i64) -> Result<Vec<RNoteListItem>> {
        let list = self.notes.get_list_group(req.into(), group_id).await?;
        Ok(list.into_iter().map(map_note_list_item).collect())
    }

    pub async fn search_notes(&self, params: RSearchParams) -> Result<Vec<RNoteListItem>> {
        let list = self.notes.search(params.into()).await?;
        Ok(list.into_iter().map(map_note_list_item).collect())
    }

    pub async fn get_note_groups(&self) -> Result<Vec<RNoteGroup>> {
        let groups = self.notes.get_groups().await?;
        Ok(groups.into_iter().map(map_note_group).collect())
    }

    pub async fn create_empty_note(&self) -> Result<RNote> {
        let note = self.notes.create_note().await?;
        Ok(map_note(note))
    }

    pub async fn create_note_group(&self, name: String, placing: i64) -> Result<RNoteGroup> {
        let group = self.notes.create_note_group(&name, placing).await?;
        Ok(map_note_group(group))
    }

    pub async fn update_note(&self, id: i64, title: String, content: String) -> Result<()> {
        self.notes.update_note(id, title, content).await
    }

    pub async fn add_notes_to_group(&self, group_id: Option<i64>, notes_ids: Vec<i64>) -> Result<()> {
        self.notes.add_to_group(group_id, notes_ids).await
    }

    pub async fn update_note_tags(&self, note_id: i64, tag_ids: Vec<i64>) -> Result<()> {
        self.notes.update_tags(note_id, tag_ids).await
    }

    pub async fn update_note_group(&self, id: i64, name: String) -> Result<()> {
        self.notes.update_note_group(id, name).await
    }

    pub async fn delete_note_group(&self, id: i64) -> Result<()> {
        self.notes.delete_group(id).await
    }

    pub async fn delete_note(&self, id: i64) -> Result<()> {
        self.notes.delete_note(id).await
    }
}
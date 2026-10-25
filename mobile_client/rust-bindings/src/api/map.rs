use crate::api::models::{
    ui_notes::{RNote, RNoteGroup, RNoteListItem},
    ui_short_notes::{RShortNoteSection, RShortNoteListItem, RShortNoteItem},
    ui_short_tasks::{RShortTaskSection, RShortTaskItem},
    ui_tags::RTag,
    ui_task::RTask,
};

// --- Tags ---
pub fn map_tag(core: notecore::models::tags::ui_tags::UITag) -> RTag {
    RTag {
        id: core.id,
        name: core.name,
        created_at: core.created_at,
    }
}

// --- Notes ---
pub fn map_note_group(core: notecore::models::notes::ui_notes::UINoteGroup) -> RNoteGroup {
    RNoteGroup {
        id: core.id,
        name: core.name,
        listed_notes: core.listed_notes,
        placing: core.placing,
    }
}

pub fn map_note(core: notecore::models::notes::ui_notes::UINote) -> RNote {
    RNote {
        id: core.id,
        group_id: core.group_id,
        title: core.title,
        content: core.content,
        tags: core.tags.into_iter().map(map_tag).collect(),
        created_at: core.created_at,
        updated_at: core.updated_at,
    }
}

pub fn map_note_list_item(core: notecore::models::notes::ui_notes::UINoteListItem) -> RNoteListItem {
    RNoteListItem {
        id: core.id,
        group_id: core.group_id,
        title: core.title,
        preview: core.preview,
        tags: core.tags.into_iter().map(map_tag).collect(),
        created_at: core.created_at,
        updated_at: core.updated_at,
    }
}

// --- Short Notes ---
pub fn map_short_note_item(core: notecore::models::notes::ui_short_notes::UIShortNoteItem) -> RShortNoteItem {
    RShortNoteItem {
        id: core.id,
        section_id: core.section_id,
        content: core.content,
    }
}

pub fn map_short_note_section(core: notecore::models::notes::ui_short_notes::UIShortNoteSection) -> RShortNoteSection {
    RShortNoteSection {
        id: core.id,
        name: core.name,
        listed_items: core.listed_items,
        tags: core.tags.into_iter().map(map_tag).collect(),
        items: core.items.into_iter().map(map_short_note_item).collect(),
        created_at: core.created_at,
        updated_at: core.updated_at,
    }
}

pub fn map_short_note_list_item(core: notecore::models::notes::ui_short_notes::UIShortNoteListItem) -> RShortNoteListItem {
    RShortNoteListItem {
        id: core.id,
        name: core.name,
        listed_items: core.listed_items,
        tags: core.tags.into_iter().map(map_tag).collect(),
        created_at: core.created_at,
        updated_at: core.updated_at,
    }
}

// --- Short Tasks ---
pub fn map_short_task_item(core: notecore::models::tasks::ui_short_tasks::UIShortTaskItem) -> RShortTaskItem {
    RShortTaskItem {
        id: core.id,
        section_id: core.section_id,
        text: core.text,
        done: core.done,
    }
}

pub fn map_short_task_section(core: notecore::models::tasks::ui_short_tasks::UIShortTaskSection) -> RShortTaskSection {
    RShortTaskSection {
        id: core.id,
        title: core.title,
        listed_items: core.listed_items,
        tags: core.tags.into_iter().map(map_tag).collect(),
        items: core.items.into_iter().map(map_short_task_item).collect(),
        created_at: core.created_at,
        updated_at: core.updated_at,
    }
}

// --- Tasks ---
pub fn map_task(core: notecore::models::tasks::ui_task::UITask) -> RTask {
    RTask {
        id: core.id,
        title: core.title,
        description: core.description,
        task_type: core.task_type.into(),
        done: core.done,
        created_at: core.created_at,
        updated_at: core.updated_at,
        options: core.options.into(),
        tags: core.tags.into_iter().map(map_tag).collect(),
    }
}
// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'NoteCore';

  @override
  String get shell_navBar_note_view => 'Notes';

  @override
  String get shell_navBar_thought_view => 'Thoughts';

  @override
  String get shell_navBar_task_view => 'Tasks';

  @override
  String get shell_navBar_checklist_view => 'Checklists';

  @override
  String get general_filters => 'Filters';

  @override
  String get notes_all => 'All';

  @override
  String get notes_delete => 'Delete';

  @override
  String get notes_change_group => 'Change Group';

  @override
  String get notes_select_group => 'Move to Group';

  @override
  String get notes_empty => 'No notes found';

  @override
  String get notes_unassigned => 'Unassigned';

  @override
  String notes_selected_count(int count) {
    return '$count selected';
  }

  @override
  String get notes_search_hint => 'Search notes';

  @override
  String get notes_no_results => 'No matching notes';

  @override
  String get notes_untitled => 'Untitled';

  @override
  String get notes_new_note => 'New note';

  @override
  String get notes_clear_selection => 'Cancel selection';

  @override
  String get notes_clear_filters => 'Clear';

  @override
  String get notes_created_after => 'Created after';

  @override
  String get notes_created_before => 'Created before';

  @override
  String get notes_tags => 'Tags';

  @override
  String get notes_tags_empty => 'No tags yet';

  @override
  String get notes_new_tag => 'New tag';

  @override
  String get notes_add_tag => 'Add tag';

  @override
  String get notes_manage_groups => 'Manage groups';

  @override
  String get notes_new_group => 'New group';

  @override
  String get notes_rename_group => 'Rename group';

  @override
  String get notes_group_name => 'Group name';

  @override
  String get notes_groups_empty => 'No groups yet';

  @override
  String notes_count(int count) {
    return '$count notes';
  }

  @override
  String get notes_cancel => 'Cancel';

  @override
  String get notes_save => 'Save';

  @override
  String get notes_create => 'Create';

  @override
  String get notes_done => 'Done';

  @override
  String get notes_delete_notes_title => 'Delete notes?';

  @override
  String notes_delete_notes_body(int count) {
    return '$count selected notes will be permanently deleted.';
  }

  @override
  String get notes_delete_group_title => 'Delete group?';

  @override
  String notes_delete_group_body(String name) {
    return '“$name” will be deleted. A group that still contains notes can\'t be deleted.';
  }

  @override
  String get notes_delete_tag_title => 'Delete tag?';

  @override
  String notes_delete_tag_body(String name) {
    return '“$name” will be removed from all notes.';
  }

  @override
  String get note_title_hint => 'Title';

  @override
  String get note_content_hint => 'Start writing…';

  @override
  String get note_saved => 'Saved';

  @override
  String get note_saving => 'Saving…';

  @override
  String get note_unsaved => 'Unsaved';

  @override
  String get note_save_failed => 'Not saved';

  @override
  String get note_leave_failed =>
      'Couldn\'t save your changes. Go back again to leave without saving.';

  @override
  String get note_load_failed => 'Couldn\'t load this note';

  @override
  String get note_share => 'Share';

  @override
  String get note_delete_title => 'Delete note?';

  @override
  String get note_delete_body => 'This note will be permanently deleted.';

  @override
  String get note_undo => 'Undo';

  @override
  String get note_redo => 'Redo';

  @override
  String get note_heading => 'Heading';

  @override
  String get note_bullet_list => 'Bullet list';

  @override
  String get note_checklist => 'Checklist';

  @override
  String get note_indent => 'Indent';

  @override
  String get note_outdent => 'Outdent';

  @override
  String get thoughts_search_hint => 'Search thoughts';

  @override
  String get thoughts_empty => 'No thoughts yet';

  @override
  String get thoughts_new_section => 'New section';

  @override
  String get thoughts_section_name => 'Section name';

  @override
  String get thoughts_rename_section => 'Rename section';

  @override
  String thoughts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thoughts',
      one: '1 thought',
      zero: 'No thoughts',
    );
    return '$_temp0';
  }

  @override
  String thoughts_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete sections?',
      one: 'Delete section?',
    );
    return '$_temp0';
  }

  @override
  String thoughts_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count sections and all their thoughts will be permanently deleted.',
      one: 'This section and all its thoughts will be permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String get thoughts_new_item_hint => 'Add a thought…';

  @override
  String get thoughts_add => 'Add';

  @override
  String get thoughts_grid_view => 'Grid view';

  @override
  String get thoughts_list_view => 'List view';

  @override
  String get thoughts_load_failed => 'Couldn\'t load this section';

  @override
  String get thoughts_section_empty =>
      'Nothing here yet. Add your first thought below.';

  @override
  String get checklists_search_hint => 'Search checklists';

  @override
  String get checklists_empty => 'No checklists yet';

  @override
  String get checklists_all_done => 'All done! Nothing left to do';

  @override
  String get checklists_new_section => 'New checklist';

  @override
  String get checklists_section_name => 'Checklist name';

  @override
  String get checklists_rename_section => 'Rename checklist';

  @override
  String get checklists_show_completed => 'Show completed';

  @override
  String checklists_delete_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete checklists?',
      one: 'Delete checklist?',
    );
    return '$_temp0';
  }

  @override
  String checklists_delete_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count checklists and all their tasks will be permanently deleted.',
      one: 'This checklist and all its tasks will be permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String get checklists_new_item_hint => 'Add a task…';

  @override
  String get checklists_add => 'Add';

  @override
  String get checklists_load_failed => 'Couldn\'t load this checklist';

  @override
  String get checklists_section_empty =>
      'No tasks yet. Add your first task below.';

  @override
  String get checklists_no_tasks => 'No tasks yet';

  @override
  String get checklists_edit_tasks => 'Edit checklist';
}

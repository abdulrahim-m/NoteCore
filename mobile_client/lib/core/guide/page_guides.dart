import 'package:flutter/material.dart';
import 'package:mobile_client/core/guide/guide_overlay.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Scope ids of the tabs, in bottom-navigation order. The router wraps each
/// tab page in a `GuideScope` with the matching id.
const guideScopes = ['notes', 'thoughts', 'tasks', 'checklists'];

/// Starts the guide of the tab at [tabIndex] (the `?` button of the top bar).
void startGuideForTab(BuildContext context, int tabIndex) {
  final scope = guideScopes[tabIndex];
  showGuide(
    context,
    scope: scope,
    steps: guideSteps(scope, AppLocalizations.of(context)!),
  );
}

/// The steps of a page. To change a guide, edit its list, targets are the ids
/// used by `GuideTarget` (search, filters, create, item, list + page specific).
/// A step without a target (or whose target is not visible) is centered.
List<GuideStep> guideSteps(String scope, AppLocalizations l) {
  final search = GuideStep(
    target: 'search',
    icon: Icons.search,
    title: l.guide_search_title,
    body: l.guide_search_body,
  );
  final filters = GuideStep(
    target: 'filters',
    icon: Icons.filter_list,
    title: l.guide_filters_title,
    body: l.guide_filters_body,
  );
  GuideStep create(String title, String body) => GuideStep(
    target: 'create',
    icon: Icons.add,
    title: title,
    body: body,
  );
  GuideStep list(String title, String body) => GuideStep(
    target: 'item', // the first row, the whole list when it is empty
    fallback: 'list',
    icon: Icons.touch_app_outlined,
    title: title,
    body: '$body ${l.guide_refresh}',
  );
  GuideStep select(String title, String body) => GuideStep(
    icon: Icons.check_circle_outline,
    title: title,
    body: body,
  );

  return switch (scope) {
    'notes' => [
      GuideStep(
        icon: Icons.sticky_note_2_outlined,
        title: l.guide_notes_intro_title,
        body: l.guide_notes_intro_body,
      ),
      create(l.guide_notes_create_title, l.guide_notes_create_body),
      search,
      filters,
      GuideStep(
        target: 'groups',
        icon: Icons.folder_copy_outlined,
        title: l.guide_notes_groups_title,
        body: l.guide_notes_groups_body,
      ),
      GuideStep(
        target: 'manage-groups',
        icon: Icons.edit_note,
        title: l.guide_notes_manage_title,
        body: l.guide_notes_manage_body,
      ),
      list(l.guide_notes_list_title, l.guide_notes_list_body),
      select(l.guide_notes_select_title, l.guide_notes_select_body),
    ],
    'thoughts' => [
      GuideStep(
        icon: Icons.lightbulb_outline,
        title: l.guide_thoughts_intro_title,
        body: l.guide_thoughts_intro_body,
      ),
      create(l.guide_thoughts_create_title, l.guide_thoughts_create_body),
      search,
      filters,
      GuideStep(
        target: 'view',
        icon: Icons.grid_view,
        title: l.guide_thoughts_view_title,
        body: l.guide_thoughts_view_body,
      ),
      list(l.guide_thoughts_list_title, l.guide_thoughts_list_body),
      select(l.guide_thoughts_select_title, l.guide_thoughts_select_body),
    ],
    'tasks' => [
      GuideStep(
        icon: Icons.task_alt,
        title: l.guide_tasks_intro_title,
        body: l.guide_tasks_intro_body,
      ),
      create(l.guide_tasks_create_title, l.guide_tasks_create_body),
      search,
      GuideStep(
        target: 'filters',
        icon: Icons.filter_list,
        title: l.guide_filters_title,
        body: l.guide_tasks_filters_body,
      ),
      GuideStep(
        target: 'status',
        icon: Icons.published_with_changes,
        title: l.guide_tasks_views_title,
        body: l.guide_tasks_views_body,
      ),
      GuideStep(
        target: 'kind',
        icon: Icons.repeat,
        title: l.guide_tasks_kind_title,
        body: l.guide_tasks_kind_body,
      ),
      GuideStep(
        target: 'upcoming',
        icon: Icons.upcoming_outlined,
        title: l.guide_tasks_upcoming_title,
        body: l.guide_tasks_upcoming_body,
      ),
      list(l.guide_tasks_list_title, l.guide_tasks_list_body),
      select(l.guide_tasks_select_title, l.guide_tasks_select_body),
    ],
    'checklists' => [
      GuideStep(
        icon: Icons.checklist,
        title: l.guide_checklists_intro_title,
        body: l.guide_checklists_intro_body,
      ),
      create(l.guide_checklists_create_title, l.guide_checklists_create_body),
      search,
      filters,
      GuideStep(
        target: 'completed',
        icon: Icons.visibility_outlined,
        title: l.guide_checklists_completed_title,
        body: l.guide_checklists_completed_body,
      ),
      list(l.guide_checklists_list_title, l.guide_checklists_list_body),
      select(l.guide_checklists_select_title, l.guide_checklists_select_body),
    ],
    _ => const [],
  };
}

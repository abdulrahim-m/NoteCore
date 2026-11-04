import 'package:flutter/material.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/controllers/section_list_controller.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';
import 'package:mobile_client/shared/views/searchable_list_page.dart';
import 'package:mobile_client/shared/widgets/search_filters.dart';
import 'package:mobile_client/shared/widgets/section_selection_actions.dart';

/// [SearchableListPage] for sections. Creating asks for
/// a name then opens the new section, selection adds rename.
class SectionListPage<C extends SectionListController<T>, T>
    extends StatelessWidget {
  const SectionListPage({
    super.key,
    required this.create,
    required this.routeOf,
    required this.slivers,
    required this.visibleCount,
    required this.emptyText,
    required this.emptyIcon,
    required this.searchHint,
    required this.newTitle,
    required this.nameHint,
    required this.renameTitle,
    required this.deleteTitle,
    required this.deleteBody,
    this.toolbar,
  });

  final C Function(SearchFilters filters) create;
  final String Function(int id) routeOf;
  final List<Widget> Function(
    BuildContext context,
    C controller,
    Future<void> Function(int id) open,
  )
  slivers;
  final int Function(C controller) visibleCount;
  final String Function(C controller) emptyText;
  final IconData emptyIcon;
  final Widget Function(BuildContext context, C controller)? toolbar;

  final String searchHint;
  final String newTitle;
  final String nameHint;
  final String renameTitle;
  final String Function(int count) deleteTitle;
  final String Function(int count) deleteBody;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SearchableListPage<C, T>(
      create: create,
      routeOf: routeOf,
      slivers: slivers,
      visibleCount: visibleCount,
      emptyText: emptyText,
      emptyIcon: emptyIcon,
      searchHint: searchHint,
      toolbar: toolbar,
      createTooltip: newTitle,
      selectionActions: (context, c) => buildSectionSelectionActions<T>(
        context,
        controller: c,
        renameTitle: renameTitle,
        nameHint: nameHint,
        deleteTitle: deleteTitle,
        deleteBody: deleteBody,
      ),
      onCreate: (context, c, open) async {
        final name = await showTextInputDialog(
          context,
          title: newTitle,
          hint: nameHint,
          confirmLabel: l10n.notes_create,
        );
        if (name == null) return;
        final id = await c.createSection(name);
        if (id != null && context.mounted) await open(id);
      },
    );
  }
}

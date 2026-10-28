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
}

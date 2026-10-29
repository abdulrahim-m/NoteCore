import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'NoteCore'**
  String get app_title;

  /// No description provided for @shell_navBar_note_view.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get shell_navBar_note_view;

  /// No description provided for @shell_navBar_thought_view.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get shell_navBar_thought_view;

  /// No description provided for @shell_navBar_task_view.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get shell_navBar_task_view;

  /// No description provided for @shell_navBar_checklist_view.
  ///
  /// In en, this message translates to:
  /// **'Checklists'**
  String get shell_navBar_checklist_view;

  /// No description provided for @notes_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notes_all;

  /// No description provided for @notes_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notes_delete;

  /// No description provided for @notes_change_group.
  ///
  /// In en, this message translates to:
  /// **'Change Group'**
  String get notes_change_group;

  /// No description provided for @notes_select_group.
  ///
  /// In en, this message translates to:
  /// **'Move to Group'**
  String get notes_select_group;

  /// No description provided for @notes_empty.
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get notes_empty;

  /// No description provided for @notes_unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get notes_unassigned;

  /// No description provided for @notes_selected_count.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String notes_selected_count(int count);

  /// No description provided for @notes_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notes_search_hint;

  /// No description provided for @notes_no_results.
  ///
  /// In en, this message translates to:
  /// **'No matching notes'**
  String get notes_no_results;

  /// No description provided for @notes_untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get notes_untitled;

  /// No description provided for @notes_new_note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notes_new_note;

  /// No description provided for @notes_clear_selection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get notes_clear_selection;

  /// No description provided for @notes_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get notes_filters;

  /// No description provided for @notes_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get notes_clear_filters;

  /// No description provided for @notes_created_after.
  ///
  /// In en, this message translates to:
  /// **'Created after'**
  String get notes_created_after;

  /// No description provided for @notes_created_before.
  ///
  /// In en, this message translates to:
  /// **'Created before'**
  String get notes_created_before;

  /// No description provided for @notes_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get notes_tags;

  /// No description provided for @notes_tags_empty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get notes_tags_empty;

  /// No description provided for @notes_new_tag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get notes_new_tag;

  /// No description provided for @notes_add_tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get notes_add_tag;

  /// No description provided for @notes_manage_groups.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get notes_manage_groups;

  /// No description provided for @notes_new_group.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get notes_new_group;

  /// No description provided for @notes_rename_group.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get notes_rename_group;

  /// No description provided for @notes_group_name.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get notes_group_name;

  /// No description provided for @notes_groups_empty.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get notes_groups_empty;

  /// No description provided for @notes_count.
  ///
  /// In en, this message translates to:
  /// **'{count} notes'**
  String notes_count(int count);

  /// No description provided for @notes_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get notes_cancel;

  /// No description provided for @notes_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get notes_save;

  /// No description provided for @notes_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get notes_create;

  /// No description provided for @notes_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notes_done;

  /// No description provided for @notes_delete_notes_title.
  ///
  /// In en, this message translates to:
  /// **'Delete notes?'**
  String get notes_delete_notes_title;

  /// No description provided for @notes_delete_notes_body.
  ///
  /// In en, this message translates to:
  /// **'{count} selected notes will be permanently deleted.'**
  String notes_delete_notes_body(int count);

  /// No description provided for @notes_delete_group_title.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get notes_delete_group_title;

  /// No description provided for @notes_delete_group_body.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be deleted. A group that still contains notes can\'t be deleted.'**
  String notes_delete_group_body(String name);

  /// No description provided for @notes_delete_tag_title.
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get notes_delete_tag_title;

  /// No description provided for @notes_delete_tag_body.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed from all notes.'**
  String notes_delete_tag_body(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

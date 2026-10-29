// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_title => 'NoteCore';

  @override
  String get shell_navBar_note_view => 'ملاحظات';

  @override
  String get shell_navBar_thought_view => 'أفكار';

  @override
  String get shell_navBar_task_view => 'مهام';

  @override
  String get shell_navBar_checklist_view => 'القوائم';

  @override
  String get notes_all => 'الكل';

  @override
  String get notes_delete => 'حذف';

  @override
  String get notes_change_group => 'تغيير المجموعة';

  @override
  String get notes_select_group => 'نقل إلى مجموعة';

  @override
  String get notes_empty => 'لا توجد ملاحظات';

  @override
  String get notes_unassigned => 'بدون مجموعة';

  @override
  String notes_selected_count(int count) {
    return 'تم تحديد $count';
  }

  @override
  String get notes_search_hint => 'ابحث في الملاحظات';

  @override
  String get notes_no_results => 'لا توجد ملاحظات مطابقة';

  @override
  String get notes_untitled => 'بدون عنوان';

  @override
  String get notes_new_note => 'ملاحظة جديدة';

  @override
  String get notes_clear_selection => 'إلغاء التحديد';

  @override
  String get notes_filters => 'التصفية';

  @override
  String get notes_clear_filters => 'مسح';

  @override
  String get notes_created_after => 'أُنشئت بعد';

  @override
  String get notes_created_before => 'أُنشئت قبل';

  @override
  String get notes_tags => 'الوسوم';

  @override
  String get notes_tags_empty => 'لا توجد وسوم بعد';

  @override
  String get notes_new_tag => 'وسم جديد';

  @override
  String get notes_add_tag => 'إضافة وسم';

  @override
  String get notes_manage_groups => 'إدارة المجموعات';

  @override
  String get notes_new_group => 'مجموعة جديدة';

  @override
  String get notes_rename_group => 'إعادة تسمية المجموعة';

  @override
  String get notes_group_name => 'اسم المجموعة';

  @override
  String get notes_groups_empty => 'لا توجد مجموعات بعد';

  @override
  String notes_count(int count) {
    return '$count ملاحظات';
  }

  @override
  String get notes_cancel => 'إلغاء';

  @override
  String get notes_save => 'حفظ';

  @override
  String get notes_create => 'إنشاء';

  @override
  String get notes_done => 'تم';

  @override
  String get notes_delete_notes_title => 'حذف الملاحظات؟';

  @override
  String notes_delete_notes_body(int count) {
    return 'سيتم حذف $count من الملاحظات المحددة نهائيًا.';
  }

  @override
  String get notes_delete_group_title => 'حذف المجموعة؟';

  @override
  String notes_delete_group_body(String name) {
    return 'سيتم حذف «$name». لا يمكن حذف مجموعة ما زالت تحتوي على ملاحظات.';
  }

  @override
  String get notes_delete_tag_title => 'حذف الوسم؟';

  @override
  String notes_delete_tag_body(String name) {
    return 'ستتم إزالة «$name» من جميع الملاحظات.';
  }

  @override
  String get note_title_hint => 'العنوان';

  @override
  String get note_content_hint => 'ابدأ الكتابة…';

  @override
  String get note_saved => 'تم الحفظ';

  @override
  String get note_saving => 'جارٍ الحفظ…';

  @override
  String get note_unsaved => 'غير محفوظ';

  @override
  String get note_save_failed => 'لم يتم الحفظ';

  @override
  String get note_leave_failed =>
      'تعذّر حفظ تغييراتك. ارجع مرة أخرى للمغادرة دون حفظ.';

  @override
  String get note_load_failed => 'تعذّر تحميل هذه الملاحظة';

  @override
  String get note_share => 'مشاركة';

  @override
  String get note_delete_title => 'حذف الملاحظة؟';

  @override
  String get note_delete_body => 'سيتم حذف هذه الملاحظة نهائيًا.';

  @override
  String get note_undo => 'تراجع';

  @override
  String get note_redo => 'إعادة';

  @override
  String get note_heading => 'عنوان';

  @override
  String get note_bullet_list => 'قائمة نقطية';

  @override
  String get note_checklist => 'قائمة مهام';

  @override
  String get note_indent => 'زيادة المسافة البادئة';

  @override
  String get note_outdent => 'تقليل المسافة البادئة';
}

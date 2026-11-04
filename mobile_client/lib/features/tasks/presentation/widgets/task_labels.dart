import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/domain/task_schedule.dart';
import 'package:mobile_client/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

String priorityLabel(AppLocalizations l10n, PriorityDto p) => switch (p) {
  PriorityDto.lowest => l10n.tasks_priority_lowest,
  PriorityDto.low => l10n.tasks_priority_low,
  PriorityDto.medium => l10n.tasks_priority_medium,
  PriorityDto.high => l10n.tasks_priority_high,
  PriorityDto.highest => l10n.tasks_priority_highest,
};

Color priorityColor(ColorScheme cs, PriorityDto p) => switch (p) {
  PriorityDto.highest => cs.error,
  PriorityDto.high => Colors.deepOrange,
  PriorityDto.medium => cs.primary,
  PriorityDto.low || PriorityDto.lowest => cs.outline,
};

String timeLabel(BuildContext context, int hour) =>
    TimeOfDay(hour: hour, minute: 0).format(context);

String weekdayName(String locale, WeekdayDto d, {bool short = false}) =>
    DateFormat(short ? 'E' : 'EEEE', locale).format(
      DateTime(2024, 1, weekdayNumber(d)),
    );

String scheduleLabel(BuildContext context, ScheduleDto s) {
  final l10n = AppLocalizations.of(context)!;
  final loc = Localizations.localeOf(context).toString();
  return s.when(
    daily: (h) => l10n.tasks_sched_daily(timeLabel(context, h)),
    everyNDays: (n, h) => l10n.tasks_sched_every_n_days(n, timeLabel(context, h)),
    weekly: (days, h) {
      final sorted = [...days]..sort((a, b) => weekdayNumber(a) - weekdayNumber(b));
      if (sorted.length >= 7) return l10n.tasks_sched_daily(timeLabel(context, h));
      final names = sorted
          .map((d) => weekdayName(loc, d, short: sorted.length > 1))
          .join(loc.startsWith('ar') ? '، ' : ', ');
      return l10n.tasks_sched_weekly(names, timeLabel(context, h));
    },
    monthly: (d, h) => l10n.tasks_sched_monthly(d, timeLabel(context, h)),
    yearly: (m, d, h) => l10n.tasks_sched_yearly(
      DateFormat.MMMd(loc).format(DateTime(2024, m, d)),
      timeLabel(context, h),
    ),
  );
}

String whenLabel(BuildContext context, DateTime d, {required bool withTime}) {
  final loc = MaterialLocalizations.of(context);
  final date = loc.formatMediumDate(d);
  return withTime
      ? '$date · ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(d))}'
      : date;
}

String kindLabel(AppLocalizations l10n, TaskKind k) => switch (k) {
  TaskKind.all => l10n.tasks_all_types,
  TaskKind.oneTime => l10n.tasks_type_one_time,
  TaskKind.periodic => l10n.tasks_type_periodic,
};

IconData kindIcon(TaskKind k) => switch (k) {
  TaskKind.all => Icons.apps,
  TaskKind.oneTime => Icons.task_alt,
  TaskKind.periodic => Icons.repeat,
};

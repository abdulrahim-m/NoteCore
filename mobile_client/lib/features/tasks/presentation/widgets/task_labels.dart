import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
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

String scheduleLabel(BuildContext context, ScheduleDto s) {
  final l10n = AppLocalizations.of(context)!;
  final loc = Localizations.localeOf(context).toString();
  return s.when(
    daily: (h) => l10n.tasks_sched_daily(timeLabel(context, h)),
    everyNDays: (n, h) => l10n.tasks_sched_every_n_days(n, timeLabel(context, h)),
    weekly: (d, h) => l10n.tasks_sched_weekly(
      DateFormat.EEEE(loc).format(DateTime(2024, 1, d)),
      timeLabel(context, h),
    ),
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

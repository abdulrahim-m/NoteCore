import 'dart:math' as math;

import 'package:mobile_client/core/rust/dto/task.dart';

/// Due date of a one-time task. The core stores it as a string, both a plain
/// date (`2026-11-03`) and a full ISO date-time are understood.
DateTime? parseDue(String? value) =>
    value == null ? null : DateTime.tryParse(value);

/// True when the stored due date also carries a time of day.
bool dueHasTime(String? value) => value != null && value.length > 10;

String formatDue(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

bool isOverdue(TaskDto t, DateTime now) {
  if (t.done || t.taskType != TaskTypeDto.oneTime) return false;
  final d = parseDue(t.options.dueDate);
  if (d == null) return false;
  final end = dueHasTime(t.options.dueDate)
      ? d
      : DateTime(d.year, d.month, d.day + 1); // a date is due until its end
  return end.isBefore(now);
}

int _daysIn(int year, int month) => DateTime(year, month + 1, 0).day;

DateTime _at(int y, int m, int d, int hour) =>
    DateTime(y, m, math.min(d, _daysIn(y, m)), hour);

/// Next time the task needs attention: its due date (one-time) or the next
/// occurrence of its schedule after [now] (periodic).
DateTime? nextOccurrence(TaskDto t, DateTime now) {
  if (t.taskType == TaskTypeDto.oneTime) return parseDue(t.options.dueDate);
  final s = t.options.schedule;
  if (s == null) return null;

  return s.when(
    daily: (h) {
      final today = DateTime(now.year, now.month, now.day, h);
      return today.isAfter(now)
          ? today
          : DateTime(now.year, now.month, now.day + 1, h);
    },
    everyNDays: (days, h) {
      final step = math.max(1, days);
      final c = t.createdAt.toLocal();
      final elapsed = DateTime(
        now.year,
        now.month,
        now.day,
      ).difference(DateTime(c.year, c.month, c.day)).inDays;
      var n = elapsed > 0 ? elapsed ~/ step : 0;
      var cand = DateTime(c.year, c.month, c.day + n * step, h);
      while (!cand.isAfter(now)) {
        n++;
        cand = DateTime(c.year, c.month, c.day + n * step, h);
      }
      return cand;
    },
    weekly: (dow, h) {
      final target = dow == 0 ? 7 : dow;
      final delta = (target - now.weekday) % 7;
      final cand = DateTime(now.year, now.month, now.day + delta, h);
      return cand.isAfter(now)
          ? cand
          : DateTime(now.year, now.month, now.day + delta + 7, h);
    },
    monthly: (dom, h) {
      final cand = _at(now.year, now.month, dom, h);
      return cand.isAfter(now)
          ? cand
          : DateTime(
              now.year,
              now.month + 1,
              math.min(dom, _daysIn(now.year, now.month + 1)),
              h,
            );
    },
    yearly: (month, dom, h) {
      final cand = _at(now.year, month, dom, h);
      return cand.isAfter(now) ? cand : _at(now.year + 1, month, dom, h);
    },
  );
}

typedef UpcomingEntry = ({TaskDto task, DateTime when});

/// The unfinished tasks that come up soonest.
List<UpcomingEntry> upcomingOf(
  Iterable<TaskDto> tasks,
  DateTime now, {
  int limit = 10,
}) {
  final out = <UpcomingEntry>[];
  for (final t in tasks) {
    if (t.done) continue;
    final when = nextOccurrence(t, now);
    if (when != null) out.add((task: t, when: when));
  }
  out.sort((a, b) => a.when.compareTo(b.when));
  return out.take(limit).toList();
}

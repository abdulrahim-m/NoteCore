import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/core/rust/dto/task.dart';
import 'package:mobile_client/features/tasks/presentation/widgets/task_labels.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ScheduleDto value;
  final ValueChanged<ScheduleDto> onChanged;

  static ScheduleDto _make(int kind, int hour) => switch (kind) {
    0 => ScheduleDto.daily(hour: hour),
    1 => ScheduleDto.everyNDays(days: 2, hour: hour),
    2 => ScheduleDto.weekly(dayOfWeek: 1, hour: hour),
    3 => ScheduleDto.monthly(dayOfMonth: 1, hour: hour),
    _ => ScheduleDto.yearly(month: 1, dayOfMonth: 1, hour: hour),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = Localizations.localeOf(context).toString();
    final s = value;
    final kind = s.map(
      daily: (_) => 0,
      everyNDays: (_) => 1,
      weekly: (_) => 2,
      monthly: (_) => 3,
      yearly: (_) => 4,
    );

    final kinds = [
      l10n.tasks_kind_daily,
      l10n.tasks_kind_every_n_days,
      l10n.tasks_kind_weekly,
      l10n.tasks_kind_monthly,
      l10n.tasks_kind_yearly,
    ];

    final fields = <Widget>[
      _IntField(
        label: l10n.tasks_field_repeats,
        value: kind,
        options: const [0, 1, 2, 3, 4],
        text: (i) => kinds[i],
        onChanged: (i) => onChanged(_make(i, s.hour)),
        width: 190,
      ),
      ...s.when(
        daily: (_) => const <Widget>[],
        everyNDays: (days, h) => [
          _IntField(
            label: l10n.tasks_field_days,
            value: days,
            options: List.generate(29, (i) => i + 2),
            text: (d) => '$d',
            onChanged: (d) =>
                onChanged(ScheduleDto.everyNDays(days: d, hour: h)),
          ),
        ],
        weekly: (dow, h) => [
          _IntField(
            label: l10n.tasks_field_day_of_week,
            value: dow,
            options: List.generate(7, (i) => i + 1),
            text: (d) => DateFormat.EEEE(loc).format(DateTime(2024, 1, d)),
            onChanged: (d) =>
                onChanged(ScheduleDto.weekly(dayOfWeek: d, hour: h)),
            width: 160,
          ),
        ],
        monthly: (dom, h) => [
          _IntField(
            label: l10n.tasks_field_day_of_month,
            value: dom,
            options: List.generate(31, (i) => i + 1),
            text: (d) => '$d',
            onChanged: (d) =>
                onChanged(ScheduleDto.monthly(dayOfMonth: d, hour: h)),
          ),
        ],
        yearly: (m, dom, h) => [
          _IntField(
            label: l10n.tasks_field_month,
            value: m,
            options: List.generate(12, (i) => i + 1),
            text: (v) => DateFormat.MMMM(loc).format(DateTime(2024, v)),
            onChanged: (v) => onChanged(
              ScheduleDto.yearly(month: v, dayOfMonth: dom, hour: h),
            ),
            width: 160,
          ),
          _IntField(
            label: l10n.tasks_field_day_of_month,
            value: dom,
            options: List.generate(31, (i) => i + 1),
            text: (d) => '$d',
            onChanged: (d) => onChanged(
              ScheduleDto.yearly(month: m, dayOfMonth: d, hour: h),
            ),
          ),
        ],
      ),
      _IntField(
        label: l10n.tasks_field_hour,
        value: s.hour,
        options: List.generate(24, (i) => i),
        text: (h) => timeLabel(context, h),
        onChanged: (h) => onChanged(s.copyWith(hour: h)),
        width: 130,
      ),
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: fields);
  }
}

class _IntField extends StatelessWidget {
  const _IntField({
    required this.label,
    required this.value,
    required this.options,
    required this.text,
    required this.onChanged,
    this.width = 110,
  });

  final String label;
  final int value;
  final List<int> options;
  final String Function(int) text;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    final all = {...options, value}.toList()..sort();
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, isDense: true),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isDense: true,
            isExpanded: true,
            value: value,
            items: [
              for (final o in all)
                DropdownMenuItem(value: o, child: Text(text(o))),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/settings/app_settings.dart';
import 'package:mobile_client/core/settings/settings_controller.dart';

/// A setting picked from a fixed list: shows the current choice, tap opens a
/// dialog with the options. Works for any [Setting] of any type.
class ChoiceSettingTile<T> extends StatelessWidget {
  const ChoiceSettingTile({
    super.key,
    required this.setting,
    required this.title,
    required this.options,
    required this.labelOf,
    this.icon,
    this.hint,
  });

  final Setting<T> setting;
  final String title;
  final List<T> options;
  final String Function(BuildContext context, T value) labelOf;
  final IconData? icon;
  final String? hint;

  Future<void> _pick(BuildContext context, SettingsController settings) async {
    final current = settings.get(setting);
    final picked = await showDialog<T>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          for (final o in options)
            ListTile(
              title: Text(labelOf(ctx, o)),
              trailing: o == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(ctx, o),
            ),
        ],
      ),
    );
    if (picked != null) await settings.set(setting, picked);
  }

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsController>();
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: hint == null ? null : Text(hint!),
      trailing: Text(
        labelOf(context, settings.get(setting)),
        style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
      ),
      onTap: () => _pick(context, settings),
    );
  }
}

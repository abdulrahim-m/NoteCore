import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/settings/app_settings.dart';
import 'package:mobile_client/core/settings/settings_controller.dart';
import 'package:mobile_client/core/theme/themes/theme_registry.dart';
import 'package:mobile_client/features/settings/presentation/widgets/theme_preview.dart';

/// Pick the app theme from small previews. Lists every entry of
/// [appThemeOptions].
class ThemeSettingTile extends StatelessWidget {
  const ThemeSettingTile({super.key, required this.setting, required this.title});

  final Setting<String> setting;
  final String title;

  @override
  Widget build(BuildContext context) {
    final settings = getIt<SettingsController>();
    final selectedId = themeById(settings.get(setting)).id;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined),
              const SizedBox(width: 16),
              Text(title, style: theme.textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final o in appThemeOptions)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => settings.set(setting, o.id),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      children: [
                        ThemePreview(colors: o.colors, selected: o.id == selectedId),
                        const SizedBox(height: 6),
                        Text(
                          o.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: o.id == selectedId
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_client/core/di/injection.dart';
import 'package:mobile_client/core/settings/app_settings.dart';
import 'package:mobile_client/core/settings/settings_controller.dart';

/// A whole-number setting on a slider. The value is saved when the finger
/// lifts (so the app does not save while dragging); [previewText] shows
/// at the chosen size meanwhile.
class SliderSettingTile extends StatefulWidget {
  const SliderSettingTile({
    super.key,
    required this.setting,
    required this.title,
    required this.min,
    required this.max,
    this.icon,
    this.previewText,
  });

  final Setting<int> setting;
  final String title;
  final int min;
  final int max;
  final IconData? icon;

  final String? previewText;

  @override
  State<SliderSettingTile> createState() => _SliderSettingTileState();
}

class _SliderSettingTileState extends State<SliderSettingTile> {
  final _settings = getIt<SettingsController>();
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final saved = _settings.get(widget.setting);
    final value = (_drag ?? saved.toDouble()).clamp(
      widget.min.toDouble(),
      widget.max.toDouble(),
    );
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                '${value.round()}',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.max - widget.min,
            value: value,
            label: '${value.round()}',
            onChanged: (v) => setState(() => _drag = v),
            onChangeEnd: (v) async {
              await _settings.set(widget.setting, v.round());
              if (mounted) setState(() => _drag = null);
            },
          ),
          if (widget.previewText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.previewText!,
                textScaler: TextScaler.noScaling,
                style: TextStyle(fontSize: value, color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

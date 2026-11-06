import 'package:flutter/material.dart';
import 'package:mobile_client/core/theme/themes/base.dart';

/// A tiny mock of the app drawn with a theme's colors (in the brightness the
/// app is currently using): background, top bar, a card with text lines and
/// a primary button.
class ThemePreview extends StatelessWidget {
  const ThemePreview({
    super.key,
    required this.colors,
    required this.selected,
    this.width = 92,
    this.height = 68,
  });

  final AppColors colors;
  final bool selected;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? c.darkBackground : c.lightBackground;
    final surface = dark ? c.darkSurface : c.lightSurface;
    final border = dark ? c.darkBorder : c.lightBorder;
    final text = dark ? c.darkTextPrimary : c.lightTextPrimary;
    final textSub = dark ? c.darkTextSecondary : c.lightTextSecondary;

    Widget bar(Color color, double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(h),
      ),
    );

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: selected ? c.primary : border,
          width: selected ? 2.5 : 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // top bar
              Container(
                height: 14,
                color: surface,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: AlignmentDirectional.centerStart,
                child: bar(c.primary, 24, 4),
              ),
              // a card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bar(text, 36, 4),
                        const SizedBox(height: 3),
                        bar(textSub, 54, 3),
                        const Spacer(),
                        bar(c.primary, 24, 7),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selected)
            PositionedDirectional(
              top: 1,
              end: 1,
              child: Icon(Icons.check_circle, size: 14, color: c.primary),
            ),
        ],
      ),
    );
  }
}

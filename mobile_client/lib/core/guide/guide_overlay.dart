import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_client/core/guide/guide_target.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// One step of a page guide. The widget registered as [target] (or, when it is
/// not on screen, [fallback]) is spotlighted, without either, the explanation
/// is shown in the middle of the screen.
class GuideStep {
  const GuideStep({
    this.target,
    this.fallback,
    required this.title,
    required this.body,
    this.icon = Icons.lightbulb_outline,
  });

  final String? target;
  final String? fallback;
  final String title;
  final String body;
  final IconData icon;
}

/// Runs [steps] as a spotlight tour over the whole app.
void showGuide(
  BuildContext context, {
  required String scope,
  required List<GuideStep> steps,
}) {
  if (steps.isEmpty) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  final l10n = AppLocalizations.of(context)!;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _GuideLayer(
      scope: scope,
      steps: steps,
      l10n: l10n,
      onClose: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _GuideLayer extends StatefulWidget {
  const _GuideLayer({
    required this.scope,
    required this.steps,
    required this.l10n,
    required this.onClose,
  });

  final String scope;
  final List<GuideStep> steps;
  final AppLocalizations l10n;
  final VoidCallback onClose;

  @override
  State<_GuideLayer> createState() => _GuideLayerState();
}

class _GuideLayerState extends State<_GuideLayer>
    with TickerProviderStateMixin {
  // The spotlight glides from one target to the next.
  late final _move = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  // A soft ring that keeps pulsing around the target.
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat();

  int _i = 0;
  Rect? _from;
  Rect? _to;
  bool _busy = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _go(0));
  }

  @override
  void dispose() {
    _move.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    widget.onClose();
  }

  // ------------------------------------------------------------- targets
  BuildContext? _contextOf(GuideStep step) {
    for (final id in [step.target, step.fallback]) {
      if (id == null) continue;
      final ctx = GuideRegistry.find(widget.scope, id)?.currentContext;
      final ro = ctx?.findRenderObject();
      if (ro is RenderBox && ro.attached && ro.hasSize) return ctx;
    }
    return null;
  }

  Rect? _measure(BuildContext? ctx, Size screen) {
    final ro = ctx?.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
    final rect = (ro.localToGlobal(Offset.zero) & ro.size)
        .inflate(8)
        .intersect(Offset.zero & screen);
    return rect.isEmpty ? null : rect;
  }

  /// Where the spotlight is right now (mid-glide included).
  Rect? get _holeNow {
    final to = _to;
    if (to == null) return null;
    final t = Curves.easeInOutCubic.transform(_move.value);
    final from =
        _from ?? Rect.fromCenter(center: to.center, width: 0, height: 0);
    return Rect.lerp(from, to, t);
  }

  Future<void> _go(int i) async {
    if (_busy || !mounted) return;
    _busy = true;
    final step = widget.steps[i];
    var ctx = _contextOf(step);
    if (ctx != null) {
      // Bring the target into view first (long lists, scrolled pages).
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
      if (!mounted) return;
      ctx = _contextOf(step);
    }
    final hole = _measure(ctx, MediaQuery.sizeOf(context));
    HapticFeedback.selectionClick();
    setState(() {
      _from = _holeNow;
      _to = hole;
      _i = i;
    });
    await _move.forward(from: 0);
    _busy = false;
  }

  void _next() {
    if (_i >= widget.steps.length - 1) {
      _close();
    } else {
      _go(_i + 1);
    }
  }

  void _back() {
    if (_i > 0) _go(_i - 1);
  }

  // --------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final cs = Theme.of(context).colorScheme;
    final step = widget.steps[_i];
    final hole = _to; // final position, for placing the card

    // Below the spotlight, else above it, else pinned to the bottom.
    double? top, bottom;
    if (hole == null) {
      top = 0;
      bottom = 0;
    } else if (mq.size.height - hole.bottom >= 250) {
      top = hole.bottom + 16;
    } else if (hole.top >= 250) {
      bottom = mq.size.height - hole.top + 16;
    } else {
      bottom = mq.padding.bottom + 24;
    }

    return BackButtonListener(
      onBackButtonPressed: () async {
        _close();
        return true;
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              // Swallows taps so the page below can't be used mid-tour.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: AnimatedBuilder(
                  animation: Listenable.merge([_move, _pulse]),
                  builder: (context, _) {
                    final h = _holeNow;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipPath(
                          clipper: _HoleClipper(h),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                            child: ColoredBox(
                              color: Colors.black.withValues(alpha: 0.74),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _RingPainter(
                              hole: h,
                              color: cs.primary,
                              pulse: _pulse.value,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: top,
              bottom: bottom,
              child: Align(
                alignment:
                    hole == null ? Alignment.center : Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: ConstrainedBox(
                    key: ValueKey(_i),
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _GuideCard(
                      step: step,
                      index: _i,
                      count: widget.steps.length,
                      l10n: widget.l10n,
                      onBack: _back,
                      onNext: _next,
                      onClose: _close,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- the card
class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.step,
    required this.index,
    required this.count,
    required this.l10n,
    required this.onBack,
    required this.onNext,
    required this.onClose,
  });

  final GuideStep step;
  final int index;
  final int count;
  final AppLocalizations l10n;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final last = index == count - 1;

    return Material(
      color: cs.surface,
      elevation: 12,
      shadowColor: cs.primary.withValues(alpha: 0.35),
      surfaceTintColor: cs.primary,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 8, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      step.icon,
                      size: 22,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.guide_skip,
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 10, end: 12),
              child: Text(
                step.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // progress: the current step is a longer pill
                Expanded(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (var i = 0; i < count; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: i == index ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == index
                                ? cs.primary
                                : i < index
                                ? cs.primary.withValues(alpha: 0.4)
                                : cs.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ),
                if (index > 0)
                  TextButton(onPressed: onBack, child: Text(l10n.guide_back)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilledButton.icon(
                    onPressed: onNext,
                    iconAlignment: IconAlignment.end,
                    icon: Icon(
                      last ? Icons.check : Icons.arrow_forward,
                      size: 18,
                    ),
                    label: Text(last ? l10n.guide_done : l10n.guide_next),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- the spotlight
RRect _spotlight(Rect hole) => RRect.fromRectAndRadius(
  hole,
  Radius.circular((hole.shortestSide / 2).clamp(0, 22).toDouble()),
);

class _HoleClipper extends CustomClipper<Path> {
  const _HoleClipper(this.hole);

  final Rect? hole;

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final h = hole;
    if (h == null) return full;
    return Path.combine(
      PathOperation.difference,
      full,
      Path()..addRRect(_spotlight(h)),
    );
  }

  @override
  bool shouldReclip(_HoleClipper old) => hole != old.hole;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.hole,
    required this.color,
    required this.pulse,
  });

  final Rect? hole;
  final Color color;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final h = hole;
    if (h == null || h.isEmpty) return;
    final r = _spotlight(h);

    // soft glow
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = color.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // crisp edge
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.95),
    );
    // expanding pulse
    canvas.drawRRect(
      r.inflate(pulse * 16),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: (1 - pulse) * 0.7),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      hole != old.hole || color != old.color || pulse != old.pulse;
}

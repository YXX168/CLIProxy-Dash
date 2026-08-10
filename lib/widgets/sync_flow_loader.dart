import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/visual_mode.dart';
import '../theme/app_theme.dart';

/// First-sync animation built as a layered data gateway.
class SyncFlowLoader extends StatefulWidget {
  const SyncFlowLoader({required this.visualMode, super.key});

  final VisualMode visualMode;

  @override
  State<SyncFlowLoader> createState() => _SyncFlowLoaderState();
}

class _SyncFlowLoaderState extends State<SyncFlowLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _animationsDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      _controller
        ..stop()
        ..value = 0.28;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energyMode = widget.visualMode == VisualMode.energy;
    final primary = energyMode ? AppTheme.violet : AppTheme.cyan;

    return Semantics(
      liveRegion: true,
      label: '正在同步账户状态，请稍候',
      child: SizedBox(
        key: Key(energyMode ? 'energy-sync-flow' : 'console-sync-flow'),
        height: 468,
        child: Column(
          children: [
            RepaintBoundary(
              key: const Key('sync-flow-field'),
              child: SizedBox(
                width: double.infinity,
                height: 330,
                child: CustomPaint(
                  painter: _DataGatewayPainter(
                    animation: _controller,
                    primary: primary,
                  ),
                ),
              ),
            ),
            Text(
              '正在同步账户状态',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFF2F7FF),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '建立安全连接  ·  聚合账户数据',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8290A6),
                fontSize: 11,
                letterSpacing: 0.75,
              ),
            ),
            const SizedBox(height: 22),
            _SignalSteps(animation: _controller, primary: primary),
          ],
        ),
      ),
    );
  }
}

class _DataGatewayPainter extends CustomPainter {
  _DataGatewayPainter({required this.animation, required this.primary})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 2);
    final unit = math.min(size.width, size.height) / 330;
    final phase = animation.value;
    final wave = (math.sin(phase * math.pi * 2) + 1) / 2;

    _drawAtmosphere(canvas, center, unit, wave);
    _drawPerspectiveGrid(canvas, size, center, unit);
    _drawOuterGate(canvas, center, unit, phase);
    _drawDataRails(canvas, center, unit, phase);
    _drawPrism(canvas, center, unit, phase, wave);
    _drawPackets(canvas, center, unit, phase);
  }

  void _drawAtmosphere(Canvas canvas, Offset center, double unit, double wave) {
    final radius = 150 * unit;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: 0.12 + wave * 0.025),
            AppTheme.violet.withValues(alpha: 0.045),
            Colors.transparent,
          ],
          stops: const [0, 0.46, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _drawPerspectiveGrid(
    Canvas canvas,
    Size size,
    Offset center,
    double unit,
  ) {
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7 * unit
      ..color = primary.withValues(alpha: 0.075);
    for (var i = -4; i <= 4; i++) {
      final offset = i * 26 * unit;
      canvas.drawLine(
        Offset(center.dx + offset * 0.34, center.dy - 104 * unit),
        Offset(center.dx + offset, center.dy + 112 * unit),
        grid,
      );
    }
    for (var i = 0; i < 6; i++) {
      final y = center.dy - 82 * unit + i * 35 * unit;
      final spread = 42 * unit + i * 22 * unit;
      canvas.drawLine(
        Offset(center.dx - spread, y),
        Offset(center.dx + spread, y),
        grid,
      );
    }
  }

  void _drawOuterGate(Canvas canvas, Offset center, double unit, double phase) {
    for (var i = 0; i < 3; i++) {
      final scale = 1 - i * 0.17;
      final alpha = 0.24 - i * 0.055;
      final gate = _hexagon(center, 116 * unit * scale, 82 * unit * scale);
      canvas.drawPath(
        gate,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.15 - i * 0.16) * unit
          ..color = primary.withValues(alpha: alpha),
      );
    }

    final scan = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * unit
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        transform: GradientRotation(phase * math.pi * 2),
        colors: [
          Colors.transparent,
          primary.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.9),
          primary,
          Colors.transparent,
        ],
        stops: const [0, 0.46, 0.54, 0.64, 1],
      ).createShader(Rect.fromCircle(center: center, radius: 116 * unit));
    canvas.drawPath(_hexagon(center, 116 * unit, 82 * unit), scan);
  }

  void _drawDataRails(Canvas canvas, Offset center, double unit, double phase) {
    final rail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * unit
      ..color = primary.withValues(alpha: 0.24);
    for (final direction in [-1.0, 1.0]) {
      for (var lane = -1; lane <= 1; lane++) {
        final path = Path()
          ..moveTo(
            center.dx + direction * 164 * unit,
            center.dy + lane * 28 * unit,
          )
          ..lineTo(
            center.dx + direction * 82 * unit,
            center.dy + lane * 18 * unit,
          )
          ..lineTo(
            center.dx + direction * 49 * unit,
            center.dy + lane * 12 * unit,
          );
        canvas.drawPath(path, rail);

        final t = (phase * (0.72 + lane.abs() * 0.12) + lane * 0.16) % 1;
        final metric = path.computeMetrics().first;
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent == null) continue;
        canvas.drawCircle(
          tangent.position,
          7 * unit,
          Paint()
            ..color = primary.withValues(alpha: 0.32)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * unit),
        );
        canvas.drawCircle(
          tangent.position,
          2.1 * unit,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  void _drawPrism(
    Canvas canvas,
    Offset center,
    double unit,
    double phase,
    double wave,
  ) {
    final radius = 49 * unit;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final glowPath = _diamond(center, radius * (1.02 + wave * 0.035));
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = primary.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 * unit),
    );
    canvas.drawPath(
      _diamond(center, radius),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFDEFCFF),
            Color(0xFF61E5F7),
            Color(0xFF5B55B9),
            Color(0xFF10162E),
          ],
          stops: const [0, 0.28, 0.7, 1],
        ).createShader(bounds),
    );
    canvas.drawPath(
      _diamond(center.translate(0, 2 * unit), radius * 0.69),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: [
            Colors.white.withValues(alpha: 0.42),
            const Color(0xFF132546).withValues(alpha: 0.94),
            const Color(0xFF070B17),
          ],
        ).createShader(bounds),
    );

    final sweepY = center.dy - radius * 0.62 + radius * 1.24 * phase;
    canvas.save();
    canvas.clipPath(_diamond(center, radius * 0.69));
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, sweepY),
        width: radius * 1.4,
        height: 7 * unit,
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            primary.withValues(alpha: 0.9),
            Colors.white,
            primary.withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ).createShader(bounds)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * unit),
    );
    canvas.restore();

    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9 * unit
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawLine(center.translate(0, -radius), center, facet);
    canvas.drawLine(center.translate(radius * 0.72, 0), center, facet);
    canvas.drawLine(center.translate(0, radius), center, facet);
    canvas.drawLine(center.translate(-radius * 0.72, 0), center, facet);
  }

  void _drawPackets(Canvas canvas, Offset center, double unit, double phase) {
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + phase * math.pi * 0.32;
      final radius = (91 + (i.isEven ? 12 : 0)) * unit;
      final point =
          center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.72);
      final alpha = 0.18 + 0.32 * ((math.sin(angle + phase * 6) + 1) / 2);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 8 * unit,
            height: 3 * unit,
          ),
          Radius.circular(1.5 * unit),
        ),
        Paint()..color = primary.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  Path _hexagon(Offset center, double width, double height) => Path()
    ..moveTo(center.dx, center.dy - height)
    ..lineTo(center.dx + width * 0.78, center.dy - height * 0.5)
    ..lineTo(center.dx + width, center.dy + height * 0.22)
    ..lineTo(center.dx + width * 0.45, center.dy + height)
    ..lineTo(center.dx - width * 0.45, center.dy + height)
    ..lineTo(center.dx - width, center.dy + height * 0.22)
    ..lineTo(center.dx - width * 0.78, center.dy - height * 0.5)
    ..close();

  Path _diamond(Offset center, double radius) => Path()
    ..moveTo(center.dx, center.dy - radius)
    ..lineTo(center.dx + radius * 0.72, center.dy)
    ..lineTo(center.dx, center.dy + radius)
    ..lineTo(center.dx - radius * 0.72, center.dy)
    ..close();

  @override
  bool shouldRepaint(covariant _DataGatewayPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.primary != primary;
}

class _SignalSteps extends StatelessWidget {
  const _SignalSteps({required this.animation, required this.primary});

  final Animation<double> animation;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('sync-flow-dots'),
      width: 78,
      height: 12,
      child: CustomPaint(
        painter: _SignalStepsPainter(animation: animation, primary: primary),
      ),
    );
  }
}

class _SignalStepsPainter extends CustomPainter {
  _SignalStepsPainter({required this.animation, required this.primary})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final active = (animation.value * 4).floor() % 4;
    for (var i = 0; i < 4; i++) {
      final isActive = i == active;
      final width = isActive ? 19.0 : 10.0;
      final rect = Rect.fromCenter(
        center: Offset(10 + i * 19.5, size.height / 2),
        width: width,
        height: 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()
          ..color = isActive
              ? primary.withValues(alpha: 0.95)
              : primary.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SignalStepsPainter oldDelegate) =>
      oldDelegate.animation != animation || oldDelegate.primary != primary;
}

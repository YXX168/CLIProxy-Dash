import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Compact prism beacon used in the dashboard header.
class QuantumEmblem extends StatefulWidget {
  const QuantumEmblem({super.key, this.size = 38});

  final double size;

  @override
  State<QuantumEmblem> createState() => _QuantumEmblemState();
}

class _QuantumEmblemState extends State<QuantumEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        key: const Key('quantum-emblem'),
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _PrismBeaconPainter(progress: _controller.value),
          ),
        ),
      ),
    );
  }
}

class _PrismBeaconPainter extends CustomPainter {
  const _PrismBeaconPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final tile = Offset.zero & size;
    final radius = side * 0.29;
    final phase = progress * math.pi * 2;

    final tilePath = Path()
      ..addRRect(RRect.fromRectAndRadius(tile, Radius.circular(side * 0.3)));
    canvas.drawPath(
      tilePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2A4A), Color(0xFF0B1222)],
        ).createShader(tile),
    );
    canvas.drawPath(
      tilePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.018
        ..color = Colors.white.withValues(alpha: 0.13),
    );

    canvas.drawCircle(
      center,
      side * 0.44,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.cyan.withValues(alpha: 0.18),
            AppTheme.violet.withValues(alpha: 0.07),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: side * 0.44)),
    );

    final orbitRect = Rect.fromCenter(
      center: center,
      width: side * 0.72,
      height: side * 0.27,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.28 + math.sin(phase) * 0.04);
    canvas.translate(-center.dx, -center.dy);
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.035
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          AppTheme.cyan,
          AppTheme.violet,
          AppTheme.magenta,
          AppTheme.cyan,
        ],
      ).createShader(orbitRect);
    canvas.drawArc(orbitRect, phase * 0.22, math.pi * 0.92, false, orbit);
    canvas.drawArc(
      orbitRect,
      math.pi + phase * 0.22,
      math.pi * 0.68,
      false,
      orbit,
    );
    canvas.restore();

    final coreRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius * 1.2,
      Paint()
        ..color = AppTheme.cyan.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.09),
    );
    canvas.drawPath(
      _diamond(center, radius * 1.12),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBDF8FF), Color(0xFF48D9F5), Color(0xFF4B4EAA)],
        ).createShader(coreRect),
    );
    canvas.drawPath(
      _diamond(center.translate(0, side * 0.015), radius * 0.72),
      Paint()..color = const Color(0xFF08152E).withValues(alpha: 0.72),
    );
    canvas.drawCircle(
      center.translate(-side * 0.08, -side * 0.1),
      side * 0.035,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );

    final beaconAngle = phase * 0.7 - math.pi / 2;
    final beacon =
        center +
        Offset(math.cos(beaconAngle), math.sin(beaconAngle)) * side * 0.36;
    canvas.drawCircle(
      beacon,
      side * 0.075,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.06),
    );
    canvas.drawCircle(beacon, side * 0.025, Paint()..color = Colors.white);
  }

  Path _diamond(Offset center, double radius) => Path()
    ..moveTo(center.dx, center.dy - radius)
    ..lineTo(center.dx + radius * 0.72, center.dy)
    ..lineTo(center.dx, center.dy + radius)
    ..lineTo(center.dx - radius * 0.72, center.dy)
    ..close();

  @override
  bool shouldRepaint(covariant _PrismBeaconPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

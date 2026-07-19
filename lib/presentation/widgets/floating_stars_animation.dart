import 'dart:math';
import 'package:flutter/material.dart';

/// Gentle, non-distracting ambient animation of floating stars /
/// soft rising bubbles, used behind the ringing page content.
class FloatingStarsAnimation extends StatefulWidget {
  final int particleCount;
  const FloatingStarsAnimation({super.key, this.particleCount = 18});

  @override
  State<FloatingStarsAnimation> createState() =>
      _FloatingStarsAnimationState();
}

class _FloatingStarsAnimationState extends State<FloatingStarsAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(widget.particleCount, (i) {
      return _Particle(
        xFraction: random.nextDouble(),
        startDelay: random.nextDouble(),
        speed: 0.05 + random.nextDouble() * 0.08,
        size: 6 + random.nextDouble() * 14,
        opacity: 0.25 + random.nextDouble() * 0.35,
        drift: (random.nextDouble() - 0.5) * 0.15,
        isStar: random.nextBool(),
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double xFraction;
  final double startDelay;
  final double speed;
  final double size;
  final double opacity;
  final double drift;
  final bool isStar;

  _Particle({
    required this.xFraction,
    required this.startDelay,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.drift,
    required this.isStar,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = ((t * (1 / p.speed)) + p.startDelay) % 1.0;
      final y = size.height * (1 - progress);
      final x = size.width * p.xFraction +
          sin(progress * 2 * pi) * size.width * p.drift;

      final fadeIn = (progress < 0.1) ? progress / 0.1 : 1.0;
      final fadeOut = (progress > 0.85) ? (1 - progress) / 0.15 : 1.0;
      final alpha = (p.opacity * fadeIn * fadeOut).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (p.isStar) {
        _drawStar(canvas, Offset(x, y), p.size / 2, paint);
      } else {
        canvas.drawCircle(Offset(x, y), p.size / 2, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 4;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : radius * 0.4;
      final angle = (pi / points) * i - pi / 2;
      final point = Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

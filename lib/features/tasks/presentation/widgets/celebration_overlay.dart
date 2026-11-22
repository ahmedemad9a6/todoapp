import 'dart:math';
import 'package:flutter/material.dart';

/// ويدجت احتفالية خفيفة وعالية الأداء (Confetti & Particle Celebration)
/// ترسم قصاصات ونجوم ملونة تتطاير بفيزياء ناعمة عند إنجاز المهام
class CelebrationOverlay extends StatefulWidget {
  final Widget child;

  const CelebrationOverlay({
    super.key,
    required this.child,
  });

  static CelebrationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<CelebrationOverlayState>();
  }

  @override
  State<CelebrationOverlay> createState() => CelebrationOverlayState();
}

class CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// إطلاق الاحتفال وقصاصات النجاح 🎉
  void play({Offset? origin}) {
    _particles.clear();
    const colors = [
      Color(0xFF10B981), // زمردي
      Color(0xFF3B82F6), // أزرق ناصع
      Color(0xFFF59E0B), // ذهبي
      Color(0xFFEC4899), // وردي
      Color(0xFF8B5CF6), // بنفسجي
      Color(0xFF06B6D4), // فيروزي
    ];

    final startX = origin?.dx ?? 200.0;
    final startY = origin?.dy ?? 200.0;

    for (int i = 0; i < 45; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 150.0 + _random.nextDouble() * 260.0;
      final size = 6.0 + _random.nextDouble() * 6.0;
      final color = colors[_random.nextInt(colors.length)];
      final isCircle = _random.nextBool();
      final rotationSpeed = (_random.nextDouble() - 0.5) * 8;

      _particles.add(
        _ConfettiParticle(
          x: startX,
          y: startY,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 120, // قوة دفع خفيفة للأعلى
          size: size,
          color: color,
          isCircle: isCircle,
          rotationSpeed: rotationSpeed,
        ),
      );
    }

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final bool isCircle;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.isCircle,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress; // من 0.0 إلى 1.0

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;
    final opacity = (1.0 - t).clamp(0.0, 1.0);
    const gravity = 450.0; // تسارع الجاذبية للأرض

    for (final p in particles) {
      final curX = p.x + p.vx * t;
      final curY = p.y + p.vy * t + 0.5 * gravity * t * t;

      if (curX < -50 || curX > size.width + 50 || curY > size.height + 50) {
        continue;
      }

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(p.rotationSpeed * t * pi);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 1.4,
              height: p.size * 0.8,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}


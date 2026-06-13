// lib/widgets/buddy_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class BuddyWidget extends StatefulWidget {
  final bool isHappy;
  final bool isTalking;

  const BuddyWidget({
    super.key,
    this.isHappy = false,
    this.isTalking = false,
  });

  @override
  State<BuddyWidget> createState() => _BuddyWidgetState();
}

class _BuddyWidgetState extends State<BuddyWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _happyController;
  late Animation<double> _floatAnim;
  late Animation<double> _blinkAnim;
  late Animation<double> _happyAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _happyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _blinkAnim = Tween<double>(begin: 1, end: 0).animate(_blinkController);

    _happyAnim = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _happyController, curve: Curves.elasticOut),
    );

    _scheduleBlink();
  }

  void _scheduleBlink() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: 2 + Random().nextInt(3)));
      if (!mounted) break;
      await _blinkController.forward();
      await _blinkController.reverse();
    }
  }

  @override
  void didUpdateWidget(BuddyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHappy && !oldWidget.isHappy) {
      _happyController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _happyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnim, _blinkAnim, _happyAnim]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: Transform.scale(
            scale: _happyAnim.value,
            child: SizedBox(
              width: 160,
              height: 180,
              child: CustomPaint(
                painter: _RobotPainter(
                  blink: _blinkAnim.value,
                  isHappy: widget.isHappy,
                  isTalking: widget.isTalking,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RobotPainter extends CustomPainter {
  final double blink;
  final bool isHappy;
  final bool isTalking;

  _RobotPainter({
    required this.blink,
    required this.isHappy,
    required this.isTalking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final paint = Paint()..isAntiAlias = true;

    // --- Antenna ---
    paint.color = PebloColors.deepBlue;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawLine(Offset(cx, 12), Offset(cx, 32), paint);
    paint.style = PaintingStyle.fill;
    paint.color = PebloColors.sunYellow;
    canvas.drawCircle(Offset(cx, 9), 7, paint);

    // --- Head ---
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 44, 30, 88, 72),
      const Radius.circular(22),
    );
    paint.color = PebloColors.skyBlue;
    canvas.drawRRect(headRect, paint);

    // Highlight on head
    paint.color = Colors.white.withOpacity(0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 34, 36, 40, 16),
        const Radius.circular(8),
      ),
      paint,
    );

    // --- Eyes ---
    final eyeY = isHappy ? 62.0 : 64.0;
    _drawEye(canvas, cx - 18, eyeY, blink, isHappy);
    _drawEye(canvas, cx + 18, eyeY, blink, isHappy);

    // --- Mouth ---
    final mouthPaint = Paint()
      ..color = PebloColors.deepBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    if (isHappy) {
      final smilePath = Path()
        ..moveTo(cx - 16, 90)
        ..quadraticBezierTo(cx, 104, cx + 16, 90);
      canvas.drawPath(smilePath, mouthPaint);
    } else if (isTalking) {
      paint.color = PebloColors.deepBlue;
      paint.style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 92), width: 22, height: 14), paint);
      paint.color = Colors.white.withOpacity(0.3);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 90), width: 14, height: 7), paint);
    } else {
      canvas.drawLine(Offset(cx - 14, 92), Offset(cx + 14, 92), mouthPaint);
    }

    // --- Cheek blush ---
    if (isHappy) {
      paint.color = PebloColors.coralRed.withOpacity(0.25);
      paint.style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 34, 80), width: 20, height: 12), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 34, 80), width: 20, height: 12), paint);
    }

    // --- Neck ---
    paint.color = PebloColors.deepBlue.withOpacity(0.4);
    canvas.drawRect(Rect.fromLTWH(cx - 10, 100, 20, 10), paint);

    // --- Body ---
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 50, 108, 100, 62),
      const Radius.circular(18),
    );
    paint.color = PebloColors.deepBlue;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(bodyRect, paint);

    // Body panel
    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 30, 118, 60, 38),
      const Radius.circular(10),
    );
    paint.color = PebloColors.skyBlue.withOpacity(0.35);
    canvas.drawRRect(panelRect, paint);

    // Panel lights
    final colors = [PebloColors.sunYellow, PebloColors.successGreen, PebloColors.coralRed];
    for (int i = 0; i < 3; i++) {
      paint.color = colors[i];
      canvas.drawCircle(Offset(cx - 18 + i * 18.0, 132), 6, paint);
    }

    // --- Gear icon on body (the lost blue gear!) ---
    _drawGear(canvas, Offset(cx, 150), 10, isHappy ? PebloColors.sunYellow : PebloColors.skyBlue.withOpacity(0.6));

    // --- Arms ---
    paint.color = PebloColors.deepBlue;
    final armRadius = const Radius.circular(8);
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 68, 112, 20, 44), armRadius),
      paint,
    );
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 48, 112, 20, 44), armRadius),
      paint,
    );

    // Hands
    paint.color = PebloColors.skyBlue;
    canvas.drawCircle(Offset(cx - 58, 158), 11, paint);
    canvas.drawCircle(Offset(cx + 58, 158), 11, paint);

    // --- Legs ---
    paint.color = PebloColors.deepBlue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 36, 168, 24, 14), armRadius),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 12, 168, 24, 14), armRadius),
      paint,
    );

    // Feet
    paint.color = PebloColors.skyBlue.withOpacity(0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 40, 178, 30, 10), const Radius.circular(5)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 10, 178, 30, 10), const Radius.circular(5)),
      paint,
    );
  }

  void _drawEye(Canvas canvas, double cx, double cy, double blink, bool happy) {
    final paint = Paint()..isAntiAlias = true;

    // White of eye
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 22 * blink.clamp(0.05, 1.0)), paint);

    if (blink > 0.1) {
      // Iris
      paint.color = PebloColors.deepBlue;
      canvas.drawCircle(Offset(cx, cy), 7 * blink, paint);
      // Pupil shine
      paint.color = Colors.white;
      canvas.drawCircle(Offset(cx + 2, cy - 2), 2.5 * blink, paint);

      if (happy) {
        // Star sparkle in eye
        paint.color = PebloColors.sunYellow.withOpacity(0.8 * blink);
        canvas.drawCircle(Offset(cx - 3, cy + 2), 1.5, paint);
      }
    }
  }

  void _drawGear(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final toothCount = 8;
    final outerRadius = radius;
    final innerRadius = radius * 0.7;
    final path = Path();

    for (int i = 0; i < toothCount * 2; i++) {
      final angle = (i * pi) / toothCount - pi / 2;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    paint.color = color.withOpacity(0.5);
    canvas.drawCircle(center, radius * 0.35, paint);
  }

  @override
  bool shouldRepaint(_RobotPainter old) =>
      old.blink != blink || old.isHappy != isHappy || old.isTalking != isTalking;
}

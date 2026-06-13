// lib/widgets/success_widget.dart

import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class SuccessWidget extends StatefulWidget {
  final VoidCallback onPlayAgain;

  const SuccessWidget({super.key, required this.onPlayAgain});

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4))..play();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti emitter
        ConfettiWidget(
          confettiController: _confetti,
          blastDirection: pi / 2, // downward
          emissionFrequency: 0.06,
          numberOfParticles: 20,
          maxBlastForce: 30,
          minBlastForce: 10,
          gravity: 0.3,
          colors: const [
            PebloColors.sunYellow,
            PebloColors.skyBlue,
            PebloColors.leafGreen,
            PebloColors.coralRed,
            PebloColors.softPurple,
          ],
          createParticlePath: (size) {
            final path = Path();
            path.addOval(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
            return path;
          },
        ),

        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF9C4), Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: PebloColors.successGreen, width: 3),
              boxShadow: [
                BoxShadow(
                  color: PebloColors.successGreen.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                Text(
                  'Amazing!',
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: PebloColors.successGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You got it right!\nBlue is Pip's favourite colour! 💙",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PebloColors.inkDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Stars row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + i * 100),
                      curve: Curves.elasticOut,
                      builder: (context, v, _) => Transform.scale(
                        scale: v,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('⭐', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: widget.onPlayAgain,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B1FA2), Color(0xFFE91E8C)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '🚀 Play Again!',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

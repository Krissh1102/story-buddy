
// lib/widgets/quiz_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_model.dart';
import '../theme.dart';

class QuizWidget extends StatefulWidget {
  final QuizModel quiz;
  final String? selectedAnswer;
  final bool isCorrect;
  final void Function(String answer) onAnswerSelected;

  const QuizWidget({
    super.key,
    required this.quiz,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.onAnswerSelected,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(QuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger shake when a wrong answer is newly selected
    if (widget.selectedAnswer != null &&
        widget.selectedAnswer != widget.quiz.answer &&
        widget.selectedAnswer != oldWidget.selectedAnswer) {
      _shakeController.forward(from: 0).then((_) => _shakeController.reverse());
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: PebloColors.cardWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: PebloColors.deepBlue.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Quiz header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Question!',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: PebloColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Question text (from JSON, not hardcoded)
              Text(
                widget.quiz.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: PebloColors.inkDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Options — rendered from quiz.options list, handles 3-5 options
              ...widget.quiz.options.asMap().entries.map(
                    (entry) => _buildOption(entry.value, entry.key),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String option, int index) {
    final isSelected = widget.selectedAnswer == option;
    final isCorrectOption = option == widget.quiz.answer;
    final isWrong = isSelected && !isCorrectOption;
    final answered = widget.isCorrect;

    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? trailing;

    if (answered && isCorrectOption) {
      bgColor = PebloColors.successGreen.withOpacity(0.15);
      borderColor = PebloColors.successGreen;
      textColor = PebloColors.successGreen;
      trailing = const Text('✅', style: TextStyle(fontSize: 18));
    } else if (isWrong) {
      bgColor = PebloColors.coralRed.withOpacity(0.12);
      borderColor = PebloColors.coralRed;
      textColor = PebloColors.coralRed;
      trailing = const Text('❌', style: TextStyle(fontSize: 16));
    } else {
      bgColor = PebloColors.bgGradientBottom;
      borderColor = PebloColors.skyBlue;
      textColor = PebloColors.inkDark;
      trailing = null;
    }

    const labels = ['A', 'B', 'C', 'D', 'E'];
    final label = index < labels.length ? labels[index] : '${index + 1}';

    Widget tile = GestureDetector(
      onTap: answered ? null : () => widget.onAnswerSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: borderColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );

    // Shake animation applied only to the wrong-selected option
    if (isWrong) {
      tile = AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          final dx = sin(_shakeAnim.value * pi * 5) * 8;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          );
        },
        child: tile,
      );
    }

    return tile;
  }
}

// lib/widgets/story_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/story_provider.dart';

class StoryCard extends StatefulWidget {
  final AudioState audioState;
  final String storyText;
  final String errorMessage;
  final VoidCallback onReadTap;

  const StoryCard({
    super.key,
    required this.audioState,
    required this.storyText,
    required this.errorMessage,
    required this.onReadTap,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // Story text
            Text(
              widget.storyText,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 17,
                height: 1.65,
                color: PebloColors.inkDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // State-based UI
            if (widget.audioState == AudioState.error)
              _buildErrorState()
            else
              _buildReadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadButton() {
    final isLoading = widget.audioState == AudioState.loading;
    final isPlaying = widget.audioState == AudioState.playing;

    return ScaleTransition(
      scale: (isPlaying || isLoading) ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: widget.onReadTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPlaying
                  ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                  : [PebloColors.deepBlue, const Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: (isPlaying ? PebloColors.coralRed : PebloColors.deepBlue)
                    .withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              else
                Icon(
                  isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              const SizedBox(width: 10),
              Text(
                isLoading
                    ? 'Getting ready...'
                    : isPlaying
                        ? 'Stop Story'
                        : '🎙️ Read Me a Story!',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Text(
          widget.errorMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: PebloColors.coralRed,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onReadTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: PebloColors.sunYellow,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '🔄 Try Again',
              style: GoogleFonts.nunito(
                color: PebloColors.inkDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

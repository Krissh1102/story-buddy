// lib/screens/story_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
//  BUBBLY KIDS THEME — Pip's Story Adventure
//  Palette: electric violet, sunshine yellow, coral pink, mint green, sky blue
//  Signature element: wobbly animated card border via AnimatedBuilder + CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';

// ─── Durations & Curves ───────────────────────────────────────────────────────
const _kFast = Duration(milliseconds: 120);
const _kMid = Duration(milliseconds: 300);
const _kSlow = Duration(milliseconds: 520);
const Curve _kSpring = Curves.easeOutCubic;
const Curve _kBounce = Curves.elasticOut;
const Curve _kSnap = Curves.easeInOutCubic;

// ─── Kids Colour Palette ─────────────────────────────────────────────────────
class KidsColors {
  KidsColors._();

  // Backgrounds
  static const bg = Color(0xFFFFF8F0); // warm cream
  static const surface = Color(0xFFFFFFFF);
  static const surfaceYellow = Color(0xFFFFF9C4);
  static const surfaceMint = Color(0xFFE8F8F0);
  static const surfaceViolet = Color(0xFFF3EEFF);
  static const surfaceCoral = Color(0xFFFFEEEC);

  // Brand / primary
  static const violet = Color(0xFF7C4DFF);
  static const violetLight = Color(0xFFEDE7FF);
  static const violetDark = Color(0xFF5E35B1);

  // Accent colours
  static const yellow = Color(0xFFFFCA28);
  static const yellowDark = Color(0xFFF57F17);
  static const coral = Color(0xFFFF6B6B);
  static const coralLight = Color(0xFFFFE5E5);
  static const coralDark = Color(0xFFD32F2F);
  static const mint = Color(0xFF00C9A7);
  static const mintLight = Color(0xFFE0FAF5);
  static const mintDark = Color(0xFF00796B);
  static const sky = Color(0xFF29B6F6);
  static const skyLight = Color(0xFFE1F5FE);
  static const skyDark = Color(0xFF0277BD);

  // Text
  static const textPrimary = Color(0xFF1A1035);
  static const textSecondary = Color(0xFF6B5E8A);
  static const textTertiary = Color(0xFFAA99CC);

  // Semantic
  static const success = Color(0xFF00C9A7);
  static const successLight = Color(0xFFE0FAF5);
  static const successDark = Color(0xFF00796B);
  static const error = Color(0xFFFF6B6B);
  static const errorLight = Color(0xFFFFE5E5);
  static const outline = Color(0xFFEDE7FF);

  // Star
  static const star = Color(0xFFFFCA28);
}

// ─── Kids Text Styles ─────────────────────────────────────────────────────────
class KidsText {
  KidsText._();

  static TextStyle display({Color? color}) => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: color ?? KidsColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle title({Color? color}) => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: color ?? KidsColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle body({Color? color}) => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: color ?? KidsColors.textPrimary,
    height: 1.7,
  );

  static TextStyle label({Color? color}) => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color ?? KidsColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? KidsColors.textTertiary,
    letterSpacing: 0.2,
  );
}

// ─── Wobbly border painter ────────────────────────────────────────────────────
// The signature element: a sinusoidal, animated border that gives the story
// card a hand-drawn, alive feel. Wave offset is driven by an animation tick.
class _WobblyBorderPainter extends CustomPainter {
  const _WobblyBorderPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
    this.amplitude = 5.0,
    this.frequency = 2.5,
    this.radius = 24.0,
  });

  final double progress; // 0..1, drives wave phase
  final Color color;
  final double strokeWidth;
  final double amplitude;
  final double frequency;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final phase = progress * 2 * math.pi;
    const steps = 200;

    // Helper: map a 0..perimeter position to a wobbly x,y
    final W = size.width;
    final H = size.height;
    final perimeter = 2 * (W + H);

    Offset _point(double t) {
      // t is 0..perimeter
      double x, y, nx, ny;
      if (t < W) {
        // top edge
        x = t;
        y = 0;
        nx = 0;
        ny = -1;
      } else if (t < W + H) {
        // right edge
        x = W;
        y = t - W;
        nx = 1;
        ny = 0;
      } else if (t < 2 * W + H) {
        // bottom edge
        x = W - (t - W - H);
        y = H;
        nx = 0;
        ny = 1;
      } else {
        // left edge
        x = 0;
        y = H - (t - 2 * W - H);
        nx = -1;
        ny = 0;
      }
      final wave =
          amplitude * math.sin(frequency * 2 * math.pi * t / perimeter + phase);
      return Offset(x + nx * wave, y + ny * wave);
    }

    final start = _point(0);
    path.moveTo(start.dx, start.dy);
    for (int i = 1; i <= steps; i++) {
      final pt = _point(perimeter * i / steps);
      path.lineTo(pt.dx, pt.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WobblyBorderPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathCtrl;
  late final Animation<double> _breathAnim;
  late final AnimationController _wobbleCtrl;
  final _scrollCtrl = ScrollController();
  double _appBarElevation = 0;

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    _breathAnim = CurvedAnimation(
      parent: _breathCtrl,
      curve: Curves.easeInOutSine,
    );

    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _scrollCtrl.addListener(() {
      final elev = (_scrollCtrl.offset / 40).clamp(0.0, 1.0);
      if ((elev - _appBarElevation).abs() > 0.02) {
        setState(() => _appBarElevation = elev);
      }
    });
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _wobbleCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Consumer<StoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: KidsColors.bg,
          body: CustomScrollView(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              _KidsAppBar(elevation: _appBarElevation),
              SliverSafeArea(
                top: false,
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.min(600, mq.size.width - 32),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),
                            _BuddySection(
                              provider: provider,
                              breathAnim: _breathAnim,
                            ),
                            const SizedBox(height: 24),
                            _StorySection(
                              provider: provider,
                              wobbleCtrl: _wobbleCtrl,
                            ),
                            const SizedBox(height: 16),
                            _QuizSection(provider: provider),
                            SizedBox(height: 48 + mq.padding.bottom),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _KidsAppBar extends StatelessWidget {
  const _KidsAppBar({required this.elevation});
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: AnimatedContainer(
        duration: _kMid,
        curve: _kSnap,
        decoration: BoxDecoration(
          color: KidsColors.bg.withOpacity(0.9 + elevation * 0.1),
          border: Border(
            bottom: BorderSide(
              color: KidsColors.violet.withOpacity(elevation * 0.15),
              width: 1.5,
            ),
          ),
        ),
      ),
      title: _AppBarTitle(),
      actions: const [_StarChip(stars: 12), SizedBox(width: 16)],
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: KidsColors.violet,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: KidsColors.violet.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Story Time!',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: KidsColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Star chip ────────────────────────────────────────────────────────────────

class _StarChip extends StatelessWidget {
  const _StarChip({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: KidsColors.yellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: KidsColors.yellow, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: KidsColors.yellow, size: 16),
          const SizedBox(width: 4),
          Text(
            '$stars',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: KidsColors.yellowDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Buddy section ────────────────────────────────────────────────────────────

class _BuddySection extends StatelessWidget {
  const _BuddySection({required this.provider, required this.breathAnim});
  final StoryProvider provider;
  final Animation<double> breathAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: breathAnim,
          builder: (_, child) => Transform.scale(
            scale: 1.0 + breathAnim.value * 0.035,
            child: child,
          ),
          child: _BuddyAvatar(
            isHappy: provider.isCorrect,
            isAnimating: provider.audioState == AudioState.playing,
          ),
        ),
        const SizedBox(height: 12),
        _StatusPill(provider: provider),
      ],
    );
  }
}

// ─── Audio waveform ───────────────────────────────────────────────────────────

class _AudioWaveform extends StatefulWidget {
  const _AudioWaveform();

  @override
  State<_AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<_AudioWaveform>
    with TickerProviderStateMixin {
  late final List<AnimationController> _bars;
  static const _heights = [0.5, 1.0, 0.7, 0.9, 0.6, 1.0, 0.5];
  static const _delays = [0, 80, 160, 40, 200, 120, 60];

  @override
  void initState() {
    super.initState();
    _bars = List.generate(7, (i) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 340 + i * 50),
      );
      Future.delayed(Duration(milliseconds: _delays[i]), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _bars) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_bars.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedBuilder(
            animation: _bars[i],
            builder: (_, __) {
              final h = 6 + (_bars[i].value * 20 * _heights[i]);
              final hue = (200 + i * 20).toDouble();
              return Container(
                width: 4,
                height: h,
                decoration: BoxDecoration(
                  color: HSLColor.fromAHSL(1, hue, 0.8, 0.55).toColor(),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─── Buddy avatar ─────────────────────────────────────────────────────────────

class _BuddyAvatar extends StatelessWidget {
  const _BuddyAvatar({required this.isHappy, required this.isAnimating});
  final bool isHappy;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final Color bg = isHappy ? KidsColors.mintLight : KidsColors.violetLight;
    final Color accent = isHappy ? KidsColors.mint : KidsColors.violet;

    return Semantics(
      label: isHappy ? 'Pip, super happy!' : 'Pip',
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring when playing
          if (isAnimating)
            AnimatedContainer(
              duration: _kSlow,
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.25), width: 8),
              ),
            ),
          // Main avatar
          AnimatedContainer(
            duration: _kSlow,
            curve: _kSpring,
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.5), width: 3),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(isAnimating ? 0.3 : 0.12),
                  blurRadius: isAnimating ? 28 : 16,
                  spreadRadius: isAnimating ? 4 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: _kMid,
                switchInCurve: _kBounce,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(parent: anim, curve: _kBounce),
                  child: child,
                ),
                child: isAnimating
                    ? const _AudioWaveform()
                    : Text(
                        isHappy ? '🌟' : '🤖',
                        key: ValueKey(isHappy),
                        style: const TextStyle(fontSize: 48),
                      ),
              ),
            ),
          ),
          // Star badge when happy
          if (isHappy)
            Positioned(
              top: 6,
              right: 6,
              child: AnimatedScale(
                scale: isHappy ? 1.0 : 0.0,
                duration: _kSlow,
                curve: _kBounce,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: KidsColors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('⭐', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Status pill ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.provider});
  final StoryProvider provider;

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(provider);
    return AnimatedSwitcher(
      duration: _kMid,
      switchInCurve: _kSpring,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SizeTransition(
          sizeFactor: CurvedAnimation(parent: anim, curve: _kSpring),
          axisAlignment: 0,
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(cfg.label),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cfg.bgColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: cfg.dotColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(color: cfg.dotColor, pulse: cfg.pulse),
            const SizedBox(width: 8),
            Text(
              cfg.label,
              style: KidsText.label(
                color: cfg.textColor,
              ).copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  _PillConfig _configFor(StoryProvider p) {
    switch (p.audioState) {
      case AudioState.playing:
        return const _PillConfig(
          label: 'Pip is reading to you! 📖',
          dotColor: KidsColors.violet,
          bgColor: KidsColors.violetLight,
          textColor: KidsColors.violetDark,
          pulse: true,
        );
      case AudioState.loading:
        return const _PillConfig(
          label: 'Getting the story ready… ✨',
          dotColor: KidsColors.yellow,
          bgColor: KidsColors.surfaceYellow,
          textColor: KidsColors.yellowDark,
          pulse: true,
        );
      case AudioState.error:
        return const _PillConfig(
          label: 'Oops! Something went wrong 😬',
          dotColor: KidsColors.coral,
          bgColor: KidsColors.coralLight,
          textColor: KidsColors.coralDark,
          pulse: false,
        );
      case AudioState.finished:
        if (p.isCorrect) {
          return const _PillConfig(
            label: 'You got it! Amazing! 🎉',
            dotColor: KidsColors.mint,
            bgColor: KidsColors.mintLight,
            textColor: KidsColors.mintDark,
            pulse: false,
          );
        }
        return const _PillConfig(
          label: "Quiz time! Can you answer? 🧠",
          dotColor: KidsColors.sky,
          bgColor: KidsColors.skyLight,
          textColor: KidsColors.skyDark,
          pulse: false,
        );
      default:
        return const _PillConfig(
          label: "Hi! I'm Pip 👋",
          dotColor: KidsColors.violet,
          bgColor: KidsColors.violetLight,
          textColor: KidsColors.violetDark,
          pulse: false,
        );
    }
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final opacity = widget.pulse ? 0.45 + _ctrl.value * 0.55 : 1.0;
        final scale = widget.pulse ? 0.8 + _ctrl.value * 0.4 : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _PillConfig {
  const _PillConfig({
    required this.label,
    required this.dotColor,
    required this.bgColor,
    required this.textColor,
    required this.pulse,
  });
  final String label;
  final Color dotColor;
  final Color bgColor;
  final Color textColor;
  final bool pulse;
}

// ─── Story section ────────────────────────────────────────────────────────────

class _StorySection extends StatelessWidget {
  const _StorySection({required this.provider, required this.wobbleCtrl});
  final StoryProvider provider;
  final AnimationController wobbleCtrl;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _kMid,
      curve: _kSpring,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: _kMid,
        switchInCurve: _kSpring,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: _kSpring)),
            child: child,
          ),
        ),
        child: _buildStateCard(),
      ),
    );
  }

  Widget _buildStateCard() {
    switch (provider.audioState) {
      case AudioState.loading:
        return const _StoryShimmer(key: ValueKey('loading'));
      case AudioState.error:
        return _StoryErrorCard(
          key: const ValueKey('error'),
          message: provider.errorMessage,
          onRetry: provider.readStory,
        );
      default:
        return _StoryCard(
          key: const ValueKey('story'),
          storyText: StoryProvider.storyText,
          audioState: provider.audioState,
          onReadTap: provider.readStory,
          wobbleCtrl: wobbleCtrl,
        );
    }
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _StoryShimmer extends StatefulWidget {
  const _StoryShimmer({super.key});

  @override
  State<_StoryShimmer> createState() => _StoryShimmerState();
}

class _StoryShimmerState extends State<_StoryShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KidsColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KidsColors.violet.withOpacity(0.2), width: 2),
      ),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBone(width: 120, height: 18, anim: _anim),
              const SizedBox(height: 20),
              _ShimmerBone(width: double.infinity, height: 14, anim: _anim),
              const SizedBox(height: 10),
              _ShimmerBone(width: double.infinity, height: 14, anim: _anim),
              const SizedBox(height: 10),
              _ShimmerBone(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 14,
                anim: _anim,
              ),
              const SizedBox(height: 28),
              _ShimmerBone(
                width: double.infinity,
                height: 54,
                anim: _anim,
                borderRadius: 18,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShimmerBone extends StatelessWidget {
  const _ShimmerBone({
    required this.width,
    required this.height,
    required this.anim,
    this.borderRadius = 6.0,
  });
  final double width;
  final double height;
  final Animation<double> anim;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-2 + anim.value * 4, 0),
          end: Alignment(-1 + anim.value * 4, 0),
          colors: [
            KidsColors.outline.withOpacity(0.4),
            KidsColors.violet.withOpacity(0.15),
            KidsColors.outline.withOpacity(0.4),
          ],
        ),
      ),
    );
  }
}

// ─── Story card with wobbly animated border ───────────────────────────────────

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    super.key,
    required this.storyText,
    required this.audioState,
    required this.onReadTap,
    required this.wobbleCtrl,
  });
  final String storyText;
  final AudioState audioState;
  final VoidCallback onReadTap;
  final AnimationController wobbleCtrl;

  String get _wordCount {
    final n = storyText.trim().split(RegExp(r'\s+')).length;
    return '$n words';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = audioState == AudioState.playing;

    return AnimatedBuilder(
      animation: wobbleCtrl,
      builder: (_, child) {
        return CustomPaint(
          painter: _WobblyBorderPainter(
            progress: wobbleCtrl.value,
            color: isPlaying
                ? KidsColors.violet.withOpacity(0.8)
                : KidsColors.violet.withOpacity(0.35),
            strokeWidth: isPlaying ? 3 : 2,
            amplitude: isPlaying ? 6 : 3.5,
            frequency: 3.0,
          ),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: KidsColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: KidsColors.violetLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text(
                        "Today's Story",
                        style: KidsText.caption(
                          color: KidsColors.violetDark,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KidsColors.surfaceYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: KidsColors.yellow.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _wordCount,
                    style: KidsText.caption(color: KidsColors.yellowDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Story text
            Text(
              storyText,
              style: KidsText.body().copyWith(height: 1.75, fontSize: 15.5),
            ),
            const SizedBox(height: 24),
            // Play button
            _PlayButton(
              isPlaying: audioState == AudioState.playing,
              canPlay:
                  audioState == AudioState.idle ||
                  audioState == AudioState.finished,
              wasFinished: audioState == AudioState.finished,
              onTap: onReadTap,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Play button ──────────────────────────────────────────────────────────────

class _PlayButton extends StatefulWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.canPlay,
    required this.wasFinished,
    required this.onTap,
  });
  final bool isPlaying;
  final bool canPlay;
  final bool wasFinished;
  final VoidCallback onTap;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: _kFast);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.isPlaying;
    final Color bg = isPlaying ? KidsColors.violetLight : KidsColors.violet;
    final Color fg = isPlaying ? KidsColors.violet : Colors.white;
    final String emoji = isPlaying
        ? '🎧'
        : widget.wasFinished
        ? '🔁'
        : '▶️';
    final String label = isPlaying
        ? 'Listening…'
        : widget.wasFinished
        ? 'Listen again!'
        : 'Listen to the story!';

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTapDown: widget.canPlay ? (_) => _pressCtrl.forward() : null,
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        onTap: widget.canPlay
            ? () {
                HapticFeedback.lightImpact();
                widget.onTap();
              }
            : null,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 0.94).animate(
            CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
          ),
          child: AnimatedContainer(
            duration: _kMid,
            curve: _kSnap,
            height: 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: isPlaying
                  ? Border.all(
                      color: KidsColors.violet.withOpacity(0.4),
                      width: 2,
                    )
                  : null,
              boxShadow: isPlaying
                  ? []
                  : [
                      BoxShadow(
                        color: KidsColors.violet.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: _kFast,
                child: Row(
                  key: ValueKey(isPlaying),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: KidsText.label(color: fg).copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error card ───────────────────────────────────────────────────────────────

class _StoryErrorCard extends StatelessWidget {
  const _StoryErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KidsColors.coralLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KidsColors.coral.withOpacity(0.35), width: 2),
      ),
      child: Column(
        children: [
          const Text('😵', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            'Uh oh! Something broke!',
            style: KidsText.title(color: KidsColors.coralDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'Check your connection and try again!',
            style: KidsText.body(
              color: KidsColors.coralDark.withOpacity(0.75),
            ).copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: KidsColors.coral,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: KidsColors.coral.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔄', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Try again!',
                    style: KidsText.label(
                      color: Colors.white,
                    ).copyWith(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quiz section ─────────────────────────────────────────────────────────────

class _QuizSection extends StatelessWidget {
  const _QuizSection({required this.provider});
  final StoryProvider provider;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _kMid,
      curve: _kSpring,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: _kMid,
        switchInCurve: _kSpring,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: _kSpring)),
            child: child,
          ),
        ),
        child: _buildQuizState(),
      ),
    );
  }

  Widget _buildQuizState() {
    if (provider.quizState == QuizState.hidden) {
      return _QuizLockedCard(
        key: const ValueKey('locked'),
        audioState: provider.audioState,
      );
    }
    if (provider.isCorrect) {
      return _SuccessCard(
        key: const ValueKey('success'),
        onPlayAgain: provider.reset,
      );
    }
    return _QuizCard(
      key: const ValueKey('quiz'),
      selectedAnswer: provider.selectedAnswer,
      isCorrect: provider.isCorrect,
      onAnswerSelected: provider.selectAnswer,
      quiz: const {
        'question': "What colour was Pip the Robot's lost gear?",
        'options': ['Red 🔴', 'Green 🟢', 'Blue 🔵', 'Yellow 🟡'],
        'answer': 'Blue 🔵',
      },
    );
  }
}

// ─── Quiz locked card ─────────────────────────────────────────────────────────

class _QuizLockedCard extends StatelessWidget {
  const _QuizLockedCard({super.key, required this.audioState});
  final AudioState audioState;

  double get _progress {
    switch (audioState) {
      case AudioState.idle:
        return 0.0;
      case AudioState.loading:
        return 0.15;
      case AudioState.playing:
        return 0.6;
      case AudioState.finished:
        return 1.0;
      case AudioState.error:
        return 0.0;
    }
  }

  String get _hintText {
    if (audioState == AudioState.playing) {
      return 'Keep listening… the quiz is coming! 👂';
    }
    return 'Listen to the story to unlock your quiz! 🔒';
  }

  // Bar colour for progress
  Color get _barColor {
    if (_progress >= 1.0) return KidsColors.mint;
    if (_progress > 0.1) return KidsColors.violet;
    return KidsColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = audioState == AudioState.finished;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: KidsColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked
              ? KidsColors.mint.withOpacity(0.5)
              : KidsColors.outline,
          width: isUnlocked ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧩', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Story Quiz',
                style: KidsText.title(
                  color: isUnlocked
                      ? KidsColors.textPrimary
                      : KidsColors.textSecondary,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: _kMid,
                child: Text(
                  isUnlocked ? '🔓' : '🔒',
                  key: ValueKey(isUnlocked),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chunky progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: _kSlow,
            curve: _kSpring,
            builder: (_, value, __) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: KidsColors.violetLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: _barColor,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: _barColor.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            _hintText,
            style: KidsText.caption(
              color: KidsColors.textTertiary,
            ).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Quiz card ────────────────────────────────────────────────────────────────

class _QuizCard extends StatefulWidget {
  const _QuizCard({
    super.key,
    required this.quiz,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.onAnswerSelected,
  });
  final Map<String, dynamic> quiz;
  final String? selectedAnswer;
  final bool isCorrect;
  final void Function(String) onAnswerSelected;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> with TickerProviderStateMixin {
  late final List<AnimationController> _staggerCtrls;

  @override
  void initState() {
    super.initState();
    final opts = widget.quiz['options'] as List<String>? ?? [];
    _staggerCtrls = List.generate(
      opts.length,
      (i) => AnimationController(vsync: this, duration: _kMid),
    );
    for (var i = 0; i < _staggerCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: 50 + i * 70), () {
        if (mounted) _staggerCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _staggerCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz['question'] as String? ?? '';
    final options = widget.quiz['options'] as List<String>? ?? [];
    final correct = widget.quiz['answer'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: KidsColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KidsColors.sky.withOpacity(0.35), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: KidsColors.skyLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧠', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(
                  'Quick Quiz!',
                  style: KidsText.caption(
                    color: KidsColors.skyDark,
                  ).copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(question, style: KidsText.title()),
          const SizedBox(height: 18),
          ...List.generate(options.length, (i) {
            final opt = options[i];
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _staggerCtrls[i], curve: _kSpring),
                  ),
              child: FadeTransition(
                opacity: _staggerCtrls[i],
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AnswerButton(
                    label: opt,
                    index: i,
                    selected: widget.selectedAnswer == opt,
                    isCorrect: opt == correct,
                    isRevealed: widget.selectedAnswer != null,
                    onTap: widget.selectedAnswer == null
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onAnswerSelected(opt);
                          }
                        : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Answer button ────────────────────────────────────────────────────────────

class _AnswerButton extends StatefulWidget {
  const _AnswerButton({
    required this.label,
    required this.index,
    required this.selected,
    required this.isCorrect,
    required this.isRevealed,
    required this.onTap,
  });
  final String label;
  final int index;
  final bool selected;
  final bool isCorrect;
  final bool isRevealed;
  final VoidCallback? onTap;

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton>
    with TickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _pressCtrl = AnimationController(vsync: this, duration: _kFast);
  }

  @override
  void didUpdateWidget(_AnswerButton old) {
    super.didUpdateWidget(old);
    if (widget.selected &&
        widget.isRevealed &&
        !widget.isCorrect &&
        !old.isRevealed) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
    }
    if (widget.isRevealed && widget.isCorrect && !old.isRevealed) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCorrect = widget.isRevealed && widget.isCorrect;
    final showError = widget.isRevealed && widget.selected && !widget.isCorrect;

    final shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    final letters = ['A', 'B', 'C', 'D'];
    final bg = showCorrect
        ? KidsColors.mintLight
        : showError
        ? KidsColors.coralLight
        : KidsColors.surface;
    final borderColor = showCorrect
        ? KidsColors.mint
        : showError
        ? KidsColors.coral
        : widget.selected
        ? KidsColors.sky
        : KidsColors.outline;
    final textColor = showCorrect
        ? KidsColors.mintDark
        : showError
        ? KidsColors.coralDark
        : KidsColors.textPrimary;

    return Semantics(
      button: widget.onTap != null,
      selected: widget.selected,
      label: widget.label,
      child: AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(showError ? shakeAnim.value : 0, 0),
          child: child,
        ),
        child: GestureDetector(
          onTapDown: widget.onTap != null ? (_) => _pressCtrl.forward() : null,
          onTapUp: (_) => _pressCtrl.reverse(),
          onTapCancel: () => _pressCtrl.reverse(),
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.97).animate(
              CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
            ),
            child: AnimatedContainer(
              duration: _kMid,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: showCorrect
                    ? [
                        BoxShadow(
                          color: KidsColors.mint.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Letter badge
                  _LetterBadge(
                    letter: letters[widget.index % letters.length],
                    isCorrect: showCorrect,
                    isError: showError,
                    isSelected: widget.selected && !widget.isRevealed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: KidsText.body(color: textColor).copyWith(
                        fontWeight: widget.selected || showCorrect
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (widget.isRevealed) ...[
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: _kFast,
                      child: widget.isCorrect
                          ? const Text(
                              '✅',
                              key: ValueKey('check'),
                              style: TextStyle(fontSize: 20),
                            )
                          : widget.selected
                          ? const Text(
                              '❌',
                              key: ValueKey('x'),
                              style: TextStyle(fontSize: 20),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Letter badge ─────────────────────────────────────────────────────────────

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({
    required this.letter,
    required this.isCorrect,
    required this.isError,
    required this.isSelected,
  });
  final String letter;
  final bool isCorrect;
  final bool isError;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (isCorrect) {
      bg = KidsColors.mint;
      fg = Colors.white;
    } else if (isError) {
      bg = KidsColors.coral;
      fg = Colors.white;
    } else if (isSelected) {
      bg = KidsColors.sky;
      fg = Colors.white;
    } else {
      bg = KidsColors.violetLight;
      fg = KidsColors.textSecondary;
    }

    return AnimatedContainer(
      duration: _kMid,
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ─── Success card ─────────────────────────────────────────────────────────────

class _SuccessCard extends StatefulWidget {
  const _SuccessCard({super.key, required this.onPlayAgain});
  final VoidCallback onPlayAgain;

  @override
  State<_SuccessCard> createState() => _SuccessCardState();
}

class _SuccessCardState extends State<_SuccessCard>
    with TickerProviderStateMixin {
  late final AnimationController _iconCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _btnCtrl;
  late final AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(vsync: this, duration: _kSlow);
    _textCtrl = AnimationController(vsync: this, duration: _kMid);
    _btnCtrl = AnimationController(vsync: this, duration: _kMid);
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _confettiCtrl.forward();
    _iconCtrl.forward().then((_) {
      if (mounted)
        _textCtrl.forward().then((_) {
          if (mounted) _btnCtrl.forward();
        });
    });
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _textCtrl.dispose();
    _btnCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: KidsColors.surfaceMint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KidsColors.mint.withOpacity(0.5), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: KidsColors.mint.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated confetti stars + main emoji
          ScaleTransition(
            scale: CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbiting confetti
                AnimatedBuilder(
                  animation: _confettiCtrl,
                  builder: (_, __) {
                    return SizedBox(
                      width: 110,
                      height: 110,
                      child: CustomPaint(
                        painter: _ConfettiPainter(
                          progress: _confettiCtrl.value,
                        ),
                      ),
                    );
                  },
                ),
                // Trophy emoji
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: KidsColors.mintLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: KidsColors.mint.withOpacity(0.4),
                      width: 2.5,
                    ),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 42)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _textCtrl,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _textCtrl, curve: _kSpring)),
              child: Column(
                children: [
                  Text(
                    'Amazing job! 🎉',
                    style: KidsText.display(
                      color: KidsColors.mintDark,
                    ).copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You answered perfectly! Keep up the awesome work!',
                    style: KidsText.body(
                      color: KidsColors.textSecondary,
                    ).copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _btnCtrl,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _btnCtrl, curve: _kSpring)),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KidsColors.mint,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: KidsColors.mint.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(
                        'Read another story!',
                        style: KidsText.label(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confetti painter ─────────────────────────────────────────────────────────
// Draws little coloured dots that orbit outward and fade — triggered on success.

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});
  final double progress; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rng = math.Random(42);

    const particles = 16;
    final colors = [
      KidsColors.violet,
      KidsColors.yellow,
      KidsColors.coral,
      KidsColors.sky,
      KidsColors.mint,
    ];

    for (int i = 0; i < particles; i++) {
      final angle = (i / particles) * 2 * math.pi + rng.nextDouble() * 0.4;
      final maxR = 44.0 + rng.nextDouble() * 12;
      final r = maxR * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final sz = 5.0 + rng.nextDouble() * 4;

      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;

      canvas.drawCircle(
        Offset(x, y),
        sz * (1 - progress * 0.5),
        Paint()..color = colors[i % colors.length].withOpacity(opacity * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

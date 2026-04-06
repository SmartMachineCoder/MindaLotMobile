import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/mood.dart';
import '../../../core/services/mood_provider.dart';

class MoodSelector extends StatelessWidget {
  final MoodProvider provider;
  final bool isDarkBg;
  const MoodSelector(
      {super.key, required this.provider, this.isDarkBg = false});

  static const _moods = [
    MoodType.happy,
    MoodType.sad,
    MoodType.anxious,
    MoodType.angry,
    MoodType.confused,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moods.map((mood) {
        final config = MoodData.get(mood);
        final isSelected = provider.currentMood == mood;
        final isLocked = provider.isMoodLocked && !isSelected;

        return _BrandedMoodButton(
          config: config,
          isSelected: isSelected,
          isLocked: isLocked,
          isDarkBg: isDarkBg,
          onTap: () {
            if (provider.isMoodLocked) {
              if (!isSelected) _showLockedDialog(context, provider);
              return;
            }
            provider.selectMood(mood);
          },
        );
      }).toList(),
    );
  }

  void _showLockedDialog(BuildContext context, MoodProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Mood Locked',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text(
          'Your current mood is locked for ${provider.formatRemainingTime()} more.\n\nThis helps us track your emotional journey accurately.',
          style: GoogleFonts.nunito(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF5C3D2E),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Branded mood button — custom-painted icon, glass card, rich interactions
// ═══════════════════════════════════════════════════════════════════════════
class _BrandedMoodButton extends StatefulWidget {
  final MoodConfig config;
  final bool isSelected;
  final bool isLocked;
  final bool isDarkBg;
  final VoidCallback onTap;

  const _BrandedMoodButton({
    required this.config,
    required this.isSelected,
    required this.isLocked,
    required this.isDarkBg,
    required this.onTap,
  });

  @override
  State<_BrandedMoodButton> createState() => _BrandedMoodButtonState();
}

class _BrandedMoodButtonState extends State<_BrandedMoodButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isSelected) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _BrandedMoodButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? 0.88
        : _isHovered
            ? 1.12
            : (widget.isSelected ? 1.08 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isLocked
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, child) {
            final ps = widget.isSelected
                ? 1.0 + _pulseController.value * 0.05
                : 1.0;
            return AnimatedScale(
              scale: scale * ps,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: child,
            );
          },
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final color = widget.config.primaryColor;
    final size = 58.0;

    return Opacity(
      opacity: widget.isLocked ? 0.35 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withValues(alpha: 0.7),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isDarkBg
                          ? [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.08),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.9),
                              const Color(0xFFF5F0ED),
                            ],
                    ),
              border: Border.all(
                color: widget.isSelected
                    ? color
                    : _isHovered
                        ? color.withValues(alpha: 0.5)
                        : widget.isDarkBg
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFE0D6CF),
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : _isHovered
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
            ),
            child: CustomPaint(
              size: Size(size, size),
              painter: _MoodIconPainter(
                mood: widget.config.type,
                color: widget.isSelected
                    ? Colors.white
                    : widget.isDarkBg
                        ? Colors.white.withValues(alpha: 0.85)
                        : color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            widget.config.label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight:
                  widget.isSelected ? FontWeight.w800 : FontWeight.w600,
              color: widget.isSelected
                  ? color
                  : widget.isDarkBg
                      ? Colors.white70
                      : const Color(0xFF7A6055),
              shadows: widget.isDarkBg
                  ? [const Shadow(color: Colors.black54, blurRadius: 4)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Custom-painted mood icons — consistent branded look across all platforms
// ═══════════════════════════════════════════════════════════════════════════
class _MoodIconPainter extends CustomPainter {
  final MoodType mood;
  final Color color;

  _MoodIconPainter({required this.mood, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.28;

    // Face circle outline
    final facePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy), r, facePaint);

    switch (mood) {
      case MoodType.happy:
        _drawHappy(canvas, cx, cy, r, fillPaint, facePaint);
        break;
      case MoodType.sad:
        _drawSad(canvas, cx, cy, r, fillPaint, facePaint);
        break;
      case MoodType.anxious:
        _drawAnxious(canvas, cx, cy, r, fillPaint, facePaint);
        break;
      case MoodType.angry:
        _drawAngry(canvas, cx, cy, r, fillPaint, facePaint);
        break;
      case MoodType.confused:
        _drawConfused(canvas, cx, cy, r, fillPaint, facePaint);
        break;
      default:
        break;
    }
  }

  void _drawHappy(Canvas canvas, double cx, double cy, double r,
      Paint fill, Paint stroke) {
    // Eyes — happy arcs (^  ^)
    final eyeY = cy - r * 0.2;
    final eyeSpread = r * 0.35;
    for (final dx in [-eyeSpread, eyeSpread]) {
      final path = Path()
        ..moveTo(cx + dx - r * 0.15, eyeY)
        ..quadraticBezierTo(cx + dx, eyeY - r * 0.25, cx + dx + r * 0.15, eyeY);
      canvas.drawPath(path, stroke..strokeWidth = 2.0);
    }
    // Wide smile
    final smilePath = Path()
      ..moveTo(cx - r * 0.5, cy + r * 0.15)
      ..quadraticBezierTo(cx, cy + r * 0.65, cx + r * 0.5, cy + r * 0.15);
    canvas.drawPath(smilePath, stroke..strokeWidth = 2.0);
  }

  void _drawSad(Canvas canvas, double cx, double cy, double r,
      Paint fill, Paint stroke) {
    // Eyes — dots
    final eyeY = cy - r * 0.15;
    final sp = r * 0.3;
    canvas.drawCircle(Offset(cx - sp, eyeY), r * 0.07, fill);
    canvas.drawCircle(Offset(cx + sp, eyeY), r * 0.07, fill);
    // Tear drop on left eye
    final tearPath = Path()
      ..moveTo(cx - sp, eyeY + r * 0.12)
      ..quadraticBezierTo(
          cx - sp - r * 0.06, eyeY + r * 0.32, cx - sp, eyeY + r * 0.38);
    canvas.drawPath(tearPath, stroke..strokeWidth = 1.5);
    // Frown
    final frownPath = Path()
      ..moveTo(cx - r * 0.35, cy + r * 0.4)
      ..quadraticBezierTo(cx, cy + r * 0.1, cx + r * 0.35, cy + r * 0.4);
    canvas.drawPath(frownPath, stroke..strokeWidth = 2.0);
  }

  void _drawAnxious(Canvas canvas, double cx, double cy, double r,
      Paint fill, Paint stroke) {
    // Wide open eyes (circles)
    final eyeY = cy - r * 0.15;
    final sp = r * 0.3;
    canvas.drawCircle(Offset(cx - sp, eyeY), r * 0.13, stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx + sp, eyeY), r * 0.13, stroke);
    // Pupils
    canvas.drawCircle(Offset(cx - sp, eyeY), r * 0.05, fill);
    canvas.drawCircle(Offset(cx + sp, eyeY), r * 0.05, fill);
    // Wavy worried mouth
    final mouthPath = Path()..moveTo(cx - r * 0.3, cy + r * 0.3);
    for (int i = 0; i < 4; i++) {
      final x = cx - r * 0.3 + (i + 1) * (r * 0.6 / 4);
      final y = cy + r * 0.3 + (i.isEven ? -r * 0.08 : r * 0.08);
      mouthPath.lineTo(x, y);
    }
    canvas.drawPath(mouthPath, stroke..strokeWidth = 1.8);
    // Sweat drop
    canvas.drawCircle(Offset(cx + r * 0.55, cy - r * 0.35), r * 0.08, fill);
  }

  void _drawAngry(Canvas canvas, double cx, double cy, double r,
      Paint fill, Paint stroke) {
    // Angry brows (V shapes)
    final browY = cy - r * 0.35;
    final sp = r * 0.3;
    // Left brow: slants down inward
    canvas.drawLine(Offset(cx - sp - r * 0.2, browY - r * 0.1),
        Offset(cx - sp + r * 0.15, browY + r * 0.1), stroke..strokeWidth = 2.2);
    // Right brow: slants down inward
    canvas.drawLine(Offset(cx + sp + r * 0.2, browY - r * 0.1),
        Offset(cx + sp - r * 0.15, browY + r * 0.1), stroke);
    // Eyes — sharp dots
    final eyeY = cy - r * 0.08;
    canvas.drawCircle(Offset(cx - sp, eyeY), r * 0.08, fill);
    canvas.drawCircle(Offset(cx + sp, eyeY), r * 0.08, fill);
    // Tight frown
    final frownPath = Path()
      ..moveTo(cx - r * 0.3, cy + r * 0.35)
      ..quadraticBezierTo(cx, cy + r * 0.15, cx + r * 0.3, cy + r * 0.35);
    canvas.drawPath(frownPath, stroke..strokeWidth = 2.2);
  }

  void _drawConfused(Canvas canvas, double cx, double cy, double r,
      Paint fill, Paint stroke) {
    // Uneven eyes — one bigger
    final eyeY = cy - r * 0.15;
    final sp = r * 0.3;
    canvas.drawCircle(Offset(cx - sp, eyeY), r * 0.09, fill);
    canvas.drawCircle(Offset(cx + sp, eyeY - r * 0.05), r * 0.07, fill);
    // Raised brow on right
    final browPath = Path()
      ..moveTo(cx + sp - r * 0.15, eyeY - r * 0.28)
      ..quadraticBezierTo(
          cx + sp, eyeY - r * 0.4, cx + sp + r * 0.15, eyeY - r * 0.25);
    canvas.drawPath(browPath, stroke..strokeWidth = 1.8);
    // Slanted/crooked mouth
    final mouthPath = Path()
      ..moveTo(cx - r * 0.2, cy + r * 0.3)
      ..lineTo(cx + r * 0.25, cy + r * 0.2);
    canvas.drawPath(mouthPath, stroke..strokeWidth = 2.0);
    // Question mark above head
    final qx = cx + r * 0.6;
    final qy = cy - r * 0.8;
    final qPath = Path()
      ..moveTo(qx - r * 0.12, qy - r * 0.15)
      ..quadraticBezierTo(qx - r * 0.12, qy - r * 0.35, qx, qy - r * 0.35)
      ..quadraticBezierTo(qx + r * 0.12, qy - r * 0.35, qx + r * 0.05, qy - r * 0.15)
      ..quadraticBezierTo(qx, qy - r * 0.05, qx, qy);
    canvas.drawPath(qPath, stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(qx, qy + r * 0.1), r * 0.04, fill);
  }

  @override
  bool shouldRepaint(covariant _MoodIconPainter old) =>
      old.mood != mood || old.color != color;
}

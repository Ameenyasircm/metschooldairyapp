import 'dart:math';
import 'package:flutter/material.dart';

class ExamComingSoonPage extends StatefulWidget {
  const ExamComingSoonPage({super.key});

  @override
  State<ExamComingSoonPage> createState() => _ExamComingSoonPageState();
}

class _ExamComingSoonPageState extends State<ExamComingSoonPage>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _orbitController;

  late Animation<double> _floatAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _orbitAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _floatAnim = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _orbitAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Background blobs ──
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(color: const Color(0xFF4F46E5), size: 280),
            ),
            Positioned(
              bottom: 40,
              left: -80,
              child: _GlowBlob(color: const Color(0xFF7C3AED), size: 240),
            ),
            Positioned(
              top: 200,
              left: 40,
              child: _GlowBlob(color: const Color(0xFF0EA5E9), size: 120),
            ),

            // ── Orbiting dots ──
            AnimatedBuilder(
              animation: _orbitAnim,
              builder: (_, __) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: _OrbitPainter(_orbitAnim.value),
                  ),
                );
              },
            ),

            // ── Main content ──
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Floating icon
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: child,
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) {
                          return Transform.scale(
                            scale: _pulseAnim.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                const Color(0xFF6366F1).withOpacity(0.55),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.assignment_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // "COMING SOON" badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: const Color(0xFF6366F1), width: 1.4),
                        color: const Color(0xFF6366F1).withOpacity(0.12),
                      ),
                      child: const Text(
                        '✦  COMING SOON  ✦',
                        style: TextStyle(
                          color: Color(0xFFA5B4FC),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Title
                    const Text(
                      'Exam\nSection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Subtitle
                    Text(
                      'We\'re working hard to bring you\na powerful exam experience.\nStay tuned! 🚀',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Feature preview chips
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: const [
                        _FeatureChip(
                            icon: Icons.timer_outlined, label: 'Timed Tests'),
                        _FeatureChip(
                            icon: Icons.bar_chart_rounded,
                            label: 'Score Analysis'),
                        _FeatureChip(
                            icon: Icons.quiz_outlined,
                            label: 'Mock Exams'),
                        _FeatureChip(
                            icon: Icons.leaderboard_rounded,
                            label: 'Leaderboard'),
                      ],
                    ),

                    const SizedBox(height: 48),


                    // Back button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifySnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B4B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF818CF8)),
            SizedBox(width: 10),
            Text(
              'You\'ll be notified when Exams launch!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─── Feature Chip ───────────────────────────

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFA5B4FC)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glow Blob ──────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ─── Orbit Painter ──────────────────────────

class _OrbitPainter extends CustomPainter {
  final double angle;

  _OrbitPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;
    final paint = Paint()..style = PaintingStyle.fill;

    final dots = [
      (radius: 110.0, size: 6.0, color: const Color(0xFF6366F1), phase: 0.0),
      (
      radius: 155.0,
      size: 4.5,
      color: const Color(0xFF8B5CF6),
      phase: pi / 1.5
      ),
      (
      radius: 195.0,
      size: 3.5,
      color: const Color(0xFF0EA5E9),
      phase: pi / 3
      ),
    ];

    for (final d in dots) {
      final a = angle + d.phase;
      final x = cx + d.radius * cos(a);
      final y = cy + d.radius * sin(a) * 0.35;
      paint.color = d.color.withOpacity(0.7);
      canvas.drawCircle(Offset(x, y), d.size, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.angle != angle;
}



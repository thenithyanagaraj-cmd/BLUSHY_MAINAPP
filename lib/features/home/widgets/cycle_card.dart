import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../../core/state.dart';

class BlushyCycleCard extends StatefulWidget {
  final bool purePainterMode;
  const BlushyCycleCard({super.key, this.purePainterMode = false});

  @override
  State<BlushyCycleCard> createState() => _BlushyCycleCardState();
}

class _BlushyCycleCardState extends State<BlushyCycleCard> with TickerProviderStateMixin {
  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _loopController;
  late final AnimationController _sweepController;

  final double _currentDayProgress = 19.0 / 28.0; 
  double _userDragProgress = -1.0;                
  bool _isSweeping = false;
  String _activePhaseName = 'Luteal Phase';
  String _activeDayLabel = '19';
  String _activePeriodLabel = '10 days';

  Path? _cachedPath;
  PathMetrics? _cachedMetrics;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _progressController.animateTo(
      _currentDayProgress,
      curve: Curves.easeOutCubic,
    );

    _sweepController.addListener(() {
      if (_isSweeping) {
        _updateLabelsForProgress(_sweepController.value);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _loopController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  void _updateLabelsForProgress(double t) {
    final day = (t * 28).round().clamp(1, 28);
    setState(() {
      _activeDayLabel = day.toString();
      if (day <= 5) {
        _activePhaseName = 'Menstrual Phase';
        _activePeriodLabel = 'Active';
      } else if (day <= 12) {
        _activePhaseName = 'Follicular Phase';
        _activePeriodLabel = '${28 - day} days';
      } else if (day <= 16) {
        _activePhaseName = 'Ovulation Phase';
        _activePeriodLabel = '${28 - day} days';
      } else {
        _activePhaseName = 'Luteal Phase';
        final diff = 28 - day;
        _activePeriodLabel = diff == 0 ? 'Tomorrow' : '$diff days';
      }
    });
  }

  Path _generateContinuousBlushyPath(Size size) {
    if (_cachedPath != null && size.width == 260) return _cachedPath!;

    final w = size.width;
    final h = size.height;
    final path = Path();

    // Start at bottom-left leg
    path.moveTo(w * 0.38, h * 0.90);
    
    // Left inner curve up
    path.cubicTo(
      w * 0.37, h * 0.76,
      w * 0.31, h * 0.54,
      w * 0.28, h * 0.44,
    );

    // Left loop/ovary curve
    path.cubicTo(
      w * 0.25, h * 0.34,
      w * 0.18, h * 0.30,
      w * 0.18, h * 0.42,
    );
    path.cubicTo(
      w * 0.18, h * 0.54,
      w * 0.10, h * 0.56,
      w * 0.06, h * 0.42,
    );
    path.cubicTo(
      w * 0.02, h * 0.26,
      w * 0.08, h * 0.14,
      w * 0.14, h * 0.14,
    );

    // Top bridge left to center dip
    path.cubicTo(
      w * 0.22, h * 0.14,
      w * 0.34, h * 0.22,
      w * 0.50, h * 0.26, // Center dip
    );

    // Top bridge right to right loop
    path.cubicTo(
      w * 0.66, h * 0.22,
      w * 0.78, h * 0.14,
      w * 0.86, h * 0.14,
    );

    // Right loop/ovary curve
    path.cubicTo(
      w * 0.92, h * 0.14,
      w * 0.98, h * 0.26,
      w * 0.94, h * 0.42,
    );
    path.cubicTo(
      w * 0.90, h * 0.56,
      w * 0.82, h * 0.54,
      w * 0.82, h * 0.42,
    );
    path.cubicTo(
      w * 0.82, h * 0.30,
      w * 0.75, h * 0.34,
      w * 0.72, h * 0.44,
    );

    // Right inner curve down to end at bottom-right leg
    path.cubicTo(
      w * 0.69, h * 0.54,
      w * 0.63, h * 0.76,
      w * 0.62, h * 0.90,
    );

    _cachedPath = path;
    _cachedMetrics = path.computeMetrics();
    return path;
  }

  void _triggerEducationalSweep() {
    if (_isSweeping) return;
    setState(() {
      _isSweeping = true;
    });
    _sweepController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isSweeping = false;
            _activePhaseName = 'Luteal Phase';
            _activeDayLabel = '19';
            _activePeriodLabel = '10 days';
          });
        }
      });
    });
  }

  Color _getCurrentPhaseColor(String phaseName) {
    if (phaseName.contains('Menstrual')) return const Color(0xFFDD0D22);
    if (phaseName.contains('Follicular')) return const Color(0xFFFF9B9E);
    if (phaseName.contains('Ovulation')) return const Color(0xFFFFB800);
    return const Color(0xFF6F42F5); // Luteal
  }

  @override
  Widget build(BuildContext context) {
    final state = BlushyOSProvider.of(context);
    final mode = ContextResolver.resolve(state.personalContext, state.wellbeingState);

    const canvasSize = Size(260, 95); 
    
    double activeProgress = _progressController.value;
    if (_userDragProgress >= 0.0) {
      activeProgress = _userDragProgress;
    } else if (_isSweeping) {
      activeProgress = _sweepController.value;
    }

    final activeColor = _getCurrentPhaseColor(_activePhaseName);

    if (widget.purePainterMode) {
      return Center(
        child: GestureDetector(
          onTap: _triggerEducationalSweep,
          onHorizontalDragUpdate: (details) {
            final localX = details.localPosition.dx;
            final normalized = (localX / canvasSize.width).clamp(0.0, 1.0);
            setState(() {
              _userDragProgress = normalized;
              _updateLabelsForProgress(normalized);
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _userDragProgress = -1.0;
              if (!_isSweeping) {
                _activePhaseName = 'Luteal Phase';
                _activeDayLabel = '19';
                _activePeriodLabel = '10 days';
              }
            });
          },
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _progressController,
                _pulseController,
                _loopController,
                _sweepController
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: SignatureCyclePathPainter(
                    path: _generateContinuousBlushyPath(canvasSize),
                    progress: activeProgress,
                    pulseVal: _pulseController.value,
                    loopAngle: _loopController.value * 2.0 * math.pi,
                    activeColor: activeColor,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BlushyColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: BlushyColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: BlushyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _getTitleForMode(mode),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: BlushyColors.text,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.info_outline_rounded, size: 14, color: BlushyColors.secondaryText),
                ],
              ),
              if (mode != CycleCardMode.wellbeing)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: BlushyColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 12, color: BlushyColors.text),
                        const SizedBox(width: 4),
                        Text(
                          'Edit Cycle',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: BlushyColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Dynamic Content based on mode
          _buildContentForMode(mode, activeColor),
          
          if (mode == CycleCardMode.predictable || mode == CycleCardMode.learning) ...[
            const Divider(color: BlushyColors.border, height: 32),
            Center(
              child: GestureDetector(
                onTap: _triggerEducationalSweep,
                onHorizontalDragUpdate: (details) {
                  final localX = details.localPosition.dx;
                  final normalized = (localX / canvasSize.width).clamp(0.0, 1.0);
                  setState(() {
                    _userDragProgress = normalized;
                    _updateLabelsForProgress(normalized);
                  });
                },
                onHorizontalDragEnd: (details) {
                  setState(() {
                    _userDragProgress = -1.0;
                    if (!_isSweeping) {
                      _activePhaseName = 'Luteal Phase';
                      _activeDayLabel = '19';
                      _activePeriodLabel = '10 days';
                    }
                  });
                },
                child: SizedBox(
                  width: canvasSize.width,
                  height: canvasSize.height,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _progressController,
                      _pulseController,
                      _loopController,
                      _sweepController
                    ]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: SignatureCyclePathPainter(
                          path: _generateContinuousBlushyPath(canvasSize),
                          progress: activeProgress,
                          pulseVal: _pulseController.value,
                          loopAngle: _loopController.value * 2.0 * math.pi,
                          activeColor: activeColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendDot('Menstrual', const Color(0xFFDD0D22)),
                _buildLegendDot('Follicular', const Color(0xFFFF9B9E)),
                _buildLegendDot('Ovulation', const Color(0xFFFFB800)),
                _buildLegendDot('Luteal', const Color(0xFF6F42F5)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  String _getTitleForMode(CycleCardMode mode) {
    switch(mode) {
      case CycleCardMode.predictable: return 'Your cycle journey';
      case CycleCardMode.variable: return 'Cycle variability detected';
      case CycleCardMode.learning: return 'Sia is learning your patterns';
      case CycleCardMode.wellbeing: return 'Daily Wellbeing';
      case CycleCardMode.lifeContext: return 'Life Stage Focus';
    }
  }

  Widget _buildContentForMode(CycleCardMode mode, Color activeColor) {
    switch (mode) {
      case CycleCardMode.predictable:
      case CycleCardMode.learning:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _activePhaseName,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mode == CycleCardMode.learning ? 'Gathering data... Day $_activeDayLabel' : 'Day $_activeDayLabel of 28',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BlushyColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Expected Period: August 2',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: BlushyColors.secondaryText,
                ),
              ),
            ],
          ),
        );
      case CycleCardMode.variable:
        return Text(
          "Your cycle length is varying. Log your symptoms daily so Sia can adjust predictions.",
          style: GoogleFonts.inter(fontSize: 14, color: BlushyColors.text),
        );
      case CycleCardMode.wellbeing:
        return Text(
          "Tracking is disabled. Focus on your daily energy, mood, and sleep.",
          style: GoogleFonts.inter(fontSize: 14, color: BlushyColors.text),
        );
      case CycleCardMode.lifeContext:
        return Text(
          "Your recommendations are adapted to your current life stage.",
          style: GoogleFonts.inter(fontSize: 14, color: BlushyColors.text),
        );
    }
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: BlushyColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

class SignatureCyclePathPainter extends CustomPainter {
  final Path path;
  final double progress;
  final double pulseVal;
  final double loopAngle;
  final Color activeColor;

  SignatureCyclePathPainter({
    required this.path,
    required this.progress,
    required this.pulseVal,
    required this.loopAngle,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold<double>(0.0, (prev, m) => prev + m.length);
    final activeLength = totalLength * progress;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, backgroundPaint);

    final progressPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    double accumulatedDistance = 0.0;
    Offset leadPosition = Offset.zero;

    for (var metric in metrics) {
      if (accumulatedDistance >= activeLength) break;
      
      final limit = (activeLength - accumulatedDistance).clamp(0.0, metric.length);
      final segmentPath = metric.extractPath(0.0, limit);
      canvas.drawPath(segmentPath, progressPaint);

      final tangent = metric.getTangentForOffset(limit);
      if (tangent != null) {
        leadPosition = tangent.position;
      }
      
      accumulatedDistance += metric.length;
    }

    if (leadPosition != Offset.zero) {
      Offset orbPosition = leadPosition;

      if (progress >= 0.99) {
        const loopRadius = 3.0;
        orbPosition = Offset(
          orbPosition.dx + math.cos(loopAngle) * loopRadius,
          orbPosition.dy + math.sin(loopAngle) * loopRadius,
        );
      }

      canvas.drawCircle(
        orbPosition,
        11.0,
        Paint()
          ..color = activeColor.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
      );

      canvas.drawCircle(
        orbPosition,
        7.5,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        orbPosition,
        7.5,
        Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );

      canvas.drawCircle(
        orbPosition,
        2.5,
        Paint()..color = activeColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SignatureCyclePathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.pulseVal != pulseVal ||
           oldDelegate.loopAngle != loopAngle ||
           oldDelegate.activeColor != activeColor;
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated water glass widget with wave effect
class WaterGlassWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final double width;

  const WaterGlassWidget({
    super.key,
    required this.progress,
    this.height = 300,
    this.width = 200,
  });

  @override
  State<WaterGlassWidget> createState() => _WaterGlassWidgetState();
}

class _WaterGlassWidgetState extends State<WaterGlassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Water fill with waves
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _WaterGlassPainter(
              progress: widget.progress,
              waveAnimation: _waveController,
            ),
          ),
          
          // Percentage text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              if (widget.progress >= 1.0)
                const Text(
                  'Goal Reached! 🎉',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterGlassPainter extends CustomPainter {
  final double progress;
  final Animation<double> waveAnimation;

  _WaterGlassPainter({
    required this.progress,
    required this.waveAnimation,
  }) : super(repaint: waveAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw glass outline - proper glass shape (wider at top)
    final glassPaint = Paint()
      ..color = Colors.blue.shade200.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final glassPath = Path()
      ..moveTo(size.width * 0.15, 0) // Top left
      ..lineTo(size.width * 0.25, size.height) // Bottom left
      ..lineTo(size.width * 0.75, size.height) // Bottom right
      ..lineTo(size.width * 0.85, 0) // Top right
      ..close();

    canvas.drawPath(glassPath, glassPaint);

    // Draw glass shine effect
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final shinePath = Path()
      ..moveTo(size.width * 0.17, size.height * 0.05)
      ..lineTo(size.width * 0.22, size.height * 0.95)
      ..lineTo(size.width * 0.27, size.height * 0.95)
      ..lineTo(size.width * 0.22, size.height * 0.05)
      ..close();
    
    canvas.drawPath(shinePath, shinePaint);

    // Draw water with waves
    if (progress > 0) {
      final waterHeight = size.height * progress;
      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0EA5E9),
            const Color(0xFF06B6D4),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final waterPath = Path();
      
      // Calculate water width at current level (accounting for glass taper)
      final waterY = size.height - waterHeight;
      final taperFactor = waterY / size.height; // 0 at top, 1 at bottom
      final leftX = size.width * (0.15 + (0.10 * taperFactor));
      final rightX = size.width * (0.85 - (0.10 * taperFactor));
      
      // Start from bottom left
      waterPath.moveTo(size.width * 0.25, size.height);
      
      // Left side of water
      waterPath.lineTo(leftX, waterY);
      
      // Draw wave on top
      final waveAmplitude = 4.0;
      final waveFrequency = 2.0;
      final waveOffset = waveAnimation.value * 2 * math.pi;

      for (double i = 0; i <= 50; i++) {
        final t = i / 50;
        final x = leftX + (rightX - leftX) * t;
        final wave = math.sin((t * waveFrequency * 2 * math.pi) + waveOffset) * waveAmplitude;
        waterPath.lineTo(x, waterY + wave);
      }

      // Right side and bottom
      waterPath.lineTo(rightX, waterY);
      waterPath.lineTo(size.width * 0.75, size.height);
      waterPath.close();

      canvas.drawPath(waterPath, waterPaint);

      // Add bubbles/sparkles
      if (progress >= 1.0) {
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..style = PaintingStyle.fill;
        
        // Multiple sparkles at different positions
        final sparkles = [
          Offset(size.width * 0.35, size.height * 0.3),
          Offset(size.width * 0.65, size.height * 0.5),
          Offset(size.width * 0.5, size.height * 0.7),
        ];
        
        for (final pos in sparkles) {
          final radius = 2 + (math.sin(waveAnimation.value * 2 * math.pi) * 1.5).abs();
          canvas.drawCircle(pos, radius, sparklePaint);
        }
      }
      
      // Add smaller bubbles when water is being added
      if (progress > 0 && progress < 1.0) {
        final bubblePaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;
        
        for (int i = 0; i < 3; i++) {
          final bubbleY = size.height - (waterHeight * 0.3) - (i * 30) + (waveAnimation.value * 20);
          if (bubbleY > waterY && bubbleY < size.height) {
            canvas.drawCircle(
              Offset(size.width * (0.3 + i * 0.2), bubbleY),
              2 + (waveAnimation.value * 1),
              bubblePaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_WaterGlassPainter oldDelegate) => true;
}

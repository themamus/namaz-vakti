// lib/presentation/screens/qibla/qibla_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/qibla_service.dart';
import '../../providers/prayer_times_provider.dart';
import '../../../core/theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  double? _heading;
  double _qiblaDirection = 0;
  bool _hasPermission = false;
  bool _isCalibrating = false;
  int _calibrationCount = 0;
  double? _latitude;
  double? _longitude;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initCompass();
  }

  void _initCompass() {
    final provider = context.read<PrayerTimesProvider>();
    if (provider.location != null) {
      _latitude = provider.location!.latitude;
      _longitude = provider.location!.longitude;
      _qiblaDirection = QiblaService.calculateQiblaDirection(
        latitude: _latitude!,
        longitude: _longitude!,
      );
    }

    FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
          _hasPermission = true;

          // Calibration detection - rapid changes indicate need for calibration
          _calibrationCount++;
          if (_calibrationCount > 50) {
            _calibrationCount = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double get _compassRotation {
    if (_heading == null) return 0;
    return -(_heading! * (math.pi / 180));
  }

  double get _qiblaRotation {
    if (_heading == null) return 0;
    return (_qiblaDirection - _heading!) * (math.pi / 180);
  }

  bool get _isPointingToQibla {
    if (_heading == null) return false;
    final diff = (_heading! - _qiblaDirection).abs() % 360;
    return diff < 5 || diff > 355;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimesProvider>();
    final location = provider.location;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Yönü'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Location info
              if (location != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.city,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                'Kıble yönü: ${_qiblaDirection.toStringAsFixed(1)}°',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                "Mekke'ye uzaklık: "
                                '${QiblaService.calculateDistanceToMecca(latitude: location.latitude, longitude: location.longitude).toStringAsFixed(0)} km',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Compass
              if (!_hasPermission)
                _buildPermissionWidget(context)
              else
                _buildCompass(context),

              const SizedBox(height: 24),

              // Status
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _isPointingToQibla
                      ? Colors.green.withOpacity(0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPointingToQibla
                        ? Colors.green
                        : theme.dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPointingToQibla
                          ? Icons.check_circle
                          : Icons.explore,
                      color: _isPointingToQibla ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPointingToQibla
                          ? '🕌 Kıble yönünü gösteriyorsunuz!'
                          : 'Telefonu çevirerek kıbleyi bulun',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _isPointingToQibla ? Colors.green : null,
                        fontWeight: _isPointingToQibla
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calibration tip
              Card(
                color: Colors.amber.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pusula kalibrasyonu için telefonu 8 şeklinde hareket ettirin',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass rose
          AnimatedBuilder(
            animation: _compassRotation != 0
                ? AlwaysStoppedAnimation(_compassRotation)
                : _pulseAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _compassRotation,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _CompassPainter(),
            ),
          ),

          // Qibla needle (always points to Mecca)
          Transform.rotate(
            angle: _qiblaRotation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🕌', style: TextStyle(fontSize: 24)),
                Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // Center dot
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _isPointingToQibla ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isPointingToQibla ? Colors.green : Colors.grey)
                      .withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),

          // Heading display
          Positioned(
            top: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _heading != null
                    ? '${_heading!.toStringAsFixed(0)}°'
                    : '--°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWidget(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.explore_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Pusula sensörü kullanılamıyor'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _initCompass,
          child: const Text('Tekrar Dene'),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final circlePaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Direction markers
    final directions = ['K', 'KD', 'D', 'GD', 'G', 'GB', 'B', 'KB'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < directions.length; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final isCardinal = i % 2 == 0;
      final markerRadius = radius - (isCardinal ? 24 : 32);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? Colors.red : Colors.grey.shade600,
          fontSize: isCardinal ? 14 : 10,
          fontWeight: isCardinal ? FontWeight.bold : FontWeight.normal,
        ),
      );
      textPainter.layout();

      final x = center.dx +
          markerRadius * math.cos(angle) -
          textPainter.width / 2;
      final y = center.dy +
          markerRadius * math.sin(angle) -
          textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }

    // Degree tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 45 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      final startX = center.dx + (radius - 10) * math.cos(angle);
      final startY = center.dy + (radius - 10) * math.sin(angle);
      final endX = center.dx + (radius - 10 - tickLength) * math.cos(angle);
      final endY = center.dy + (radius - 10 - tickLength) * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class CrtOverlay extends StatefulWidget {
  const CrtOverlay({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends State<CrtOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _flicker,
              builder: (context, _) =>
                  CustomPaint(painter: _CrtPainter(intensity: _flicker.value)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrtPainter extends CustomPainter {
  const _CrtPainter({required this.intensity});

  final double intensity;

  static const double _lineGap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += _lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0.55, 0.85, 1],
        ).createShader(Offset.zero & size),
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFF3DFF7A)
            .withValues(alpha: 0.012 + intensity * 0.012),
    );
  }

  @override
  bool shouldRepaint(_CrtPainter old) => old.intensity != intensity;
}

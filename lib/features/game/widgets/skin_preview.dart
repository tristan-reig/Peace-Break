import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../skins.dart';

class SkinScene extends StatelessWidget {
  const SkinScene({
    super.key,
    required this.paddle,
    required this.ball,
    this.showPaddle = true,
    this.showBall = true,
    this.height = 140,
  });

  final SkinStyle paddle;
  final SkinStyle ball;
  final bool showPaddle;
  final bool showBall;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.gameBg,
          border: Border.fromBorderSide(
            BorderSide(color: AppTheme.greenDim, width: 2),
          ),
        ),
        child: CustomPaint(
          painter: _ScenePainter(paddle, ball, showPaddle, showBall),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.paddle, this.ball, this.showPaddle, this.showBall);

  final SkinStyle paddle;
  final SkinStyle ball;
  final bool showPaddle;
  final bool showBall;

  @override
  void paint(Canvas canvas, Size size) {
    final alone = showPaddle != showBall;

    if (showBall) {
      paintBall(
        canvas,
        Offset(size.width / 2, alone ? size.height / 2 : size.height * 0.34),
        alone ? 28 : 18,
        ball,
      );
    }

    if (showPaddle) {
      paintPaddle(
        canvas,
        Rect.fromCenter(
          center: Offset(
            size.width / 2,
            alone ? size.height / 2 : size.height * 0.75,
          ),
          width: size.width * (alone ? 0.6 : 0.45),
          height: alone ? 24 : 18,
        ),
        paddle,
      );
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}

class SkinThumb extends StatelessWidget {
  const SkinThumb({
    super.key,
    required this.style,
    required this.isBall,
    this.size = 52,
  });

  final SkinStyle style;
  final bool isBall;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ThumbPainter(style, isBall),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.style, this.isBall);

  final SkinStyle style;
  final bool isBall;

  @override
  void paint(Canvas canvas, Size size) {
    if (isBall) {
      paintBall(
        canvas,
        Offset(size.width / 2, size.height / 2),
        size.width * 0.33,
        style,
      );
    } else {
      paintPaddle(
        canvas,
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.86,
          height: size.height * 0.28,
        ),
        style,
      );
    }
  }

  @override
  bool shouldRepaint(_ThumbPainter old) => true;
}

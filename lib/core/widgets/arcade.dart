import 'package:flutter/material.dart';

import '../theme.dart';

class ArcadeTitle extends StatelessWidget {
  const ArcadeTitle(
    this.text, {
    super.key,
    this.size = 22,
    this.color = AppTheme.green,
  });

  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    textAlign: TextAlign.center,
    style: AppTheme.title(size, color: color),
  );
}

class ArcadeFrame extends StatelessWidget {
  const ArcadeFrame({
    super.key,
    required this.child,
    this.color = AppTheme.greenDim,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.panel,
        border: Border.all(color: color, width: 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

class BlinkingText extends StatefulWidget {
  const BlinkingText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _c.drive(CurveTween(curve: Curves.easeInOut)),
    child: Text(widget.text, style: widget.style),
  );
}

class ArcadeTile extends StatelessWidget {
  const ArcadeTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.green,
    this.size = 92,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final tint = enabled ? color : AppTheme.textDim;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppTheme.panel,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: tint, width: 2),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: tint.withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
              child: Icon(icon, size: size * 0.44, color: tint),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: AppTheme.titleFont,
            fontSize: 7,
            color: tint,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

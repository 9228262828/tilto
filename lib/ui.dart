import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';

const navy = Color(0xFF101A2B);
const coral = Color(0xFFFF6B4A);
const aqua = Color(0xFF43D7C5);
const cream = Color(0xFFFFF6E9);
const panel = Color(0xFF1C2940);
const yellow = Color(0xFFFFD166);
const danger = Color(0xFFE86464);

ThemeData tiltoTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: coral,
      brightness: brightness,
      primary: coral,
      secondary: aqua,
    ),
    scaffoldBackgroundColor: dark ? navy : const Color(0xFFF5F2EC),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? panel : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

IconData modeIcon(GameMode mode) {
  switch (mode) {
    case GameMode.endless:
      return Icons.all_inclusive_rounded;
    case GameMode.rush60:
      return Icons.timer_rounded;
    case GameMode.oneFall:
      return Icons.heart_broken_rounded;
  }
}

class TiltoLogo extends StatelessWidget {
  final double size;

  const TiltoLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(size * .28),
        border: Border.all(color: aqua.withOpacity(.55), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -.16,
            child: Container(
              width: size * .58,
              height: size * .10,
              decoration: BoxDecoration(
                color: coral,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * .22,
            child: Icon(
              Icons.circle,
              color: aqua,
              size: size * .25,
            ),
          ),
        ],
      ),
    );
  }
}

class GameStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const GameStat({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        border: Border.all(color: color.withOpacity(.18)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class BalancePainter extends CustomPainter {
  final double tilt;
  final List<dynamic> pieces;

  BalancePainter({
    required this.tilt,
    required this.pieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final platformPaint = Paint()..color = coral;
    final basePaint = Paint()..color = aqua;
    final piecePaint = Paint()..color = cream;
    final accentPaint = Paint()..color = yellow;
    final shadowPaint = Paint()..color = Colors.black.withOpacity(.18);

    final center = Offset(
      size.width * (.5 + tilt * .045),
      size.height * .75,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt * .18);

    final board = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * .54,
        height: 18,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(board.shift(const Offset(0, 7)), shadowPaint);
    canvas.drawRRect(board, platformPaint);

    final base = Path()
      ..moveTo(-24, 14)
      ..lineTo(24, 14)
      ..lineTo(0, 54)
      ..close();
    canvas.drawPath(base, basePaint);
    canvas.restore();

    for (final p in pieces) {
      final x = (p.x as double) * size.width;
      final y = (p.y as double) * size.height;
      final r = (p.size as double) * size.width * .5;

      canvas.drawCircle(Offset(x + 4, y + 6), r, shadowPaint);
      canvas.drawCircle(Offset(x, y), r, piecePaint);
      canvas.drawCircle(
        Offset(x - r * .28, y - r * .28),
        max(2, r * .18),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BalancePainter oldDelegate) => true;
}

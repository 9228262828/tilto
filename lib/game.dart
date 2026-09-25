import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class TiltoGameController extends ChangeNotifier {
  static const tickMs = 16;
  static const rushDurationMs = 60000;

  final TiltoStore store;
  final GameMode mode;
  final Random random = Random();

  Timer? _ticker;
  int _lastSpawnMs = -1000;

  final List<BalancePiece> pieces = [];

  double tilt = 0;
  int elapsedMs = 0;
  int remainingMs = rushDurationMs;
  int score = 0;
  int landedCount = 0;
  int perfectCount = 0;
  int lives = 3;

  bool paused = false;
  bool gameOver = false;
  bool registered = false;

  TiltoGameController({
    required this.store,
    required this.mode,
  });

  double get rushProgress =>
      (remainingMs / rushDurationMs).clamp(0.0, 1.0).toDouble();

  void start() {
    _ticker?.cancel();
    pieces.clear();
    tilt = 0;
    elapsedMs = 0;
    remainingMs = rushDurationMs;
    score = 0;
    landedCount = 0;
    perfectCount = 0;
    lives = mode == GameMode.endless ? 3 : 1;
    paused = false;
    gameOver = false;
    registered = false;
    _lastSpawnMs = -1000;

    _ticker = Timer.periodic(
      const Duration(milliseconds: tickMs),
      (_) => _tick(),
    );

    notifyListeners();
  }

  void left() {
    if (paused || gameOver) return;
    tilt = (tilt - .14).clamp(-1.0, 1.0).toDouble();
    notifyListeners();
  }

  void right() {
    if (paused || gameOver) return;
    tilt = (tilt + .14).clamp(-1.0, 1.0).toDouble();
    notifyListeners();
  }

  void togglePause() {
    if (gameOver) return;
    paused = !paused;
    notifyListeners();
  }

  void _tick() {
    if (paused || gameOver) return;

    elapsedMs += tickMs;

    if (mode == GameMode.rush60) {
      remainingMs -= tickMs;
      if (remainingMs <= 0) {
        remainingMs = 0;
        _finish();
        return;
      }
    }

    tilt *= .991;
    if (tilt.abs() < .005) tilt = 0;

    final spawnGap = max(500, 1200 - (elapsedMs ~/ 140));
    if (elapsedMs - _lastSpawnMs >= spawnGap) {
      _spawn();
      _lastSpawnMs = elapsedMs;
    }

    _updatePieces();
    score += 1;
    notifyListeners();
  }

  void _spawn() {
    pieces.add(
      BalancePiece(
        x: .24 + random.nextDouble() * .52,
        y: -.06,
        vy: .0040 + random.nextDouble() * .0014,
        drift: (random.nextDouble() - .5) * .0008,
        size: .055 + random.nextDouble() * .02,
        landed: false,
      ),
    );
  }

  void _updatePieces() {
    const platformY = .75;
    const platformHalfWidth = .27;
    final fallen = <BalancePiece>[];

    for (final piece in pieces) {
      if (!piece.landed) {
        piece.y += piece.vy;
        piece.vy += .00007;

        if (piece.y >= platformY - piece.size * .5) {
          final center = .5 + tilt * .045;
          final inside = (piece.x - center).abs() <= platformHalfWidth;

          if (inside) {
            piece.landed = true;
            piece.y = platformY - piece.size * .5;
            piece.vy = 0;
            landedCount++;

            if (tilt.abs() <= .12) {
              perfectCount++;
              score += 30;
            } else {
              score += 15;
            }
          }
        }
      } else {
        piece.x += piece.drift + tilt * .00145;
        piece.drift += tilt * .00003;
        piece.drift *= .997;

        final center = .5 + tilt * .045;
        final allowed = platformHalfWidth - piece.size * .10;

        if ((piece.x - center).abs() > allowed) {
          piece.landed = false;
          piece.vy = .0042;
        }
      }

      if (piece.y > 1.08 || piece.x < -.12 || piece.x > 1.12) {
        fallen.add(piece);
      }
    }

    for (final piece in fallen) {
      pieces.remove(piece);
      _handleFall();
      if (gameOver) break;
    }
  }

  void _handleFall() {
    if (mode == GameMode.oneFall) {
      _finish();
      return;
    }

    if (mode == GameMode.endless) {
      lives--;
      if (lives <= 0) _finish();
      return;
    }

    score = max(0, score - 25);
  }

  Future<void> _finish() async {
    if (gameOver) return;
    gameOver = true;
    paused = false;
    _ticker?.cancel();

    if (!registered) {
      registered = true;
      await store.registerRun(
        mode: mode,
        score: score,
        landed: landedCount,
        perfects: perfectCount,
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

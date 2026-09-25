enum GameMode { endless, rush60, oneFall }

String modeName(GameMode mode) {
  switch (mode) {
    case GameMode.endless:
      return 'Endless';
    case GameMode.rush60:
      return '60 Sec Challenge';
    case GameMode.oneFall:
      return 'One Fall';
  }
}

String modeSubtitle(GameMode mode) {
  switch (mode) {
    case GameMode.endless:
      return 'Keep balancing with 3 lives.';
    case GameMode.rush60:
      return 'Survive and score for 60 seconds.';
    case GameMode.oneFall:
      return 'The first dropped piece ends the run.';
  }
}

class BalancePiece {
  double x;
  double y;
  double vy;
  double drift;
  double size;
  bool landed;

  BalancePiece({
    required this.x,
    required this.y,
    required this.vy,
    required this.drift,
    required this.size,
    required this.landed,
  });
}

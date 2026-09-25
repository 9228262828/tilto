import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class TiltoStore extends ChangeNotifier {
  static const _darkKey = 'tilto_dark_v1';
  static const _hapticKey = 'tilto_haptic_v1';
  static const _endlessKey = 'tilto_endless_best_v1';
  static const _rushKey = 'tilto_rush_best_v1';
  static const _oneFallKey = 'tilto_onefall_best_v1';
  static const _gamesKey = 'tilto_games_v1';
  static const _landedKey = 'tilto_landed_v1';
  static const _perfectKey = 'tilto_perfect_v1';

  bool ready = false;
  bool darkMode = true;
  bool haptics = true;
  int endlessBest = 0;
  int rushBest = 0;
  int oneFallBest = 0;
  int gamesPlayed = 0;
  int totalLanded = 0;
  int perfectBalances = 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_darkKey) ?? true;
    haptics = prefs.getBool(_hapticKey) ?? true;
    endlessBest = prefs.getInt(_endlessKey) ?? 0;
    rushBest = prefs.getInt(_rushKey) ?? 0;
    oneFallBest = prefs.getInt(_oneFallKey) ?? 0;
    gamesPlayed = prefs.getInt(_gamesKey) ?? 0;
    totalLanded = prefs.getInt(_landedKey) ?? 0;
    perfectBalances = prefs.getInt(_perfectKey) ?? 0;
    ready = true;
    notifyListeners();
  }

  Future<void> registerRun({
    required GameMode mode,
    required int score,
    required int landed,
    required int perfects,
  }) async {
    gamesPlayed++;
    totalLanded += landed;
    perfectBalances += perfects;

    if (mode == GameMode.endless && score > endlessBest) {
      endlessBest = score;
    } else if (mode == GameMode.rush60 && score > rushBest) {
      rushBest = score;
    } else if (mode == GameMode.oneFall && score > oneFallBest) {
      oneFallBest = score;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_endlessKey, endlessBest);
    await prefs.setInt(_rushKey, rushBest);
    await prefs.setInt(_oneFallKey, oneFallBest);
    await prefs.setInt(_gamesKey, gamesPlayed);
    await prefs.setInt(_landedKey, totalLanded);
    await prefs.setInt(_perfectKey, perfectBalances);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    haptics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, value);
    notifyListeners();
  }

  Future<void> reset() async {
    endlessBest = 0;
    rushBest = 0;
    oneFallBest = 0;
    gamesPlayed = 0;
    totalLanded = 0;
    perfectBalances = 0;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_endlessKey, _rushKey, _oneFallKey, _gamesKey, _landedKey, _perfectKey]) {
      await prefs.remove(key);
    }
    notifyListeners();
  }
}

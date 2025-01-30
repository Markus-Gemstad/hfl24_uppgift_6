import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void changeThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

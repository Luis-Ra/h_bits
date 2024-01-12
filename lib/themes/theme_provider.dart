import 'package:flutter/material.dart';
import 'package:h_bits/themes/dark_mode.dart';
import 'package:h_bits/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  //initially goin to be lightMode
  ThemeData _themeData = lightMode;
  // get the current theme
  ThemeData get themeData => _themeData;
  // is current theme dark mode

  bool get isDarkMode => _themeData == darkMode;

  // set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}

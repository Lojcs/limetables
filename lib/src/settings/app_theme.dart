import 'package:flutter/material.dart';

class LimetablesTheme {
  static const textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontSize: 40,
    ),
  );
  static ThemeData lightTheme = ThemeData.localize(
    ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
    ),
    textTheme,
  );
  static ThemeData darkTheme = ThemeData.localize(
    ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    textTheme,
  );
}

import 'package:flutter/material.dart';

class AppTheme {
  static final Color primaryColor = Colors.green.shade700;

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    buttonTheme: ButtonThemeData(buttonColor: primaryColor),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
    ),
  );
}

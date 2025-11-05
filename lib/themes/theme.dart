import 'package:flutter/material.dart';
import 'package:homefin/themes/TableColors.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A5ACD)),
  extensions: [
    const TableColors(
      headerBackground: const Color(0xFF6A5ACD),
      headerTextColor:Color(0xFFF5F5F5),
      leftColumnBackground: Color(0xFFDDE3FF), // 🔹 Indigo-tinted
      leftColumnTextColor: Color(0xFF212121),
      rowEvenBackground: Color(0xFFF9FAFB),
      rowOddBackground: Color(0xFFFFFFFF),
      borderColor: Color(0xFFCFD8DC),
      hoverColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF212121),
    ),
  ],
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
  ),
  extensions: [
    const TableColors(
      headerBackground: Color(0xFF1E1E2F),
      headerTextColor:Color(0xFFF5F5F5),
      leftColumnBackground: Color(0xFFDDE3FF), // 🔹 Indigo-tinted
      leftColumnTextColor: Color(0xFF1A237E),
      rowEvenBackground: Color(0xFF2A2A40),
      rowOddBackground: Color(0xFF24243A),
      borderColor: Color(0xFF3C3C5A),
      hoverColor: Color(0xFF30305A),
      textColor: Color(0xFFF5F5F5),
    ),
  ],
);
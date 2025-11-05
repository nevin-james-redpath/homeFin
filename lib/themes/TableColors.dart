import 'package:flutter/material.dart';

class TableColors extends ThemeExtension<TableColors> {
  final Color headerBackground;
  final Color headerTextColor;
  final Color leftColumnBackground;
final Color leftColumnTextColor;
  final Color rowEvenBackground;
  final Color rowOddBackground;
  final Color borderColor;
  final Color hoverColor;
  final Color textColor;

  const TableColors({
    required this.headerBackground,
    required this.headerTextColor,
    required this.leftColumnBackground,
    required this.leftColumnTextColor,
    required this.rowEvenBackground,
    required this.rowOddBackground,
    required this.borderColor,
    required this.hoverColor,
    required this.textColor,
  });

  @override
  TableColors copyWith({
    Color? headerBackground,
    Color? headerTextColor,
    Color? leftColumnBackground,
    Color? leftColumnTextColor,
    Color? rowEvenBackground,
    Color? rowOddBackground,
    Color? borderColor,
    Color? hoverColor,
    Color? textColor,
  }) {
    return TableColors(
      headerBackground: headerBackground ?? this.headerBackground,
      headerTextColor:headerTextColor??this.headerTextColor,
      leftColumnBackground:leftColumnBackground??this.leftColumnBackground,
      leftColumnTextColor:leftColumnTextColor??this.leftColumnTextColor,
      rowEvenBackground: rowEvenBackground ?? this.rowEvenBackground,
      rowOddBackground: rowOddBackground ?? this.rowOddBackground,
      borderColor: borderColor ?? this.borderColor,
      hoverColor: hoverColor ?? this.hoverColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  TableColors lerp(ThemeExtension<TableColors>? other, double t) {
    if (other is! TableColors) return this;
    return TableColors(
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      headerTextColor:Color.lerp(headerTextColor, other.headerTextColor, t)!,
      leftColumnBackground:Color.lerp(leftColumnBackground,other.leftColumnBackground,t)!,
      leftColumnTextColor:Color.lerp(leftColumnTextColor,other.leftColumnTextColor,t)!,
      rowEvenBackground: Color.lerp(rowEvenBackground, other.rowEvenBackground, t)!,
      rowOddBackground: Color.lerp(rowOddBackground, other.rowOddBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
}

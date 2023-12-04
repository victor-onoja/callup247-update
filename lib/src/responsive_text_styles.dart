import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle responsiveTextStyle(BuildContext context, double fontSize,
    Color? textColor, FontWeight? fontWeight) {
  double screenWidth = MediaQuery.sizeOf(context).width;

  // You can adjust these factors based on your design and responsiveness needs
  double textScaleFactor = screenWidth > 600 ? 1.25 : 1.0;

  return GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: fontSize * textScaleFactor,
      color: textColor,
      fontWeight: fontWeight,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //
  ThemeData lightTheme() {
    return ThemeData(
      // fontFamily: GoogleFonts.iBMPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      fontFamily: GoogleFonts.nunito().fontFamily,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: Colors.grey[50],
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          color: Colors.black,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),
      // brightness: Brightness.light,
      // CUSTOMIZE showDatePicker Colors
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
      ),
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      highlightColor: Colors.grey[400],
      colorScheme: ColorScheme.light(
        primary: AppColor.primaryColor,
        secondary: AppColor.accentColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColor.primaryMaterialColor,
        surface: Colors.white,
      ),
      useMaterial3: false,
    );
  }

  //
  ThemeData darkTheme() {
    return ThemeData(
      // fontFamily: GoogleFonts.iBMPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      fontFamily: GoogleFonts.nunito().fontFamily,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: Colors.grey[700],
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.black,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: AppColor.accentColor,
        brightness: Brightness.dark,
        // primary: AppColor.primaryColor,
        primary: AppColor.primaryMaterialColor,
        surface: Colors.grey[850],
      ),
      useMaterial3: false,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.grey.shade900,

        // Header (Sun, Dec 16)
        headerForegroundColor: Colors.white,
        headerBackgroundColor: Colors.deepPurple,

        // Days text
        dayForegroundColor:
        MaterialStateProperty.all(Colors.white),

        // Today border color
        todayBorder: BorderSide(color: Colors.deepPurple),

        // Weekday labels (S M T W T F S)
        weekdayStyle: TextStyle(
          color: Colors.white,
        ),

        // Year picker text
        yearForegroundColor:
        MaterialStateProperty.all(Colors.white),

        confirmButtonStyle: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: AppColor.accentColor,
            ),
          ),
        ),

        cancelButtonStyle: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: AppColor.accentColor,
            ),
          ),
        ),

        rangePickerHeaderHeadlineStyle: TextStyle(
          color: Colors.white,
        ),

        rangePickerHeaderHelpStyle: TextStyle(
          color: Colors.white,
        ),

        toggleButtonTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

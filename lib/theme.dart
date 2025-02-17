import 'package:flutter/material.dart';

// LIGHT
const backgroundLight = Colors.white;
const plainSurfaceBeginLight = Color.fromARGB(255, 255, 122, 40);
const plainSurfaceEndLight = Color.fromARGB(255, 208, 16, 222);
const specialColorLight = Color.fromARGB(255, 208, 203, 182);
const paddingColorLight = Color.fromARGB(255, 208, 203, 182);
const paddingColorLight2 = Color.fromARGB(255, 78, 155, 255);

// DARK
const backgroundDark = Color.fromARGB(133, 42, 41, 44);
const plainSurfaceBeginDark = Color.fromARGB(255, 255, 122, 40);
const plainSurfaceEndDark = Color.fromARGB(255, 208, 16, 222);
const specialColorDark = Color.fromARGB(255, 208, 203, 182);
const paddingColorDark = Colors.black;

const error = Colors.red;
const scaffoldBackground = Colors.white;
const generalColor = Colors.white;
const surface = Color.fromARGB(255, 65, 66, 94);
const brithness = Brightness.dark;
const buttonActiveColor1 = Color.fromARGB(255, 65, 66, 94);
const buttonActiveColor2 = Color.fromARGB(255, 65, 66, 94);
const buttonInactiveColor1 = Color(0xFF352F44);
const buttonInactiveColor2 = Color(0xFF352F44);
const buttonIconColor = Colors.white;
const buttonTextColor = Colors.white;
const shadowColorLight = Color.fromARGB(255, 65, 66, 94);
const shadowColorDark = Color(0xFF352F44);
const toogleActiveColor = Colors.green;
const toogleActiveTrackColor = Colors.lightGreen;
const toogleInactiveThumbColor = Colors.white;
const toogleInactiveTrackColor = Colors.white;
const textColor = Color.fromARGB(255, 4, 7, 47);
const textColor2 = Colors.white;
const textColor3 = Color(0xFF352F44);
const tileColor = Color.fromARGB(255, 4, 7, 47);
const tileColor2 = Color.fromARGB(255, 208, 203, 182);
const messageSent = Color.fromARGB(255, 3, 37, 66);
const messageReceive = Color.fromARGB(255, 56, 56, 56);
const textFieldFillColor = Color.fromARGB(255, 4, 7, 47);
const textFieldHintColor = Colors.white;
const textFieldEnableBorderColor = Colors.white;
const textFieldFocusBorderColor = Colors.white;
const separatorColor = Colors.white;
const navBarSelectedItemColor = Colors.white;
const navBarUnselectedItemColor = Colors.white;
const sliderThumbColor = Colors.white;
const sliderActiveColor = Colors.blue;
const sliderInactiveColor = Colors.white;
const progressBarColor = Colors.white;
const maintenanceTextColor = Colors.white;

ThemeData darkStyle = ThemeData(
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 36, 36, 37),
        foregroundColor: Colors.white),
    bottomAppBarTheme: const BottomAppBarTheme(
        surfaceTintColor: Color.fromARGB(255, 65, 66, 94)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey),
    listTileTheme: const ListTileThemeData(
      // tileColor: Color.fromARGB(255, 65, 66, 94),
      titleTextStyle: TextStyle(color: Colors.white),
      subtitleTextStyle: TextStyle(color: Colors.white),
      textColor: Colors.white,
      iconColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          Colors.blue,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: Colors.white),
      labelStyle: const TextStyle(color: Colors.white),
      fillColor: const Color.fromARGB(255, 36, 36, 37),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10.0),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge:
          TextStyle(fontSize: 20, color: Color.fromARGB(255, 65, 66, 94)),
      titleMedium: TextStyle(fontSize: 16, color: Colors.white),
      titleSmall: TextStyle(fontSize: 16, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 16, color: Colors.white),
      headlineSmall: TextStyle(fontSize: 16, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 20, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 18, color: Colors.white),
      bodySmall: TextStyle(fontSize: 16, color: Colors.white),
      labelLarge: TextStyle(fontSize: 16, color: Colors.white),
      labelSmall: TextStyle(fontSize: 16, color: Colors.white),
    ),
    colorScheme: const ColorScheme(
      primary: Colors.black,
      primaryContainer: Colors.black,
      inversePrimary: Colors.black,
      secondary: Colors.black,
      secondaryContainer: Colors.black,
      surface: Colors.black,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ));

ThemeData lightStyle = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 65, 66, 94),
      foregroundColor: Colors.white),
  bottomAppBarTheme: const BottomAppBarTheme(
      surfaceTintColor: Color.fromARGB(255, 65, 66, 94)),
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.white,
    titleTextStyle: TextStyle(color: Colors.black),
    subtitleTextStyle: TextStyle(color: Colors.black),
    iconColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(color: Colors.white),
    labelStyle: const TextStyle(color: Colors.white),
    fillColor: const Color(0xFF352F44),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10.0),
    ),
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 20, color: Color.fromARGB(255, 65, 66, 94)),
    titleMedium: TextStyle(fontSize: 16, color: Colors.black),
    titleSmall: TextStyle(fontSize: 16, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 16, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 16, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 20, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 18, color: Color.fromARGB(255, 4, 7, 47)),
    bodySmall: TextStyle(fontSize: 16, color: Colors.black),
    labelLarge: TextStyle(fontSize: 16, color: Colors.black),
    labelSmall: TextStyle(fontSize: 16, color: Colors.black),
  ),
  // colorScheme: const ColorScheme(
  //   primary: Color(0xFF352F44),
  //   primaryContainer: Colors.white,
  //   inversePrimary: Colors.white,
  //   secondary: Colors.white,
  //   secondaryContainer: Colors.white,
  //   surface: Colors.white,
  //   background: Colors.grey,
  //   error: error,
  //   onPrimary: Colors.white,
  //   onSecondary: Colors.white,
  //   onSurface: Colors.white,
  //   onBackground: Colors.white,
  //   onError: Colors.white,
  //   brightness: Brightness.dark,
  // )
);

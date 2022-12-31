import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppTheme {
  TextTheme myTextTheme = const TextTheme();

  get darkTheme => ThemeData.dark().copyWith(
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ButtonStyle(
        // foregroundColor: const MaterialStatePropertyAll(Colors.white),
        //     backgroundColor: MaterialStatePropertyAll(Colors.grey[700]),
        //   ),
        // ),
        // indicatorColor: Colors.green,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.grey,
          // circularTrackColor: Colors.green,
        ),
        // scaffoldBackgroundColor: Colors.black,
        // floatingActionButtonTheme:
        //     const FloatingActionButtonThemeData(backgroundColor: Colors.white),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.grey[700],
          onPrimary: Colors.white,
          secondary: Colors.white,
        ),
        // textTheme: ThemeData.dark().textTheme.apply()
      );

  get redTheme => ThemeData(
        primarySwatch: Colors.red,
      );
}

final themeProvider = StateProvider<ThemeData>((ref) {
  if (ThemeMode.system == ThemeMode.dark) {
    return AppTheme().darkTheme;
  } else {
    return AppTheme().redTheme;
  }
});

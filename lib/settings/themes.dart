import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'themes.g.dart';

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

@riverpod
class ThemeManager extends _$ThemeManager {
  // ThemeManager() {
  //   initTheme();
  // }

  // initTheme() async {
  //   await _loadPrefs();
  //   FlutterNativeSplash.remove();
  // }

  late SharedPreferences _pref;

  final String keyTheme = "theme";

  String _theme = "dark";

  _initPrefs() async {
    _pref = await SharedPreferences.getInstance();
  }

  _loadPrefs() async {
    await _initPrefs();
    _theme = _pref.getString(keyTheme) ?? "dark";
  }

  _savePrefs() async {
    await _initPrefs();
    _pref.setString(keyTheme, _theme);
  }

  setTheme(String newTheme) async {
    _theme = newTheme;
    _savePrefs();
    state = AsyncValue.data(await build());
  }

  @override
  FutureOr<ThemeData> build() async {
    await _loadPrefs();
    debugPrint("Ayo $_theme");
    switch (_theme) {
      case "dark":
        return AppTheme().darkTheme;
      case "red":
        return AppTheme().redTheme;
      default:
        if (ThemeMode.system == ThemeMode.dark) {
          return AppTheme().darkTheme;
        } else {
          return AppTheme().redTheme;
        }
    }
  }
}

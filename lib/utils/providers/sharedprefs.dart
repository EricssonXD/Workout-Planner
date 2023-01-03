// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// part 'sharedprefs.g.dart';

// class SettingsManager {
//   late SharedPreferences _pref;

//   SettingsManager() {
//     _loadFromPrefs();
//   }

//   String? _theme = "dark";
//   get theme => _theme;

//   _initPrefs() async {
//     _pref = await SharedPreferences.getInstance();
//   }

//   _loadFromPrefs() async {
//     await _initPrefs();
//     _theme = _pref.getString("theme");
//   }

//   saveToPrefs() async {
//     await _initPrefs();
//   }
// }

// @riverpod
// class ThemeNotifier extends _$ThemeNotifier {
//   late SharedPreferences _pref;
//   String _theme = "dark";

//   _initPrefs() async {
//     _pref = await SharedPreferences.getInstance();
//   }

//   @override
//   Future<String> build() async {
//     await _initPrefs();
//     _theme = _pref.getString("theme") ?? "dark";
//     return _theme;
//   }
// }

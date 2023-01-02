import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/home/screen_home.dart';
import 'package:workoutplanner/settings/themes.dart';

Future main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // IsarServices();

  runApp(const ProviderScope(
      child: App())); //Wrap in provider scope for riverpod to work
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: ref.watch(themeProvider),
    );
  }
}

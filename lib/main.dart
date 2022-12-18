import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'home/screen_home.dart';

Future main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // IsarServices();

  runApp(const ProviderScope(
      child: App())); //Wrap in provider scope for riverpod to work
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

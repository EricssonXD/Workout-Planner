import 'package:flutter/material.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'home/index.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ExerciseAdapter());
  await Hive.openBox<Exercise>('exercise');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

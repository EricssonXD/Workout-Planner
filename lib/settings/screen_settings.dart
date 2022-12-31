import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/settings/themes.dart';
import 'package:workoutplanner/utils/providers/isar.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';

class SettingScreen extends StatefulHookConsumerWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool _isDarkTheme = true;

  @override
  void initState() {
    if (ref.read(themeProvider).colorScheme.primary == Colors.grey[700]) {
      _isDarkTheme = true;
    } else {
      _isDarkTheme = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Delete all Exercise"),
            onTap: () => ref
                .watch(exerciseManagerProvider.future)
                .then((value) => value.deleteAllExercise()),
          ),
          ListTile(
            title: const Text("Delete all Workouts"),
            onTap: () => ref
                .watch(workoutManagerProvider.future)
                .then((value) => value.deleteAllWorkout()),
          ),
          ListTile(
            title: const Text("Clear all Data"),
            onTap: () => ref
                .watch(isarInstanceProvider.future)
                .then((value) => value.writeTxn(() => value.clear())),
          ),
          SwitchListTile(
            value: _isDarkTheme,
            title: const Text("Dark Theme"),
            onChanged: (value) {
              setState(() {
                _isDarkTheme = value;
              });
              value
                  ? ref.read(themeProvider.notifier).state =
                      AppTheme().darkTheme
                  : ref.read(themeProvider.notifier).state =
                      AppTheme().redTheme;
            },
          ),
        ],
      ),
    );
  }
}

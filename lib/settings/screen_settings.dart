import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/utils/providers/isar.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';

class SettingScreen extends HookConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            title: const Text("Delete all Wworkouts"),
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
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:workoutplanner/exercise_list/screen_exercise_list.dart';
import 'package:workoutplanner/testing/screen_test.dart';
import '../workout_list/screen_workout_list.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkoutList(),
                ),
              ),
              child: const Text("Workouts"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ExerciseList(),
                ),
              ),
              child: const Text("Exercises"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TestScreen(),
                ),
              ),
              child: const Text("Test"),
            )
          ],
        ),
      ),
    );
  }
}

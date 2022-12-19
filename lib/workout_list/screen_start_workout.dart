import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/workout_list/models/workouts.dart';

class StartWorkoutScreen extends ConsumerStatefulWidget {
  const StartWorkoutScreen({super.key, required this.workout});

  final Workout workout;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends ConsumerState<StartWorkoutScreen> {
  late final Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      bottomNavigationBar: BottomAppBar(
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              completeButton(),
            ],
          )),
    );
  }

  Widget completeButton() {
    return Expanded(
      child: ElevatedButton(
          style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                  BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Complete")),
    );
  }
}

import 'dart:async';

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
  late final List<WorkoutItem> rundown;

  late WorkoutItem nextItem;
  late WorkoutItem currentItem;
  int currentIndex = 0;
  bool workoutFinished = false;

  Timer timer = Timer(const Duration(seconds: 0), () {});
  int timerLeft = 60;
  bool overTime = false;
  bool resting = false;

  void rest(int restTime) {
    resting = true;
    startTimer(restTime);
  }

  void startTimer(int? seconds) {
    overTime = false;
    setState(() {
      timerLeft = seconds ?? timerLeft;
    });
    stopTimer();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timerLeft--;
        if (timerLeft <= 0) {
          overTime = true;
        }
      });
    });
  }

  void stopTimer() {
    timer.cancel();
  }

  void previousTask() {
    stopTimer();
    setState(() {
      // print("Index $currentIndex => ${currentIndex - 1}");
      currentIndex--;
      nextItem = currentItem;
      currentItem = rundown[currentIndex];
      resting = false;
      workoutFinished = false;
    });
  }

  void nextTask() {
    setState(() {
      currentItem = nextItem;
      // print("Index $currentIndex => ${currentIndex + 1}");
      currentIndex++;
      if (currentIndex < rundown.length - 1) {
        nextItem = rundown[currentIndex + 1];
      } else {
        workoutFinished = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    workout = widget.workout;

    List<WorkoutItem> tempList = [];
    for (int i = 0; i < workout.workoutItems.length; i++) {
      for (int j = 0; j < workout.workoutItems[i].sets; j++) {
        WorkoutItem item = WorkoutItem().from(workout.workoutItems[i]);
        item.sets = j + 1;
        tempList.add(item);
      }
    }

    rundown = tempList;
    currentItem = rundown[0];

    if (currentItem.exerciseCountType == ExerciseRepType.timed) {
      startTimer(currentItem.reps);
    }

    if (rundown.length != 1) {
      nextItem = rundown[1];
    } else {
      nextItem = currentItem;
      workoutFinished = true;
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
            previousButton(),
            completeButton(),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          currentExercise(),
          resting ? timerWidget() : exerciseProgress(),
          nextExercise(),
        ],
      ),
    );
  }

  Widget exerciseProgress() {
    switch (currentItem.exerciseCountType) {
      case ExerciseRepType.reps:
        return Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "${currentItem.reps} Reps",
              style: const TextStyle(fontSize: 80),
            ),
          ),
        );
      case ExerciseRepType.timed:
        if (!timer.isActive) {
          startTimer(currentItem.reps);
        }
        return timerWidget();
      default:
        return Container();
    }
  }

  Widget timerWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          overTime ? (timerLeft * -1).toString() : timerLeft.toString(),
          style: TextStyle(fontSize: 80, color: overTime ? Colors.red : null),
        ),
      ),
    );
  }

  Widget currentExercise() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
            resting
                ? "Rest Time"
                : "Current Exercise: ${currentItem.name} Set ${currentItem.sets.toString()}",
            style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget nextExercise() {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              workoutFinished
                  ? "Done!"
                  : "Next Exercise: ${nextItem.name} • ${nextItem.reps} Reps",
              style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  Widget completeButton() {
    return Expanded(
      flex: 2,
      child: ElevatedButton(
          style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                  BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
          onPressed: () {
            if (workoutFinished) {
              Navigator.of(context).pop();
              return;
            }
            if (resting) {
              stopTimer();
              nextTask();
              resting = false;
            } else {
              rest(currentItem.restTime);
            }
          },
          child: Text(resting
              ? "Proceed to Next Exercise"
              : (workoutFinished ? "Complete Workout" : "Complete"))),
    );
  }

  Widget previousButton() {
    if (currentIndex == 0) {
      return Container();
    }
    return Expanded(
      flex: 1,
      child: ElevatedButton(
          style: const ButtonStyle(
              elevation: MaterialStatePropertyAll(0),
              shape: MaterialStatePropertyAll(
                  BeveledRectangleBorder(borderRadius: BorderRadius.zero))),
          onPressed: () {
            previousTask();
          },
          child: const Text("Previous")),
    );
  }
}

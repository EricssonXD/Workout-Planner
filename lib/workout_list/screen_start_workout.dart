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
  WorkoutItem? previousItem;
  int currentIndex = 0;
  int currentSet = 0;
  int nextSet = 0;
  bool workoutFinished = false;

  Timer timer = Timer(const Duration(seconds: 0), () {});
  late int timerLeft;
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
      nextItem = currentItem;
      currentItem = previousItem ?? currentItem;
      nextSet = currentSet;
      currentSet--;
    });
  }

  void nextTask() {
    setState(() {
      if (!(currentIndex == 0 && currentSet == 0)) {
        print("object");
        previousItem = currentItem;
      }
      currentItem = nextItem;
      nextSet++;
      currentSet = nextSet;
      if (nextSet < rundown[currentIndex].sets) {
      } else {
        if (currentIndex < rundown.length - 1) {
          currentSet = nextSet;
          nextSet = 0;
          currentIndex++;
          nextItem = rundown[currentIndex];
        } else {
          //Workout Finished
          workoutFinished = true;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    workout = widget.workout;
    rundown = workout.workoutItems;
    nextItem = rundown[currentIndex];
    currentItem = nextItem;
    nextTask();
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
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "${currentItem.reps} Reps",
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
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
            "Current Exercise: ${currentItem.name} Set ${currentSet.toString()}",
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
    if (previousItem == null || currentSet == 1) {
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

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:workoutplanner/utils/notification_manager.dart';
import 'package:workoutplanner/utils/widgets/aleart_dialogs.dart';
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
  late final List<_RunDownItem> rundown;

  late _RunDownItem nextItem;
  late _RunDownItem currentItem;
  int currentIndex = 0;
  bool resting = false;
  bool workoutFinished = false;

  Timer timer = Timer(const Duration(seconds: 0), () {});
  int timerLeft = 60;
  int maxTime = 60;
  bool overTime = false;

  OverlayEntry? completeAnimation;

  final alarm = AudioPlayer();

  void rest(int restTime) {
    resting = true;
    startTimer(restTime);
  }

  void startTimer(int? seconds) {
    overTime = false;
    maxTime = seconds ?? maxTime;
    setState(() {
      timerLeft = seconds ?? timerLeft;
    });
    stopTimer();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timerLeft--;
        if (timerLeft <= 0) {
          overTime = true;
          if (timerLeft == 0) {
            playAlarm();
            resting ? NotificationManager.restTimeOver() : null;
          }
        }
      });
    });
  }

  Future<void> playAlarm() async {
    alarm.setReleaseMode(ReleaseMode.loop);
    alarm.play(AssetSource('audio/rick_roll.mp3'));
  }

  void stopTimer() {
    alarm.stop();
    timer.cancel();
  }

  void previousTask() {
    stopTimer();
    setState(() {
      currentIndex--;
      workoutFinished = false;
      if (!resting) {
        nextItem = currentItem;
        currentItem = rundown[currentIndex];
      }
      resting = false;
    });
  }

  void nextTask() {
    stopTimer();
    setState(() {
      currentItem = nextItem;
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

    List<_RunDownItem> tempList = [];
    for (int i = 0; i < workout.workoutItems.length; i++) {
      for (int j = 0; j < workout.workoutItems[i].sets; j++) {
        WorkoutItem item = WorkoutItem().from(workout.workoutItems[i]);
        tempList.add(_RunDownItem(
          workoutItem: item,
          setNow: j + 1,
          itemIndex: i,
        ));
      }
    }

    rundown = tempList;
    currentItem = rundown[0];

    if (currentItem.repType == ExerciseRepType.timed) {
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
    alarm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showYesNoDialog(context,
            title: "Are you sure you want to quit?");
      },
      child: Scaffold(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            currentExercise(),
            resting ? timerWidget() : exerciseProgress(),
            nextExercise(),
          ],
        ),
      ),
    );
  }

  Widget exerciseProgress() {
    switch (currentItem.repType) {
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
        child: SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 12,
                value: timerLeft / maxTime,
              ),
              Center(
                child: Text(
                  overTime ? (timerLeft * -1).toString() : timerLeft.toString(),
                  style: TextStyle(
                      fontSize: 80, color: overTime ? Colors.red : null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentExercise() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: resting
                ? [
                    Text(
                      "Rest Time",
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ] //If Resting
                : [
                    Text(
                      "Current Exercise:",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      currentItem.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text("Set ${currentItem.setNow}/${currentItem.setTotal}"),
                  ],
          ),
        ),
      ),
    );
  }

  Widget nextExercise() {
    return Card(
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: workoutFinished
                  ? [
                      Text(
                        "Done!",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ]
                  : [
                      Text(
                        "Next Up:",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        nextItem.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                          "${nextItem.reps} ${nextItem.repType} | Set ${nextItem.setNow}/${nextItem.setTotal} | ${nextItem.rest}s Rest"),
                    ],
            )),
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
            alarm.stop();
            if (workoutFinished) {
              Navigator.of(context).pop();
              return;
            }
            if (resting) {
              nextTask();
              resting = false;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Completed Exercise"),
                duration: Duration(milliseconds: 500),
                behavior: SnackBarBehavior.floating,
              ));
              if (currentItem.rest > 0) {
                rest(currentItem.rest);
              } else {
                nextTask();
              }
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
          onPressed: () async {
            bool confirm = await showConfirmPreviousDialog(context) ?? false;
            if (confirm) {
              alarm.stop();
              previousTask();
            }
          },
          child: const Text("Previous")),
    );
  }

  Future<bool?> showConfirmPreviousDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              "Are you sure you want to return to the previous exercise?"),
          actions: [
            TextButton(
              child: Text(
                "No",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                "Yes",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}

class _RunDownItem {
  _RunDownItem({
    required WorkoutItem workoutItem,
    required this.setNow,
    required this.itemIndex,
  }) {
    name = workoutItem.name;
    repType = workoutItem.exerciseCountType;
    rest = workoutItem.restTime;
    reps = workoutItem.reps;
    setTotal = workoutItem.sets;
  }

  // WorkoutItem workoutItem;
  short setNow;
  short itemIndex;
  late String name;
  late short setTotal;
  late short reps;
  late short rest;
  late ExerciseRepType repType;
}

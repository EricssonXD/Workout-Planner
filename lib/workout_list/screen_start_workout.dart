import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
  List<int> setNumber = [];

  Timer timer = Timer(const Duration(seconds: 0), () {});
  int timerLeft = 60;
  int maxTime = 60;
  bool overTime = false;
  bool resting = false;

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
        setNumber.add(j + 1);
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
    alarm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showConfirmQuitDialog(context) ?? false;
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
                    Text(
                        "Set ${setNumber[currentIndex].toString()}/${currentItem.sets}"),
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
                        "Next Exercise:",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        nextItem.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                          "${nextItem.reps} ${nextItem.exerciseCountType} | Set ${setNumber[currentIndex + 1].toString()}/${nextItem.sets} | ${nextItem.restTime}s Rest"),
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
              stopTimer();
              nextTask();
              resting = false;
            } else if (currentItem.restTime > 0) {
              rest(currentItem.restTime);
            } else {
              nextTask();
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

  Future<bool?> showConfirmQuitDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text(
        "Yes",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      onPressed: () => Navigator.of(context).pop(true),
    );

    Widget cancelButton = TextButton(
      child: Text(
        "No",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      onPressed: () => Navigator.of(context).pop(false),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure you want to quit?"),
      // content: const Text("This is my message."),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

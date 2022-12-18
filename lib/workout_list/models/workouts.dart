import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workoutplanner/utils/providers/isar.dart';

part 'workouts.g.dart';

@collection
class Workout {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, caseSensitive: false)
  String name = "";

  List<WorkoutItem> workoutItems = List.empty(growable: true);

  List<String> tags = List.empty(growable: true);

  bool hidden = false;

  DateTime mostRecentWorkout = DateTime.now();
}

@embedded
class WorkoutItem {
  late int id;

  late String name;

  short restTime = 0;

  short reps = 0;

  short sets = 1;

  @enumerated
  ExerciseRepType exerciseCountType = ExerciseRepType.reps;
}

enum ExerciseRepType {
  reps,
  timed,
  maxRep,
  maxTime;
}

class WorkoutManager {
  final Isar isar;

  WorkoutManager(this.isar) {
    debugPrint("init WorkoutManager");
  }

  Future<bool> addWorkout(Workout newWorkout) async {
    try {
      await isar.writeTxn(() async {
        await isar.workouts.put(newWorkout);
      });
      return true;
    } catch (e) {
      if (e.runtimeType == IsarError) {
        debugPrint(e.toString());
        return false;
      }
      rethrow;
    }
  }

  Future<List<Workout>> getWorkouts() async {
    return isar.workouts.where().sortByName().findAll();
  }

  void deleteAllWorkout() async {
    await isar.writeTxn(() async {
      await isar.workouts.filter().idGreaterThan(-1).deleteAll();
    });
  }
}

@riverpod
Future<WorkoutManager> workoutManager(WorkoutManagerRef ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return WorkoutManager(isar);
}

@riverpod
class WorkoutListNotifier extends _$WorkoutListNotifier {
  late StreamSubscription<void> watcher;

  @override
  FutureOr<List<Workout>> build() async {
    autoRefresh();
    ref.onDispose(() => watcher.cancel());
    return await getWorkouts();
  }

  autoRefresh() async {
    Isar isar = await ref.watch(isarInstanceProvider.future);

    Stream<void> onChange = isar.workouts.watchLazy();
    watcher = onChange.listen((_) async {
      debugPrint("autoRefreshed");
      refresh();
    });
  }

  Future<List<Workout>> getWorkouts() async {
    final workoutManager = await ref.watch(workoutManagerProvider.future);
    return await workoutManager.getWorkouts();
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await getWorkouts());
  }
}

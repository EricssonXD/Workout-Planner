// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @ignore
  short uid = 0;

  @ignore
  bool exerciseNotExist = false;

  short restTime = 0;

  short reps = 0;

  short sets = 1;

  @enumerated
  ExerciseRepType exerciseCountType = ExerciseRepType.reps;

  WorkoutItem from(WorkoutItem item) {
    return this
      ..id = item.id
      ..name = item.name
      ..uid = item.uid
      ..restTime = item.restTime
      ..reps = item.reps
      ..sets = item.sets
      ..exerciseCountType = item.exerciseCountType;
  }

  @override
  bool operator ==(covariant WorkoutItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.uid == uid &&
        other.restTime == restTime &&
        other.reps == reps &&
        other.sets == sets &&
        other.exerciseCountType == exerciseCountType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        uid.hashCode ^
        restTime.hashCode ^
        reps.hashCode ^
        sets.hashCode ^
        exerciseCountType.hashCode;
  }
}

enum ExerciseRepType {
  reps,
  timed,
  maxRep,
  maxTime;

  @override
  String toString() {
    switch (this) {
      case ExerciseRepType.reps:
        return "Reps";
      case ExerciseRepType.timed:
        return "Seconds";
      case ExerciseRepType.maxRep:
        return "Max Reps";
      case ExerciseRepType.maxTime:
        return "Max Seconds";
      default:
        return "";
    }
  }
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

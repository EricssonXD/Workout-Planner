import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../utils/providers/isar.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, caseSensitive: false)
  String name = "";

  // int defaultRestTime = 120;

  // int defaultReps = 12;

  // bool isTimedExercise = false;

  // int defaultSets = 3;

  List<String> tags = List.empty(growable: true);

  String videoLink = "";

  String videoPath = "";

  bool isLocalVideo = true;

  String thumbnailPath = "";
}

class ExerciseManager {
  final Isar isar;
  late final IsarCollection collection;

  ExerciseManager(this.isar) {
    debugPrint("init ExerciseManager");
    collection = isar.exercises;
  }

  Future<bool> addExercise(Exercise newExercise) async {
    try {
      await isar.writeTxn(() async {
        await isar.exercises.put(newExercise);
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

  Future<List<Exercise>> getExercises() async {
    return isar.exercises.where().sortByName().findAll();
  }

  void deleteAllExercise() async {
    await isar.writeTxn(() async {
      await isar.exercises.filter().idGreaterThan(-1).deleteAll();
    });
  }
}

@riverpod
Future<ExerciseManager> exerciseManager(ExerciseManagerRef ref) async {
  final isar = await ref.watch(isarInstanceProvider.future);
  return ExerciseManager(isar);
}

@riverpod
Future<List<Exercise>> getExercises(GetExercisesRef ref) async {
  final exerciseManager = await ref.watch(exerciseManagerProvider.future);
  return exerciseManager.getExercises();
}

@riverpod
class ExerciseListNotifier extends _$ExerciseListNotifier {
  late StreamSubscription<void> watcher;

  @override
  FutureOr<List<Exercise>> build() async {
    autoRefresh();
    ref.onDispose(() => watcher.cancel());
    final exerciseManager = await ref.watch(exerciseManagerProvider.future);
    return await exerciseManager.getExercises();
  }

  autoRefresh() async {
    // refresh();
    Isar isar = await ref.watch(isarInstanceProvider.future);

    Stream<void> onChange = isar.exercises.watchLazy();
    watcher = onChange.listen((_) async {
      debugPrint("autoRefreshed");
      refresh();
    });
  }

  Future<void> refresh() async {
    final exerciseManager = await ref.watch(exerciseManagerProvider.future);
    state = AsyncValue.data(await exerciseManager.getExercises());
  }
}

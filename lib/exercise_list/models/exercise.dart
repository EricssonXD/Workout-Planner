import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../utils/providers/isar.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true, replace: true)
  late String name;

  int defaultRestTime = 120;

  int defaultReps = 12;

  bool isTimedExercise = false;

  int defaultSets = 3;

  String? videoLink;

  String? videoPath;

  bool isLocalVideo = false;
}

class ExerciseManager {
  final Isar isar;

  ExerciseManager(this.isar) {
    debugPrint("init ExerciseManager");
  }

  Future<void> addExercise(Exercise newExercise) async {
    await isar.writeTxn(() async {
      await isar.exercises.put(newExercise);
    });
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

// final exerciseListProvider =
//     AsyncNotifierProvider.autoDispose<ExerciseListNotifier, List<Exercise>>(
//         ExerciseListNotifier.new);

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
    debugPrint('autorefresh called');
    Isar isar = await ref.watch(isarInstanceProvider.future);
    Stream<void> onChange = isar.exercises.watchLazy();

    watcher = onChange.listen((e) async {
      debugPrint("autoRefreshed");
      refresh();
    });
  }

  Future<void> refresh() async {
    final exerciseManager = await ref.watch(exerciseManagerProvider.future);
    state = AsyncValue.data(await exerciseManager.getExercises());
    debugPrint("Notifier Got Exercise List");
  }
}


// class ScoreManager {
//   final Isar isar;

//   ScoreManager(this.isar);

//   Future<void> addScore(String name, int score) async {
//     final newScore = Score()
//       ..name = name
//       ..score = score;

//     await isar.writeTxn(() async {
//       await isar.scores.put(newScore);
//     });
//   }

//   Future<List<Score>> getScores() async {
//     return isar.scores.where().sortByScoreDesc().findAll();
//   }

//   Future<List<Score>> getHighScores() async {
//     return isar.scores.where().sortByScoreDesc().limit(8).findAll();
//   }
// }
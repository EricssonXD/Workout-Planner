import 'package:riverpod_annotation/riverpod_annotation.dart';

// final exerciseProvider = NotifierProvider<ExerciseNotifier, List<Exercise>>(() {
//   return ExerciseNotifier();
// });
// part 'riverpod.g.dart';

// @riverpod
// Future<ExerciseListManager> exerciseListManager(
//     ExerciseListManagerRef ref) async {
//   final isar = await ref.watch(isarInstanceProvider.future);
//   return ExerciseListManager(isar);
// }

final helloWorldProvider = Provider<String>((ref) {
  return 'Hello world';
});

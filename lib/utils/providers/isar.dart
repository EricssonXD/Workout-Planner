import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';

part 'isar.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isarInstance(FutureProviderRef ref) async {
  if (Isar.instanceNames.isEmpty) {
    final dir = await getApplicationSupportDirectory();
    return await Isar.open(
      [
        ExerciseSchema,
      ],
      inspector: true,
      directory: dir.path,
    );
  }
  return Future.value(Isar.getInstance());
}

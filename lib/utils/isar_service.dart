import 'package:isar/isar.dart';
import 'package:workoutplanner/exercise_list/models/exercise.dart';
import 'package:path_provider/path_provider.dart';

class IsarServices {
  late Future<Isar> db;

  IsarServices() {
    db = openDb();
  }

  Future saveExercise(Exercise newExercise) async {
    final isar = await db;
    isar.writeTxn(() => isar.exercises.put(newExercise));
  }

  Future<Isar> openDb() async {
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

  Future cleanDb() async {
    final isar = await db;
    isar.writeTxn(() => isar.clear());
  }
}

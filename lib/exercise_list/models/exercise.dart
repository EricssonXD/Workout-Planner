import 'package:isar/isar.dart';

part 'exercise.g.dart';

@collection
class Exercise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  late int defaultRestTime;

  late int defaultReps;

  late bool isTimedExercise;

  late int defaultSets;

  late String videoLink;

  late String videoPath;

  late bool isLocalVideo;
}

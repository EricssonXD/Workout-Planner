import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int defaultRestTime;

  @HiveField(2)
  late int defaultReps;

  @HiveField(3)
  late bool isTimedExercise;

  @HiveField(4)
  late int defaultSets;

  @HiveField(10)
  late String videoLink;

  @HiveField(11)
  late String videoPath;

  @HiveField(12)
  late bool isLocalVideo;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise()
      ..name = fields[0] as String
      ..defaultRestTime = fields[1] as int
      ..defaultReps = fields[2] as int
      ..isTimedExercise = fields[3] as bool
      ..defaultSets = fields[4] as int
      ..videoLink = fields[10] as String
      ..isLocalVideo = fields[11] as bool;
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.defaultRestTime)
      ..writeByte(2)
      ..write(obj.defaultReps)
      ..writeByte(3)
      ..write(obj.isTimedExercise)
      ..writeByte(4)
      ..write(obj.defaultSets)
      ..writeByte(10)
      ..write(obj.videoLink)
      ..writeByte(11)
      ..write(obj.isLocalVideo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

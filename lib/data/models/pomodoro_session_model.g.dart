// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PomodoroSessionModelAdapter extends TypeAdapter<PomodoroSessionModel> {
  @override
  final int typeId = 1;

  @override
  PomodoroSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSessionModel()
      ..id = fields[0] as String
      ..taskId = fields[1] as String?
      ..type = fields[2] as int
      ..startedAt = fields[3] as DateTime
      ..finishedAt = fields[4] as DateTime?
      ..completed = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, PomodoroSessionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.finishedAt)
      ..writeByte(5)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

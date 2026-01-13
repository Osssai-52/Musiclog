// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecommendationResultAdapter extends TypeAdapter<RecommendationResult> {
  @override
  final int typeId = 2;

  @override
  RecommendationResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationResult(
      diaryEntryId: fields[0] as String,
      songId: fields[1] as String,
      reason: fields[2] as String,
      matchedLines: (fields[3] as List).cast<String>(),
      generatedAt: fields[4] as DateTime,
      model: fields[5] as String,
      confidence: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.diaryEntryId)
      ..writeByte(1)
      ..write(obj.songId)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.matchedLines)
      ..writeByte(4)
      ..write(obj.generatedAt)
      ..writeByte(5)
      ..write(obj.model)
      ..writeByte(6)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

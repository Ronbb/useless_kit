// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'converter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConverterDataAdapter extends TypeAdapter<ConverterData> {
  @override
  final int typeId = 0;

  @override
  ConverterData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConverterData(
      decoded: fields[1] as String,
      encoded: fields[2] as String,
      extraDecodedData: (fields[3] as Map).cast<String, String>(),
      extraEncodedData: (fields[4] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConverterData obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.decoded)
      ..writeByte(2)
      ..write(obj.encoded)
      ..writeByte(3)
      ..write(obj.extraDecodedData)
      ..writeByte(4)
      ..write(obj.extraEncodedData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConverterDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

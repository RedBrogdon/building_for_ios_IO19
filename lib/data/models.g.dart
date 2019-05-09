// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) {
  return LogEntry(
      veggieId: json['veggieId'] as int,
      servings: json['servings'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mealType: _$enumDecode(_$MealTypeEnumMap, json['mealType']));
}

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
      'veggieId': instance.veggieId,
      'servings': instance.servings,
      'timestamp': instance.timestamp.toIso8601String(),
      'mealType': _$MealTypeEnumMap[instance.mealType]
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

const _$MealTypeEnumMap = <MealType, dynamic>{
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner'
};

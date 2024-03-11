part of 'flashcard_model.dart';

DateTime dateTimeHandler(json, key) {
  try { return DateTime.parse(json[key] as String); } catch (_) { return DateTime.now(); }
}

FlashCard _$FlashCardFromJson(Map<String, dynamic> json) => FlashCard()
  ..word = json['word'] as String
  ..english = json['english'] as String
  ..example = json['example'] as String
  ..due = dateTimeHandler(json, 'due')
  ..stability = (json['stability'] as num).toDouble()
  ..difficulty = (json['difficulty'] as num).toDouble()
  ..elapsedDays = json['elapsedDays'] as int
  ..scheduledDays = json['scheduledDays'] as int
  ..reps = json['reps'] as int
  ..lapses = json['lapses'] as int
  ..state = $enumDecode(_$StateEnumMap, json['state'])
  ..lastReview = dateTimeHandler(json, 'lastReview');

Map<String, dynamic> _$FlashCardToJson(FlashCard instance) => <String, dynamic>{
  'word': instance.word,
  'english': instance.english,
  'example': instance.example,
  'due': instance.due.toIso8601String(),
  'stability': instance.stability,
  'difficulty': instance.difficulty,
  'elapsedDays': instance.elapsedDays,
  'scheduledDays': instance.scheduledDays,
  'reps': instance.reps,
  'lapses': instance.lapses,
  'state': _$StateEnumMap[instance.state]!,
  'lastReview': instance.lastReview.toIso8601String(),
};

const _$StateEnumMap = {
  CardState.New: 0,
  CardState.Learning: 1,
  CardState.Review: 2,
  CardState.Relearning: 3,
};

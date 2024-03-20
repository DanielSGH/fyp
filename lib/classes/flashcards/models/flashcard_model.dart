import 'package:fyp/classes/flashcards/enums/card_state.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'flashcard_model.json_serializable.dart';

class FlashCard {
  ObjectId id;
  String word;
  String english;
  String example;
  DateTime due;
  double stability;
  double difficulty;
  int elapsedDays;
  int scheduledDays;
  int reps;
  int lapses;
  CardState state;
  late DateTime lastReview;

  FlashCard._({
    required this.id,
    required this.word,
    required this.english,
    required this.example,
    required this.due, 
    required this.stability, 
    required this.difficulty, 
    required this.elapsedDays, 
    required this.scheduledDays, 
    required this.reps, 
    required this.lapses, 
    required this.state, 
    required this.lastReview
  });

  FlashCard() :
    id = ObjectId(),
    word = '',
    english = '',
    example = '',
    due = DateTime.now(),
    stability = 0.0,
    difficulty = 0.0,
    elapsedDays = 0,
    scheduledDays = 0,
    reps = 0,
    lapses = 0,
    state = CardState.New,
    lastReview = DateTime.now();

  factory FlashCard.copy({
    required FlashCard obj,
  }) {
    return FlashCard._(
      id: obj.id,
      word: obj.word,
      english: obj.english,
      example: obj.example,
      due: obj.due,
      stability: obj.stability,
      difficulty: obj.difficulty,
      elapsedDays: obj.elapsedDays,
      scheduledDays: obj.scheduledDays,
      reps: obj.reps,
      lapses: obj.lapses,
      state: obj.state,
      lastReview: obj.lastReview
    );
  }

  factory FlashCard.fromJson(Map<String, dynamic> json) => _$FlashCardFromJson(json);
  Map<String, dynamic> toJson() => _$FlashCardToJson(this);
}
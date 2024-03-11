import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String username;
  final List<FlashCard>? flashcards;
  final List<Map<String, dynamic>>? messages;
  final List<ContactModel>? contacts;
  
  User({
    required this.username,
    this.flashcards,
    this.messages,
    this.contacts,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}


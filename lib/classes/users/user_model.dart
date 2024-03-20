import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

@JsonSerializable()
class User {
  @JsonKey(fromJson: _idFromJson, toJson: _idToJson)
  final ObjectId id;
  final String username;
  final List<FlashCard>? flashcards;
  final List<Map<String, dynamic>>? messages;
  final List<ContactModel>? contacts, newPartners;
  final List<String>? selectedLanguages;
  
  User({
    required this.id,
    required this.username,
    this.flashcards,
    this.messages,
    this.contacts,
    this.newPartners,
    this.selectedLanguages,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: User._idFromJson(json['_id'] as String),
    username: json['username'] as String,
    flashcards: (json['flashcards'] as List<dynamic>?)
        ?.map((e) => FlashCard.fromJson(e as Map<String, dynamic>))
        .toList(),
    messages: (json['messages'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList(),
    contacts: (json['contacts'] as List<dynamic>?)
        ?.map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    newPartners: (json['newPartners'] as List<dynamic>?)
        ?.map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    selectedLanguages: (json['selectedLanguages'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': User._idToJson(id),
      'username': username,
      'flashcards': flashcards,
      'messages': messages,
      'contacts': contacts,
      'newPartners': newPartners,
      'selectedLanguages': selectedLanguages,
    };

  // Add these methods
  static ObjectId _idFromJson(String id) => ObjectId.fromHexString(id);
  static String _idToJson(ObjectId id) => id.toHexString();
}
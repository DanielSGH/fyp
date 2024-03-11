// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
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
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'username': instance.username,
      'flashcards': instance.flashcards,
      'messages': instance.messages,
      'contacts': instance.contacts,
    };

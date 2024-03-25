import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum OnlineStatus { online, offline }

OnlineStatus convertByName(String status) {
  try {
    return OnlineStatus.values.byName(status);
  } catch (_) {
    return OnlineStatus.offline;
  }
}

class ContactModel {
  ObjectId id;
  Image profilePicture;
  String username;
  String? lastMessage;
  DateTime? lastSeenTime;
  OnlineStatus? onlineStatus;
  List<String>? selectedLanguages;


  ContactModel({
    required this.id,
    required this.profilePicture,
    required this.username,
    this.lastSeenTime,
    this.onlineStatus = OnlineStatus.offline,
    this.lastMessage = '',
    this.selectedLanguages = const <String>[],
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) { 
    return ContactModel(
      id: ObjectId.parse(json['_id']),
      profilePicture: Image.network(json['profilePicture'] ?? dotenv.get('DEFAULT_PROFILE_PICTURE')),
      username: json['username'] as String,
      lastSeenTime: json['lastSeenTime'] == "" ? null : DateTime.parse(json['lastSeenTime']),
      onlineStatus: convertByName(json['onlineStatus'] ?? ''),
      lastMessage: json['lastMessage'],
      selectedLanguages: (json['selectedLanguages'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'profilePicture': profilePicture,
    'username': username,
    'lastSeenTime': lastSeenTime,
    'onlineStatus': onlineStatus,
    'lastMessage': lastMessage,
    'selectedLanguages': selectedLanguages,
  };
}

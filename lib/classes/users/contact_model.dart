import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum OnlineStatus { online, offline }

class ContactModel {
  ObjectId id;
  Image? profilePicture;
  String username;
  String? lastMessage;
  DateTime? lastSeenTime;
  OnlineStatus? onlineStatus;

  ContactModel({
    required this.id,
    this.profilePicture,
    required this.username,
    this.lastSeenTime,
    this.onlineStatus = OnlineStatus.offline,
    this.lastMessage = '',
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: ObjectId.parse(json['_id']),
    profilePicture: json['profilePicture'],
    username: json['username'] as String,
    lastSeenTime: json['lastSeenTime'],
    onlineStatus: json['onlineStatus'],
    lastMessage: json['lastMessage'], 
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'profilePicture': profilePicture,
    'username': username,
    'lastSeenTime': lastSeenTime,
    'onlineStatus': onlineStatus,
    'lastMessage': lastMessage,
  };
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:fyp/classes/users/user_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User(username: '', id: ObjectId(), profilePicture: Image.network(dotenv.get('DEFAULT_PROFILE_PICTURE'))));

  void setUser(User user) {
    state = user;
  }

  List<Map<String, dynamic>>? getMessages(String oid) {
    List<Map<String, dynamic>>? ret = [];
    
    state.messages?.forEach((room) {
      room['participants'].forEach((participant) {
        if (participant['_id'] == oid) {
          ret.add(room);
        }
      });
    });

    return ret;
  }

  void updateFlashCard(FlashCard card) {
    state.flashcards?.forEach((element) {
      if (element.id == card.id) {
        element.due = card.due;
        element.stability = card.stability;
        element.difficulty = card.difficulty;
        element.elapsedDays = card.elapsedDays;
        element.scheduledDays = card.scheduledDays;
        element.reps = card.reps;
        element.lapses = card.lapses;
        element.state = card.state;
        element.lastReview = card.lastReview;
      }
    });
  }

  void addMessage(String roomID, String message) {
    state.messages?.forEach((room) {
      if (room['_id'] == roomID) {
        room['messages'].add({
          'message': message,
          'from': state.id.oid,
          'at': DateTime.now(),
        });
      }
    });
  }

  void addRoomAndContact(String room, ContactModel contact) {
    state.contacts?.add(contact);
    state.messages?.add({
      '_id': room,
      'participants': [{"_id": contact.id.oid, "username": contact.username}, {"_id": state.id.oid, "username": state.username}],
      'messages': [],
    });

    state.newPartners?.removeWhere((element) => element.id.oid == contact.id.oid);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());

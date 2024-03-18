import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDB {
  static dynamic db;
  static connect() async {
    try {
      db = await Db.create(dotenv.get('MONGODB_LOCAL_URL'));
      await db.open();
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getFlashcards(String col, [Map<String, dynamic> filter = const {}]) async {
    try {
      var collection = db.collection(col);
      var flashcards = await collection.find(filter).toList();
      return flashcards;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  static Future<void> close() async {
    await db.close();
  }

  static Future<void> insertFlashcard(String col, FlashCard flashcard) async {
    try {
      var collection = db.collection(col);
      await collection.insertOne(flashcard.toJson());
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> updateFlashcard(String col, Map<String, dynamic> filter, FlashCard fc) async {
    try {
      var collection = db.collection(col);
      await collection.replaceOne(filter, fc.toJson());
    } catch (e) {
      log(e.toString());
    }
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/users/user_model.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User(username: ''));

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
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) => UserNotifier());

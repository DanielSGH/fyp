import 'dart:developer';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/chat_view.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketIONotifier extends StateNotifier<Socket> {
  SocketIONotifier() : super(io('${dotenv.get('API_BASE_URL')}/messageprotocol', 
    OptionBuilder()
    .setTransports(['websocket'])
    .build()));

  void initSetup(WidgetRef ref) {
    state.onConnect((_) async {
      var messages = ref.read(userProvider).messages;
      var prefs = await ApiWrapper.apiPreferences;
      var tok = prefs.getString('refreshToken');
      String userID = JWT.decode(tok!).payload['_id'];

      messages?.forEach((room) => state.emit('join', { "userID": userID, "room": room['_id']}));
      state.on('message', (data) {
        log('message: ${data['room']}: ${data['msg']}');
        chatViewKey.currentState?.receiveMessage(data);
      });
    });
    state.onConnectError((error) {
      log('connection error: $error');
    });
  }
}

final socketIOProvider = StateNotifierProvider<SocketIONotifier, Socket>((ref) => SocketIONotifier());
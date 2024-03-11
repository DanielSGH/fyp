import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/chat_view.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIONotifier extends StateNotifier<IO.Socket> {
  SocketIONotifier() : super(IO.io('${dotenv.get('API_BASE_URL')}/messageprotocol', 
    IO.OptionBuilder()
    .setTransports(['websocket'])
    .build()));

  void initSetup(WidgetRef ref) {
    state.onConnect((_) {
      var messages = ref.read(userProvider).messages;
      messages?.forEach((room) => state.emit('join', room['_id']));
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

final socketIOProvider = StateNotifierProvider<SocketIONotifier, IO.Socket>((ref) => SocketIONotifier());
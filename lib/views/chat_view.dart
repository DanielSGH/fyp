import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ignore: library_private_types_in_public_api
final GlobalKey<_ChatViewState> chatViewKey = GlobalKey<_ChatViewState>();

class ChatView extends ConsumerStatefulWidget {
  final ContactModel contact;
  final IO.Socket socket;

  ChatView({
    required this.contact,
    required this.socket,
  }) : super(key: chatViewKey);

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  List<String> messages = [];
  late String roomID;

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    roomID = getRoomID();
  }

  String getRoomID() {
    String oid = widget.contact.id.oid;
    List<Map<String, dynamic>> rooms = ref.read(userProvider.notifier).getMessages(oid) ?? [];
    
    rooms[0]['messages'].forEach((message) {
      final msg = message['message'];
      setState(() {
      messages.add(msg);
      });
    });

    return rooms[0]['_id'];
  }

  void receiveMessage(data) {
    if (data['room'] != roomID) {
      return;
    }

    setState(() {
      messages.add(data['msg']);
    });
  }

  void sendMessage() {
    final message = messageController.text;
    
    if (message.isNotEmpty) {
      widget.socket.emit('message', {
        'room': roomID,
        'msg': message,
      });

      ApiWrapper.sendPostReq('/message/send', {
        "to": widget.contact.id.oid,
        "message": {
          "from": ref.read(userProvider).id.oid,
          "message": message,
        },
      });

      setState(() {
        messages.add(message);
      });

      ref.read(userProvider.notifier).addMessage(roomID, message);
    }

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.contact.profilePicture?.image ?? Image.network('https://thispersondoesnotexist.com/').image,
            ),
            const SizedBox(width: 8.0),
            Text(widget.contact.username),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSent = index % 2 == 0; // Determine if the message is sent or received
                final color = isSent ? Colors.grey : Colors.blue; // Set the color based on sent or received
                return Container(
                  color: color,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(message),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
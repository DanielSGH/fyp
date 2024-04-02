import 'dart:convert';
import 'dart:developer';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:socket_io_client/socket_io_client.dart';

// ignore: library_private_types_in_public_api
final GlobalKey<_ChatViewState> chatViewKey = GlobalKey<_ChatViewState>();

class ChatView extends ConsumerStatefulWidget {
  final ContactModel contact;
  final Socket socket;

  ChatView({
    required this.contact,
    required this.socket,
  }) : super(key: chatViewKey);

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  List<Map<String, dynamic>> messages = [];
  String? roomID;

  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    String oid = widget.contact.id.oid;
    List<Map<String, dynamic>> rooms = ref.read(userProvider.notifier).getMessages(oid) ?? [];

    if (rooms.isNotEmpty) {
      setState(() {
        roomID = rooms[0]['_id'];
      });
    }

    getRoomIDHelper();
    try {
      getMessages();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text("Failed to get messages..."),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void getRoomIDHelper() async {
    if (roomID != null) {
      return;
    }

    var id = await getRoomID();
    setState(() {
      roomID = id;
    });

    ref.read(userProvider.notifier).addRoomAndContact(roomID!, widget.contact);
  }

  Future<String?> getRoomID() async {
    var res = await ApiWrapper.sendPostReq('/message/send', {
      "to": widget.contact.id.oid,
    });

    return jsonDecode(res.body)['roomID'];
  }

  void getMessages() {
    var rooms = ref.read(userProvider.notifier).getMessages(widget.contact.id.oid) ?? <Map<String, dynamic>>[];

    if (!rooms.isNotEmpty) {
      return;
    }

    try {
      setState(() {
        messages = ((rooms[0]['messages'] ?? []) as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
      });
    } catch (e) {
      rethrow;
    }
  }

  void receiveMessage(data) {
    if (data['room'] != roomID) {
      return;
    }

    setState(() {
      messages.add({
        "from": widget.contact.id.oid,
        "message": data['msg'],
        "at": DateTime.now().toIso8601String(),
      });
    });
  }

  void sendMessage() {
    final message = messageController.text;
    
    if (!message.isNotEmpty) {
      return;
    }

    if (roomID == null) {
      return;
    }

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
      messages.add({
        "from": ref.read(userProvider).id.oid,
        "message": message,
        "at": DateTime.now().toIso8601String(),
      });
    });

    ref.read(userProvider.notifier).addMessage(roomID!, message);   

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.contact.profilePicture.image,
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
                final message = messages[index]['message'];
                final isSent = messages[index]['from'] == ref.read(userProvider).id.oid;
                final color = isSent ? Colors.grey : Colors.blue;
                const Radius radius = Radius.circular(20.0);
                DateTime time = DateTime.tryParse(messages[index]['at'].toString()) ?? DateTime.now();
                
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: isSent ? const BorderRadius.only(
                            topRight: radius,
                            topLeft: radius,
                            bottomLeft: radius,
                          ) : const BorderRadius.only(
                            topRight: radius,
                            topLeft: radius,
                            bottomRight: radius,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: const TextStyle(color: Colors.white, fontSize: 16.0),
                            ),
                            Text(
                              formatDate(time, [HH, ':', nn, ' ', am, ' ', dd, '/', mm, '/', yyyy]),
                              style: const TextStyle(color: Colors.white, fontSize: 10.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
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
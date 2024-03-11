import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/chat_view.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ContactsView extends ConsumerStatefulWidget {
  const ContactsView({super.key});

  @override
  ConsumerState<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> {
  late IO.Socket socket;
  List<ContactModel> contacts = [];
  late ChatView activeChat;

  @override
  void initState() {
    super.initState();
    connect();
    contacts = ref.read(userProvider).contacts ?? [];
  }

  void connect() { 
    socket = IO.io('${dotenv.get('API_BASE_URL')}/messageprotocol', IO.OptionBuilder().setTransports(['websocket']).build());
    socket.onConnect((_) {
      var messages = ref.read(userProvider).messages;
      messages?.forEach((room) => socket.emit('join', room['_id']));
      socket.on('message', (data) {
        log('message: ${data['room']}: ${data['msg']}');
        chatViewKey.currentState?.receiveMessage(data);
      });
    });
    socket.onConnectError((error) {
      log('connection error: $error');
    });
  }

  Color _getOnlineStatusColor(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.online:
        return Colors.green;
      case OnlineStatus.offline:
        return Colors.grey;
    }
  }

  Icon _getIconForOnlineStatus(OnlineStatus status) {
    const double size = 10;

    switch (status) {
      case OnlineStatus.online:
        return const Icon(Icons.check, size: size, color: Colors.white);
      case OnlineStatus.offline:
        return const Icon(Icons.close, size: size, color: Colors.black);
    }
  }

  Text _getLastSeenTimeText(DateTime time) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return const Text('Just now');
    } else if (difference.inMinutes < 60) {
      return Text('${difference.inMinutes} minutes ago');
    } else if (difference.inHours < 24) {
      return Text('${difference.inHours} hours ago');
    } else if (difference.inDays < 7) {
      return Text('${difference.inDays} days ago');
    } else {
      return Text('${difference.inDays ~/ 7} weeks ago');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () async {
              activeChat = ChatView(contact: contacts[index], socket: socket);
              Navigator.push(context, MaterialPageRoute(builder: (context) => activeChat));
            },
            tileColor: Colors.black12,
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: contacts[index].profilePicture?.image ?? const NetworkImage('https://thispersondoesnotexist.com/')
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getOnlineStatusColor(contacts[index].onlineStatus ?? OnlineStatus.offline),
                    ),
                    child: _getIconForOnlineStatus(contacts[index].onlineStatus ?? OnlineStatus.offline),
                  ),
                ),
              ],
            ),
            title: Text(contacts[index].username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getLastSeenTimeText(contacts[index].lastSeenTime ?? DateTime.now().subtract(const Duration(days: 2))),
                if (contacts[index].lastMessage != null && contacts[index].lastMessage!.isNotEmpty)
                  Text(contacts[index].lastMessage ?? ''),
              ],
            ),
          );
        },
      ),
    );
  }
}
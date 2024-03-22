import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:fyp/providers/socketio_provider.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/chat_view.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ContactsView extends ConsumerStatefulWidget {
  const ContactsView({super.key});

  @override
  ConsumerState<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> {
  late Socket socket;
  List<ContactModel> contacts = [];
  late ChatView activeChat;

  @override
  void initState() {
    super.initState();
    connect();
    contacts = ref.read(userProvider).contacts ?? [];
  }

  void connect() { 
    socket = ref.read(socketIOProvider);
    ref.read(socketIOProvider.notifier).initSetup(ref);
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
    var newPartners = ref.watch(userProvider).newPartners;
    List<ContactModel> combinedContacts = [...contacts, ...newPartners ?? []];
    // inspect(contacts);

    return Scaffold(
      body: ListView.builder(
        itemCount: combinedContacts.length,
        itemBuilder: (context, index) {
          if (index == 0 && contacts.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contactTile(index, context, contacts),
              ],
            );
          }

          if (index == contacts.length) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Partners',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contactTile(index, context, combinedContacts),
              ],
            );
          }

          return contactTile(index, context, combinedContacts);
        },
      ),
    );
  }

  ListTile contactTile(int index, BuildContext context, List<ContactModel> whichContacts) {
    return ListTile(
      onTap: () async {
        activeChat = ChatView(contact: whichContacts[index], socket: socket);
        Navigator.push(context, MaterialPageRoute(builder: (context) => activeChat));
      },
      tileColor: Colors.black12,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: whichContacts[index].profilePicture?.image ?? const NetworkImage('https://thispersondoesnotexist.com/')
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getOnlineStatusColor(whichContacts[index].onlineStatus ?? OnlineStatus.offline),
              ),
              child: _getIconForOnlineStatus(whichContacts[index].onlineStatus ?? OnlineStatus.offline),
            ),
          ),
        ],
      ),
      title: Text(whichContacts[index].username),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getLastSeenTimeText(whichContacts[index].lastSeenTime ?? DateTime.now().subtract(const Duration(days: 2))),
          if (whichContacts[index].lastMessage != null && whichContacts[index].lastMessage!.isNotEmpty)
            Text(whichContacts[index].lastMessage ?? ''),
        ],
      ),
    );
  }
}
import 'dart:developer';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/language_codes.dart';
import 'package:fyp/classes/users/contact_model.dart';
import 'package:fyp/providers/socketio_provider.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/chat_view.dart';
import 'package:fyp/views/settings_view.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ContactsView extends ConsumerStatefulWidget {
  const ContactsView({super.key});

  @override
  ConsumerState<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> with AutomaticKeepAliveClientMixin<ContactsView> {
  late Socket socket;
  List<ContactModel> contacts = [];
  late ChatView activeChat;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    connect();
    setContacts();
  }

  @override
  void dispose() {
    // socket.dispose();
    super.dispose();
  }

  void connect() { 
    socket = ref.read(socketIOProvider);
    ref.read(socketIOProvider.notifier).initSetup(ref.read(userProvider).messages);
    socket.on('joined', (userID) {
      handleUserEvent(userID, OnlineStatus.online);
    });

    socket.on('exited', (userID) {
      handleUserEvent(userID, OnlineStatus.offline);
    });
  }

  void handleUserEvent(String userID, OnlineStatus status) {
    var user = ref.read(userProvider);
    if (userID == user.id.oid) {
      return;
    }

    var contact = user.contacts?.firstWhere((element) => element.id.oid == userID);
    contact?.onlineStatus = status;
    if (status == OnlineStatus.offline) {
      contact?.lastSeenTime = DateTime.now();
    }
    
    setState(() {      
      contacts = user.contacts ?? [];
    });
  }

  void setContacts() {
    setState(() {
      contacts = ref.read(userProvider).contacts ?? [];
      List<Map<String, dynamic>> userMessages = ref.read(userProvider).messages ?? [];

      if (contacts.isEmpty || userMessages.isEmpty) return;

      for (var contact in contacts) {
        for (var msg in userMessages) {
          if (msg['participants'] == null) continue;
          for (var participant in msg['participants']) {
            if (participant['_id'] == contact.id.oid) {
              if (msg['messages'] != null && msg['messages'].isNotEmpty) {
                contact.lastMessage = msg['messages']?.last['message'] ?? '';
              }
            }
          }
        }
      }
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
    var newPartners = ref.watch(userProvider).newPartners;
    List<ContactModel> combinedContacts = [...contacts, ...newPartners ?? []];

    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Contacts'),
          const Spacer(),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsView(pfp: ref.read(userProvider).profilePicture, socket: socket),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: ref.read(userProvider).profilePicture.image,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getOnlineStatusColor(OnlineStatus.online),
                  ),
                  child: _getIconForOnlineStatus(OnlineStatus.online),
                ),
              ),
            ],
          ),
        ]),
      ),
      body: ListView.builder(
        itemCount: combinedContacts.length,
        itemBuilder: (context, index) {
          if (index == 0 && contacts.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'New Partners',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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

  Card contactTile(int index, BuildContext context, List<ContactModel> whichContacts) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () async {
          activeChat = ChatView(contact: whichContacts[index], socket: socket);
          var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => activeChat));
          if (res == null) {
            setContacts();
          }
        },
        leading: getPFPWithStatus(whichContacts[index]),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    whichContacts[index].username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (whichContacts[index].onlineStatus == OnlineStatus.offline)
                    _getLastSeenTimeText(whichContacts[index].lastSeenTime ?? DateTime.now().subtract(const Duration(days: 2))),
                  if (whichContacts[index].lastMessage != null && whichContacts[index].lastMessage!.isNotEmpty)
                    Text(whichContacts[index].lastMessage ?? '', overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            CountryFlag.fromCountryCode(
              LanguageCodes.getCode(whichContacts[index].selectedLanguages?.first ?? 'en')!, 
              height: 36, 
              width: 48,
              borderRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  Stack getPFPWithStatus(ContactModel contact) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: contact.profilePicture.image,
          radius: 25,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getOnlineStatusColor(contact.onlineStatus ?? OnlineStatus.offline),
            ),
            child: _getIconForOnlineStatus(contact.onlineStatus ?? OnlineStatus.offline),
          ),
        ),
      ],
    );
  }
}
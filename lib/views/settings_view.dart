import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/auth_view.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SettingsView extends StatelessWidget {
  final Image pfp;
  final Socket socket;

  const SettingsView({
    Key? key, 
    required this.pfp,
    required this.socket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image:  pfp.image,
                fit: BoxFit.fill
              ),
            ),
          ),
          const Spacer(),
          // Sign out
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              ApiWrapper.delete('signout');
              sendToAuthView(context);
            },
          ),
          // Delete account
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            onTap: () {
              ApiWrapper.delete('deleteAccount');
              sendToAuthView(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void sendToAuthView(BuildContext context) {
    socket.dispose();
    Navigator.popUntil(context, ModalRoute.withName('/'));
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthView()));
  }
}
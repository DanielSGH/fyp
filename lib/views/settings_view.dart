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
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () => signOutDeleteAccountHandler(context, 'signout'),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            onTap: () => signOutDeleteAccountHandler(context, 'deleteAccount'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void disconnectApp(BuildContext context, String type) async {
    socket.dispose();
    ApiWrapper.delete(type).then((_) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthView()));
    }).catchError((error) {
      throw Exception('Failed to disconnect'); // this should never happen
    });
  }

  void signOutDeleteAccountHandler(BuildContext context, String type) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        actions: [
          diaogButton(Colors.red, 'Yes', const TextStyle(color: Colors.white), () => disconnectApp(context, type), const Icon(Icons.check, color: Colors.white)),
          diaogButton(Colors.green, 'No', const TextStyle(color: Colors.white), () => Navigator.pop(context), const Icon(Icons.close, color: Colors.white)),
        ],
        title: const Text('Are you sure?'),
        content: const Text("Are you sure you want to perform this action?"),
      )
    );    
  }

  ElevatedButton diaogButton(Color color, String text, TextStyle style, Function() onPressed, [Icon? icon]) {
    return icon == null 
      ? ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color), child: Text(text, style: style))
      : ElevatedButton.icon(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color), icon: icon, label: Text(text, style: style));
  }
}
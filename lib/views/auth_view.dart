import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/classes/users/user_model.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/home_view.dart';
import 'package:fyp/widgets/auth_form_text_field.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool isSigningUp = false;

  @override
  void initState() {
    super.initState();
    checkNeedsSignup();
  }

  void showError(e) {
    showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
          ],
          title: const Text('Error'),
          content: Text(e.toString()),
        )
      );
  }

  void checkNeedsSignup() async {
    var prefs = await ApiWrapper.apiPreferences;
    prefs.clear();

    if (!prefs.containsKey('refreshToken')) {
      setState(() {
        isSigningUp = true;
      });
      return;
    }

    try {
      await ApiWrapper.refreshAccessToken();

      User user = await ApiWrapper.getUserInfo();
      ref.read(userProvider.notifier).setUser(user);
      
      gotoHomePage();
    } catch (e) {
      showError(e);
    }
  }

  void gotoHomePage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeView()));
  }

  void _handleAuth(Map<String, String> content, context) async { 
    try {
      await ApiWrapper.authUser(content['username']!, content['password']!, content['selectedLanguage']!, content['email']);
      User user = await ApiWrapper.getUserInfo();
      ref.read(userProvider.notifier).setUser(user);
      gotoHomePage();
    } catch (e) {
      showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.blue, Colors.black26, Colors.black26]
          )
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: Text(isSigningUp ? 'Sign Up' : 'Sign In', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              AuthFormTextField(controller: _usernameController, hintText: '🧑 Username'),
              const SizedBox(height: 10),
              AuthFormTextField(controller: _passwordController, hintText: '🔑 Password', obscureText: true),
              const SizedBox(height: 10),
              if (isSigningUp) AuthFormTextField(controller: _emailController, hintText: '📧 Email'),
              const Text('Forgot password?'),
              const SizedBox(height: 30),
              AuthButton(isSigningUp: isSigningUp, onPressed: () async => _handleAuth(
                {
                  "username": _usernameController.text, 
                  if (isSigningUp) "email": _emailController.text, 
                  "password": _passwordController.text,
                  "selectedLanguage": "russian"
                }, 
                context
              )),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => isSigningUp = !isSigningUp), 
                child: Text(isSigningUp ? 'Already have an account? Sign in' :
                  'Don\'t have an account? Sign up'
                )
              ),
            ]
          ),
        ),
      )
    );
  }
}

class AuthButton extends StatelessWidget {
  final bool isSigningUp;
  final Function()? onPressed;

  const AuthButton({
    super.key,
    required this.isSigningUp,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(15),
      ),
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        onPressed: onPressed,
        child: FittedBox(
          child: Text(isSigningUp ? 'Sign Up' : 'Sign In', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        )
      ),
    );
  }
}

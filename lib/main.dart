import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/views/auth_view.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        // useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: Colors.grey,
        //   brightness: Brightness.dark,
        // ),
        // textTheme: const TextTheme(
        //   displayLarge: TextStyle(
        //     fontSize: 30,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ),
      home: const AuthView(),
    );
  }
}
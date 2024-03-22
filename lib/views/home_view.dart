import 'package:flutter/material.dart';
import 'package:fyp/views/flashcards_page.dart';
import 'package:fyp/views/sentences_view.dart';

import 'contacts_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: const [
        SentencesView(),
        ContactsView(),
        FlashcardsPage(),
      ],
    );
  }
}
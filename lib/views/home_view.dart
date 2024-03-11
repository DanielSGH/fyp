import 'package:flutter/material.dart';
import 'package:fyp/views/flashcards_page.dart';

import 'contacts_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        ContactsView(),
        FlashcardsPage(),
      ],
    );
  }
}
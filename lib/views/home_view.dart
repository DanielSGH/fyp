import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
  int selectedPage = 1;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: selectedPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.92,
              child: PageView(
                controller: controller,
                children: const [
                  SentencesView(),
                  ContactsView(),
                  FlashcardsPage(),
                ],
                onPageChanged: (int index) {
                  setState(() {
                    selectedPage = index;
                  });
                },
              ),
            ),
            BottomNavigationBar(
              currentIndex: selectedPage,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.article),
                  label: 'Sentences',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.contacts),
                  label: 'Contacts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.crop_portrait),
                  label: 'Flashcards',
                ),
              ],
              onTap: (int index) {
                controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
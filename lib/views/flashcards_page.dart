import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/classes/flashcards/enums/card_rating.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/flashcards/fsrs_api.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:fyp/views/all_card_stats_view.dart';
import 'package:fyp/views/basic_card_stats_view.dart';

import 'package:fyp/widgets/flashcard_widget.dart';

class FlashcardsPage extends ConsumerStatefulWidget {
  const FlashcardsPage ({
    Key? key,
  }) : super(key: key);
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends ConsumerState<FlashcardsPage> {
  List<FlashCard> dueCards = [], reviewedCards = [];
  FlashCard currentCard = FlashCard();
  FSRS fsrs = FSRS();

  Future<void> loadFlashcards() async {
    dueCards = List.of(ref.read(userProvider).flashcards ?? <FlashCard>[
      FlashCard()
    ]);

    dueCards.retainWhere((card) {
      return card.due == null || card.due!.isBefore(DateTime.now());
    });

    setState(() {
      currentCard = dueCards[0];
    });
  }

  @override
  void initState() {
    super.initState();
    currentCard.word = 'Loading...';
    loadFlashcards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Flashcards'),
            // IconButton(
            //   icon: const Icon(Icons.refresh),
            //   onPressed: () {
            //     setState(() {
            //       int idx = dueCards.indexOf(currentCard);
            //       if (idx < 1) {
            //         return;
            //       }

            //       currentCard = reviewedCards.removeLast();
            //     });
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BasicCardStatsView()));
              },
            ),
          ],
        ),
      ),
      body: FlashcardWidget(
        flashCard: currentCard,
        changeCard: (CardRating rating) {
          int idx = dueCards.indexOf(currentCard);
          FlashCard oldCard = FlashCard.copy(obj: dueCards[idx]);
          setState(() {
            reviewedCards.add(oldCard);
            dueCards[idx] = fsrs.repeat(currentCard, DateTime.now())[rating]!.card;
            currentCard = dueCards.elementAt(idx + 1);
            ref.read(userProvider.notifier).updateFlashCard(dueCards[idx]);
          });

          ApiWrapper.updateFlashcard(oldCard, dueCards[idx], ref.read(userProvider).selectedLanguages![0]);
        },
      ),
    );
  }
}

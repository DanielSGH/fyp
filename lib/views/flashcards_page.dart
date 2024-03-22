import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:fyp/classes/flashcards/enums/card_rating.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/flashcards/fsrs_api.dart';
import 'package:fyp/providers/user_provider.dart';

import 'package:fyp/widgets/flashcard_widget.dart';

class FlashcardsPage extends ConsumerStatefulWidget {
  const FlashcardsPage ({
    Key? key,
  }) : super(key: key);
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends ConsumerState<FlashcardsPage> {
  List<FlashCard> dueCards = [];
  FlashCard currentCard = FlashCard();
  FSRS fsrs = FSRS();

  Future<void> loadFlashcards() async {
    dueCards = ref.read(userProvider).flashcards ?? <FlashCard>[
      FlashCard()
    ];

    dueCards.retainWhere((card) {
      return card.due.isBefore(DateTime.now());
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
        title: Text(ref.watch(userProvider).username),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: FlashcardWidget(
        flashCard: currentCard,
        changeCard: (CardRating rating) {
          int idx = dueCards.indexOf(currentCard);
          FlashCard oldCard = dueCards[idx];
          setState(() {
            dueCards[idx] = fsrs.repeat(currentCard, DateTime.now())[rating]?.card as FlashCard;
            currentCard = dueCards.elementAt(idx + 1);
          });

          ApiWrapper.updateFlashcard(oldCard, dueCards[idx], ref.read(userProvider).selectedLanguages![0]);
        },
      ),
    );
  }
}

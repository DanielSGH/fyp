import 'package:fyp/classes/flashcards/enums/card_state.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/flashcards/review_log.dart';
import 'package:fyp/classes/flashcards/scheduling_info.dart';

import 'enums/card_rating.dart';

class SchedulingCards {
  FlashCard easy, okay, poor, again;

  SchedulingCards(this.easy, this.okay, this.poor, this.again);

  SchedulingCards.newSchedulingCards(FlashCard card) : 
    easy = FlashCard.copy(obj: card),
    okay = FlashCard.copy(obj: card),
    poor = FlashCard.copy(obj: card),
    again = FlashCard.copy(obj: card);

  void updateState(CardState state) {
    if (state == CardState.New) {
      easy.state = CardState.Review;
      okay.state = CardState.Learning;
      poor.state = CardState.Learning;
      again.state = CardState.Learning;
    }
    else if (state == CardState.Learning || state == CardState.Relearning) {
      easy.state = CardState.Review;
      okay.state = CardState.Review;
      poor.state = state;
      again.state = state;
    }
    else if (state == CardState.Review) {
      easy.state = CardState.Review;
      okay.state = CardState.Review;
      poor.state = CardState.Review;
      again.state = CardState.Relearning;
      again.lapses += 1;
    }
  }

  void schedule(DateTime now, int poorInterval, int okayInterval, int easyInterval) {
    again.scheduledDays = 0;
    poor.scheduledDays = poorInterval;
    okay.scheduledDays = okayInterval;
    easy.scheduledDays = easyInterval;
    again.due = now.add(const Duration(minutes: 5));

    if (poorInterval > 0) {
      poor.due = now.add(Duration(days: poorInterval));
    }
    else {
      poor.due = now.add(const Duration(minutes: 10));
    }

    okay.due = now.add(Duration(days: okayInterval));
    easy.due = now.add(Duration(days: easyInterval));
  }

  Map<CardRating, SchedulingInfo> recordLog(FlashCard card, DateTime now) {
    return {
      CardRating.Again: SchedulingInfo(again, ReviewLog(CardRating.Again.index, again.scheduledDays, again.elapsedDays, now, card.state.index)),
      CardRating.Poor: SchedulingInfo(poor, ReviewLog(CardRating.Poor.index, poor.scheduledDays, poor.elapsedDays, now, card.state.index)),
      CardRating.Okay: SchedulingInfo(okay, ReviewLog(CardRating.Okay.index, okay.scheduledDays, okay.elapsedDays, now, card.state.index)),
      CardRating.Easy: SchedulingInfo(easy, ReviewLog(CardRating.Easy.index, easy.scheduledDays, easy.elapsedDays, now, card.state.index))
    };
  }
}
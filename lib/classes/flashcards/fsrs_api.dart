import 'dart:math';

import 'package:fyp/classes/flashcards/enums/card_rating.dart';
import 'package:fyp/classes/flashcards/enums/card_state.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:fyp/classes/flashcards/fsrs_parameters.dart';
import 'package:fyp/classes/flashcards/scheduling_cards.dart';
import 'package:fyp/classes/flashcards/scheduling_info.dart';

class FSRS {
  Parameters p;
  // ignore: non_constant_identifier_names
  double DECAY, FACTOR;

  FSRS._(this.p, this.DECAY, this.FACTOR);

  factory FSRS() {
    return FSRS._(Parameters(), -0.5, pow(0.9, (1 / -0.5)) - 1);
  }

  Map<CardRating, SchedulingInfo> repeat(FlashCard card, DateTime now) {
    FlashCard cardCopy = FlashCard.copy(obj: card);

    if (cardCopy.state == CardState.New) {
      cardCopy.elapsedDays = 0;
    }
    else {
      cardCopy.elapsedDays = now.difference(cardCopy.lastReview).inDays;
    }

    cardCopy.lastReview = now;
    cardCopy.reps += 1;
    SchedulingCards s = SchedulingCards.newSchedulingCards(cardCopy);
    s.updateState(cardCopy.state);

    if (cardCopy.state == CardState.New) {
      initDs(s);

      s.again.due = now.add(const Duration(minutes: 1));
      s.poor.due = now.add(const Duration(minutes: 5));
      s.okay.due = now.add(const Duration(minutes: 10));
      int easyInterval = nextInterval(s.easy.stability);
      s.easy.due = now.add(Duration(days: easyInterval));
      s.easy.scheduledDays = easyInterval;
    }

    else if (cardCopy.state == CardState.Learning || cardCopy.state == CardState.Relearning) {
      int poorInterval = 0;
      int okayInterval = nextInterval(s.okay.stability);
      int easyInterval = max(nextInterval(s.easy.stability), okayInterval + 1);

      s.schedule(now, poorInterval, okayInterval, easyInterval);
    }

    else if (cardCopy.state == CardState.Review) {
      int interval = cardCopy.elapsedDays;
      double lastD = cardCopy.difficulty;
      double lastS = cardCopy.stability;
      num retrievability = forgettingCurve(interval, lastS);
      nextDs(s, lastD, lastS, retrievability);

      int poorInterval = nextInterval(s.poor.stability);
      int okayInterval = nextInterval(s.okay.stability);
      poorInterval = min(poorInterval, okayInterval);
      okayInterval = max(okayInterval, poorInterval + 1);
      int easyInterval = max(nextInterval(s.easy.stability), okayInterval + 1);
      s.schedule(now, poorInterval, okayInterval, easyInterval);
    }

    return s.recordLog(cardCopy, now);
  }

  void initDs(SchedulingCards s) {
    s.again.difficulty = initDifficulty(CardRating.Again.index);
    s.again.stability = initStability(CardRating.Again.index);
    s.poor.difficulty = initDifficulty(CardRating.Poor.index);
    s.poor.stability = initStability(CardRating.Poor.index);
    s.okay.difficulty = initDifficulty(CardRating.Okay.index);
    s.okay.stability = initStability(CardRating.Okay.index);
    s.easy.difficulty = initDifficulty(CardRating.Easy.index);
    s.easy.stability = initStability(CardRating.Easy.index);
  }

  void nextDs(SchedulingCards s, double lastD, double lastS, num retrievability) {
    s.again.difficulty = nextDifficulty(lastD, CardRating.Again.index);
    s.again.stability = nextForgetStability(lastD, lastS, retrievability);
    s.poor.difficulty = nextDifficulty(lastD, CardRating.Poor.index);
    s.poor.stability = nextRecallStability(lastD, lastS, retrievability, CardRating.Poor.index);
    s.okay.difficulty = nextDifficulty(lastD, CardRating.Okay.index);
    s.okay.stability = nextRecallStability(lastD, lastS, retrievability, CardRating.Okay.index);
    s.easy.difficulty = nextDifficulty(lastD, CardRating.Easy.index);
    s.easy.stability = nextRecallStability(lastD, lastS, retrievability, CardRating.Easy.index);
  }

  double initStability(int r) {
    return max(p.w[r-1], 0.1);
  }

  double initDifficulty(int r) {
    return min(max(p.w[4] - p.w[5] * (r - 3), 1), 10);
  }

  num forgettingCurve(int elapsedDays, double stability) {
    return pow(1 + FACTOR * elapsedDays / stability, DECAY);
  }


  int nextInterval(double s) {
    double newInterval = s / FACTOR * (pow(p.requestRetention, (1 / DECAY)) - 1);
    return min(max(newInterval.round(), 1), p.maximumInterval);
  }

  double nextDifficulty(double d, int r) {
    double nextD = d - p.w[6] * (r - 3);
    return min(max(meanReversion(p.w[4], nextD), 1), 10);
  }

  double meanReversion(double init, double current) {
    return p.w[7] * init + (1 - p.w[7]) * current;
  }

  double nextRecallStability(double d, double s, num r, int rating) {
    double hardPenalty = p.w[15];
    double easyBonus = p.w[16];
    
    if (rating == CardRating.Poor.index) {
      hardPenalty = 1;
    }
    
    if (rating == CardRating.Easy.index) {
      easyBonus = 1;
    }
    
    return s * (1 + exp(p.w[8]) *
          (11 - d) *
          pow(s, -p.w[9]) *
          (exp((1 - r) * p.w[10]) - 1) *
          hardPenalty *
          easyBonus);
  }

  double nextForgetStability(double d, double s, num r) {
    return p.w[11] *
          pow(d, -p.w[12]) *
          (pow(s + 1, p.w[13]) - 1) *
          exp((1 - r) * p.w[14]);
    }
}

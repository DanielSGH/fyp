import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/providers/user_provider.dart';

class AllCardStatsView extends ConsumerStatefulWidget {
  const AllCardStatsView({super.key});

  @override
  ConsumerState<AllCardStatsView> createState() => _CardStatsViewState();
}

class _CardStatsViewState extends ConsumerState<AllCardStatsView> {
  late List<FlashCard> cards;

  @override
  void initState() {
    super.initState();
    setState(() {
      cards = ref.read(userProvider).flashcards ?? <FlashCard>[
        FlashCard()
      ];
    });
  }

  Color getComputedColor(double val) {
    return getContrastingColor(getColorFromValue(val));
  }

  Color getContrastingColor(Color color) {
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    double threshold = 0.5;
    return luminance > threshold ? Colors.black : Colors.white;
  }

  Color getColorFromValue(double value) {
    value = value.clamp(0, 100);
    double hue = ((100 - value) / 100) * 120;
    double saturation = 0.6;
    double brightness = 0.67;
    HSVColor hsvColor = HSVColor.fromAHSV(1.0, hue, saturation, brightness);
    Color color = hsvColor.toColor();
    return color;
  }

  String _getLastSeenTimeText(DateTime? time) {
    if (time == null) {
      return 'Never';
    }

    DateTime now = DateTime.now();
    Duration difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${difference.inDays ~/ 7} weeks ago';
    }
  }

  List<dynamic> getStats(FlashCard card) {
    Color color = getComputedColor(card.difficulty);
    TextStyle style = TextStyle(color: color, fontSize: 80);
    return [
      Center(
        child: Column(
          children: [
            Text(
              card.word,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(card.english, style: TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis, color: color)),
            const SizedBox(height: 70),
            Icon(Icons.speed, color: color),
            Text(card.difficulty.toStringAsFixed(1), style: style),
          ],
        ),
      ),
    ];
  }

  SizedBox statCard(int idx) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: GestureDetector(
        onTap: () {
          var card = cards[idx];
          showDialog(
            context: context,
            builder: (BuildContext context) => SimpleDialog(
                title: Text(card.word),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text("Stability: ${card.stability.roundToDouble()}"),
                        Text("Elapsed Days: ${card.elapsedDays}"),
                        Text("Scheduled Days: ${card.stability}"),
                        Text("Reps: ${card.reps}"),
                        Text("Lapses: ${card.lapses}"),
                        Text("State: ${card.state.name}"),
                        Text("LastReview: ${_getLastSeenTimeText(card.lastReview)}"),
                      ],
                    ),
                  ),
                ]
              ),
          );
        },
        child: Card(
          color: getColorFromValue(cards[idx].difficulty * 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...getStats(cards[idx]),
            ],
          ),
        ),
      ),
    );
  }

  Wrap cardStats(int idx) {
    return Wrap(
      children: [
        statCard(idx),
        if (idx + 1 < cards.length)
          statCard(idx+1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Statistics'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < cards.length; i+=2)
              cardStats(i),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/classes/flashcards/enums/card_state.dart';
import 'package:fyp/providers/user_provider.dart';
import 'package:pie_chart/pie_chart.dart';

class BasicCardStatsView extends ConsumerStatefulWidget {
  const BasicCardStatsView({Key? key}) : super(key: key);

  @override
  ConsumerState<BasicCardStatsView> createState() => BasicCardStatsViewState();
}

class BasicCardStatsViewState extends ConsumerState<BasicCardStatsView> {
  Color getContrastingColor(Color color) {
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    double threshold = 0.5;
    return luminance > threshold ? Colors.green : Colors.red;
  }

  Color getColorFromValue(double value) {
    value *= 10;
    value = value.clamp(0, 100);
    double hue = ((100 - value) / 100) * 120;
    double saturation = 0.6;
    double brightness = 0.67;
    HSVColor hsvColor = HSVColor.fromAHSV(1.0, hue, saturation, brightness);
    Color color = hsvColor.toColor();
    return color;
  }

  Color getComputedColor(double val) {
    return getContrastingColor(getColorFromValue(val));
  }

  @override
  Widget build(BuildContext context) {
    var flashcards = ref.watch(userProvider).flashcards ?? [];
    int totalCards = flashcards.length;
    int completedCards = flashcards.where((card) => card.reps > 0).length;
    double averageDifficulty = flashcards.isNotEmpty
      ? flashcards.map((card) => card.difficulty).reduce((a, b) => a + b) / flashcards.length
      : 0.0;
    int cardsDueNow = flashcards.where((card) => card.due == null || (card.due != null && card.due!.isBefore(DateTime.now()))).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Stats'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  child: ListTile(
                    title: Container(margin: const EdgeInsets.only(bottom: 20), child: const Text('Card States')),
                    subtitle: FittedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: PieChart(
                          dataMap: {
                            for (var states in CardState.values)
                              states.toString().split('.').last: flashcards.where((card) => card.state == states).length.toDouble(),
                          },
                          chartType: ChartType.ring,
                          chartRadius: 100,
                          colorList: const [
                            Colors.green, 
                            Color.fromARGB(255, 255, 31, 15), 
                            Colors.blue, 
                            Colors.orange, 
                            Colors.purple, 
                            Colors.deepOrange, 
                            Color.fromARGB(255, 255, 135, 209)
                          ],
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: false,
                          ),
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  child: ListTile(
                    title: Container(margin: const EdgeInsets.only(bottom: 20), child: const Text('Average Difficulty (lower is better)')),
                    subtitle: CircleAvatar(
                      radius: 60,
                      backgroundColor: getColorFromValue(averageDifficulty),
                      child: Text(
                        averageDifficulty.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fyp/classes/flashcards/enums/card_rating.dart';
import 'package:fyp/classes/flashcards/models/flashcard_model.dart';

class FlashcardWidget extends StatefulWidget {
  final FlashCard? flashCard;
  final Function changeCard;

  const FlashcardWidget({
    Key? key,
    this.flashCard,
    required this.changeCard,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showEnglish = false;

  void changeCardHandler(CardRating rating) {
    setState(() {
      showEnglish = false;
    });

    widget.changeCard(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              child: Center(child: Text(
                widget.flashCard?.word ?? "Loading...", 
                style: const TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black
                ), 
                textAlign: TextAlign.center)
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showEnglish = !showEnglish;
                  });
                },
                child: Center(
                  child: Text(
                    showEnglish ? widget.flashCard?.english ?? "Loading..." : "Tap to show translation",
                    style: const TextStyle(
                      fontSize: 20, 
                      color: Colors.black
                    ), 
                    textAlign: TextAlign.center
                  )
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(150, 0, 0, 0),
                    blurRadius: 20.0,
                    offset: Offset(0, 10.0),
                  )
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: FittedBox(
                        child: MaterialButton(
                          // padding: const EdgeInsets.all(27),
                          onPressed: () => changeCardHandler(CardRating.Easy),
                          child: const Text("Perfect"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      color: Colors.amber,
                      child: FittedBox(
                        child: MaterialButton(
                          // padding: const EdgeInsets.all(27),
                          onPressed: () => changeCardHandler(CardRating.Okay),
                          child: const Text("Okay"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: FittedBox(
                        child: MaterialButton(
                          // padding: const EdgeInsets.all(27),
                          onPressed: () => changeCardHandler(CardRating.Poor),
                          child: const Text("Poor"),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        )
      )
    );
  }
}
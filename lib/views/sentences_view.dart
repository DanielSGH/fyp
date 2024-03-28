import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp/classes/api/api_wrapper.dart';
import 'package:http/http.dart';

class SentencesView extends StatefulWidget {
  const SentencesView({Key? key}) : super(key: key);

  @override
  State<SentencesView> createState() => _SentencesViewState();
}

class _SentencesViewState extends State<SentencesView> {
  List sentences = [];
  int _index = 0;
  late Wrap proposedSentence;

  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    }
    getSentences();
    setState(() {
      proposedSentence = const Wrap(children: []);
    });
  }

  void getSentences() {
    ApiWrapper.sendGetReq(
      '/sentences?selectedLanguage=russian'
    ).then((response) {
      if (!mounted) return;

      setState(() {
        sentences = jsonDecode(response.body);
      });
   });
  }

  void resetButtonHandler() {
    setState(() {
      proposedSentence = const Wrap(children: []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sentences.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Sentences'),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(sentences[_index]['source'], 
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 20),
              proposedSentence,
              const SizedBox(height: 50),
              Center(
                child: Wrap(children: [
                  for (var i = 0; i < sentences[_index]['shuffled'].length; i++) 
                    TextButton(
                      onPressed: () {
                        if (proposedSentence.children.where((element) => element.key == Key(i.toString())).isNotEmpty) {
                          return;
                        }
        
                        setState(() {
                          proposedSentence = Wrap(children: [
                            ...proposedSentence.children,
                            ElevatedButton(onPressed: () {
                              setState(() {
                                proposedSentence = Wrap(children: [
                                  ...proposedSentence.children.where((element) => element.key != Key(i.toString())).toList()
                                ]);
                              });
                            }, key: Key(i.toString()), child: Text(sentences[_index]['shuffled'][i]))
                          ]);
                        });
                      },
                      child: Text(sentences[_index]['shuffled'][i], 
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.normal
                        )
                      )
                    )
                ]),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 4.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(150, 0, 0, 0),
                      blurRadius: 20.0,
                      offset: Offset(0, 10.0),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            final proposedString = proposedSentence.children.map((element) => ((element as ElevatedButton).child as Text).data).join(' ');
                            if (proposedString == sentences[_index]['target']) {
                              setState(() {
                                proposedSentence = const Wrap(children: []);
                                _index = (_index + 1) % (sentences.length - 1);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Correct!'),
                                  duration: Duration(milliseconds: 500),
                                )
                              );
                                
                              return;
                            }
                                
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incorrect! Try again.'),
                                duration: Duration(milliseconds: 500),
                              )
                            );
                          },
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.only(
                          ),
                        ),
                        child: MaterialButton(
                          onPressed: resetButtonHandler,
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            resetButtonHandler();
                            setState(() {
                              _index = (_index + 1) % (sentences.length - 1);
                            });
                          },
                          child: const Icon(Icons.keyboard_double_arrow_right, color: Colors.white)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 200),
            ]
          ),
        ),
      )
    );
  }
}
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
              const SizedBox(height: 10),
              ElevatedButton(
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
                child: const Text('Submit')
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    proposedSentence = const Wrap(children: []);
                  });
                },
                child: const Text('Reset')
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _index = (_index + 1) % (sentences.length - 1);
                  });
                },
                child: const Text('Skip'),
              ),
              const SizedBox(height: 200),
            ]
          ),
        ),
      )
    );
  }
}
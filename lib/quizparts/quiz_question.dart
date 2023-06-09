import 'package:flutter/material.dart';

import 'package:quiz_app/library.dart' as lib;

import 'answer_button.dart';

class QuizQuestion extends StatelessWidget {
  const QuizQuestion(this.questionNumber, this.score, this.processAnswer, {super.key});

  final int questionNumber;
  final int score;
  final Function processAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.only(left: lib.textMargin),
              child: Text(
                "question ${questionNumber + 1} of ${lib.questions.length}",
                style: lib.baseText,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: lib.textMargin),
              child: Text(
                "finish quiz before: ${lib.timeToFinish.day}-${lib.timeToFinish.month}-${lib.timeToFinish.year}",
                style: lib.baseText,
              ),
            )
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.25,
          //child: Image.asset('assets/images/' + lib.questions[questionNumber]["image"], fit: BoxFit.fitWidth,),
          child: Image.network(lib.questionImages[questionNumber], fit: BoxFit.fitWidth,),
        ),
        ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
          child: Center(
              child: Text(lib.questions[questionNumber]["question"], style: lib.headingText,)
          ),
        ),
        for(int i = 0; i < lib.questions[questionNumber]["answers"].length; i+=2) makeButtonRow(questionNumber, i)
      ],
    );
  }

  Widget makeButtonRow(questionNumber, answerNumber){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AnswerButton(
            lib.questions[questionNumber]["answers"][answerNumber],
            lib.questions[questionNumber]["rightAnswer"] == answerNumber,
            processAnswer
        ),
        if(answerNumber + 1 < lib.questions[questionNumber]["answers"].length)
          AnswerButton(
              lib.questions[questionNumber]["answers"][answerNumber+1],
              lib.questions[questionNumber]["rightAnswer"] == answerNumber + 1,
              processAnswer
          )
        //if ends here just putting this comment so i don't get confused by lack of  {}
      ],
    );
  }
}

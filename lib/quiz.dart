import 'package:flutter/material.dart';

import 'package:quiz_app/library.dart' as lib;
import 'package:quiz_app/quizparts/OutOfTimeScreen.dart';

import 'quizparts/quizQuestion.dart';
import 'quizparts/quizResult.dart';

class Quiz extends StatefulWidget {

  const Quiz({Key? key}) : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> with AutomaticKeepAliveClientMixin {
  int questionNumber = 0;
  int score = 0;

  @override
  void initState() {
    lib.restartQuiz.stream.listen((restartQuiz) {
      setState(() {
        questionNumber = score = 0;
      });
    });
    super.initState();
  }

  void processAnswer(bool isCorrect){
    print("processing answer");
    if(isCorrect){
      score++;
    }
    setState(() {
      questionNumber++;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(lib.timeToFinish.isBefore(DateTime.now())){
      return const OutOfTimeScreen();
    }
    else if (questionNumber >= lib.questions.length){
      return QuizResult(score);
    }else{
      return QuizQuestion(questionNumber, score, processAnswer);
    }
  }

  @override
  bool get wantKeepAlive{
    return true;
  }
}

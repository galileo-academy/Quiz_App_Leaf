library lib;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/firebase_options.dart';
import 'dart:async';
import 'dart:core';

const double textMargin = 10.0;
const TextStyle baseText = TextStyle(fontSize: 16);
const TextStyle headingText =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

List<dynamic> questions = [];
List<String> questionImages = [];
DateTime timeToFinish = DateTime(0, 0, 0);

var db = FirebaseFirestore.instance;
var firebaseStorage = FirebaseStorage.instance;

void initFireBase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setQuestionsFromDB();
}

void setQuestionsFromDB() async {
  await db.collection('questions').get().then((event) {
    //load stuff
    for (var doc in event.docs) {
      print("${doc.id} => ${doc.data()}");
      questions.add(doc.data());
    }
  });

  await db.collection('timeToFinishAt').get().then((event) {
    Timestamp timestamp;
    for (var doc in event.docs) {
      print("${doc.id} => ${doc.data()}");
      timestamp = doc.data()['time'];
      timeToFinish = DateTime.fromMicrosecondsSinceEpoch(
          timestamp.microsecondsSinceEpoch);
      print(timeToFinish);
    }
  });

  //load images from url
  for (int i = 0; i < questions.length; i++) {
    var ref = firebaseStorage.ref().child(questions[i]["image"]);
    String url = await ref.getDownloadURL();
    print(url);
    questionImages.add(url);
  }
}

void submitScore(int score) async {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print("user is not logged in on submitScore, should never happen");
    } else {
      final scoreData = {"score": score, "uid": user.uid};
      db.collection("scores").doc(user.uid).set(scoreData);


    }
  });
}

Future<bool> doesUserAnswerExist() async {
  bool answerExists = false;


  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if(user == null){
      print("user is not logged in on doesUserAnswerExist");
      answerExists = true;//it's not actually true but i don't want anyone not logged in to submit
    }
    else{
      db
          .collection("scores")
          .where("uid", isEqualTo: user.uid)
          .get()
          .then((querySnapShot) {
        print("successfully completed");
        for (var docSnapshot in querySnapShot.docs) {
          print("${docSnapshot.id} => ${docSnapshot.data()}");
          answerExists = true;
        }
      },
          onError: (e) => print("Error completing: $e")
      );
    }
  });
  return answerExists;
}

late UserCredential credential;
StreamController<bool> restartQuiz = StreamController<bool>.broadcast();

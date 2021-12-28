
// ----- QuizDisplay -----
// Description: Displays all the quizzes available on the application.
// Libraries: The QuizDisplay will display the available quizzes with two
//            quizzes per row. Each quiz is selectable and will redirect the
//            user to the quiz page where the quiz can be attempted.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Screens/QuizScreen.dart';

// Class: QuizDisplay
// Description: On initiation, retrieves the titles of quizzes available and
// displays them in a selectable list.
class QuizDisplay extends StatefulWidget {
  // Constructor
  QuizDisplay({Key key, this.quizzes}) : super(key: key);

  List<Map<String, dynamic>> quizzes = [];

  // Function: createState
  @override
  _QuizDisplayState createState() => new _QuizDisplayState(quizzes: quizzes);
} // end QuizDisplay

class _QuizDisplayState extends State<QuizDisplay> {
  // Constructor
  _QuizDisplayState({this.quizzes});

  // Attribute
  List<Map<String, dynamic>> quizzes;

  // Function: initState
  // Description: Retrieves a list of available quiz titles.
  @override
  void initState() {
    super.initState();
  } // end initState

  // Function: build
  // Description: Initiates the QuizSet widget, displaying all available quiz
  // titles which can be selected by the user.
  @override
  Widget build(BuildContext context) {
    return new QuizSet(quizzes : quizzes);
  } // end build
} // end _QuizDisplayState

class QuizSet extends StatefulWidget {
  QuizSet({Key key, this.quizzes}) : super(key: key);

  final List<Map<String, dynamic>> quizzes;

  @override
  _QuizSetState createState() => new _QuizSetState(quizzes: quizzes);
}

class _QuizSetState extends State<QuizSet> {
  _QuizSetState({this.quizzes});

  final List<Map<String, dynamic>> quizzes;
  List<List<Map<String, dynamic>>> rows = [];

  @override
  void initState() {
    super.initState();
    for(int i = 0; i < quizzes.length; i++) {
      Map<String, dynamic> t1 = quizzes[i];
      Map<String, dynamic> t2 = {'quizID': -1, 'title': '', 'description': ''};
      if(++i < quizzes.length) {
        t2 = quizzes[i];
      }
      List<Map<String, dynamic>> l = [t1, t2];
      rows.add(l);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: (MediaQuery.of(context).size.width),
      child: new Center(
          child: new Column(
            children: <Widget>[
              for(var r in rows) QuizSetRow(quizzes : r),
            ],
          )
      ),
    );
  }
}

class QuizSetRow extends StatelessWidget {
  QuizSetRow({Key key, this.quizzes});

  final List<Map<String, dynamic>> quizzes;

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: (MediaQuery.of(context).size.width),
      height: 300.0,
      //color: Colors.lightBlueAccent,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for(var quiz in quizzes) QuizButton(quiz : quiz),
        ]
      )
    );
  } // end build
} // end QuizSetRow

class QuizButton extends StatelessWidget {
  QuizButton({Key key, this.quiz}) : super(key : key);

  final Map<String, dynamic> quiz;

  @override
  Widget build(BuildContext context) {
    if(quiz['title'].isEmpty) {
      return new ElevatedButton(
        onPressed: null,
        child: new Container(
          width: 180.0,
          height: 180.0,
        ),
      );
    }
    return new ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new QuizScreen(quiz : quiz)),
        );
      },
      child: new Container(
        width: 180.0,
        height: 180.0,
        child: new Center(
          child: new Text(
            quiz['title'],
            style: new TextStyle(
              fontSize: 20,
            )
          ),
        ),
      ),
    );
  }
}
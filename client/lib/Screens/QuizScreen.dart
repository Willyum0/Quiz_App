
// ----- QuizScreen -----
// Description: This displays the quizzes with two placed in a row. Each quiz
//              displayed will be a button that will direct the user to the
//              quiz screen. This will push the screen onto the stack.
// Libraries: The QuizScreen implements the Dio library, used to request a
//            list of questions for a quiz. The dart convert library is used
//            to convert JSON content to List and Map objects.
//            The Question object is implemented to store a question and a list
//            of the answers.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import '../Components/Question.dart';

// Define a callback function for the change of the quiz screen.
typedef QuizScreenChangeCallback = Function();
// Define a callback function for the change of the quiz screen.
typedef QuizScreenReturnCallback = Function(BuildContext context);
// Define a callback function for selecting an answer for a quiz question.
typedef QuizQuestionSelectCallback = Function(int question, int selected);



// Class: QuizScreen
// Description: Creates a State widget used to create the quiz screen.
class QuizScreen extends StatefulWidget {
  // Constructor
  QuizScreen({Key key, this.quiz}) : super(key : key);
  final Map<String, dynamic> quiz;   // Quiz selected to be attempted.

  // Function: createState
  @override
  _QuizScreenState createState() => new _QuizScreenState(quiz : quiz);
} // end QuizScreen

// Class: _QuizScreenState
// Description: Creates the quiz screen, displaying the quiz information in
//              three states:
//                - Start state, where the user will be displayed the quiz
//                  information.
//                - A display of the quiz questions, where the user attempts
//                  the questions.
//                - The results of the quiz, with the results of the user's
//                  attempt.
class _QuizScreenState extends State<QuizScreen> {
  // Constructor
  _QuizScreenState({this.quiz});
  final Map<String, dynamic> quiz;  // Selected quiz being attempted.
  final String baseURL = 'http://localhost:8085'; // Base URL used to call the
                                                  // server.
  int correct = 0;                  // Stores the number of correct answers.
  int attempted = 0;                // Stores the number of attempted questions.
  double score = 0.0;               // Used to calculate final score.
  bool startState = true;           // Defines start state of the quiz screen.
  bool finishState = false;         // Defines finish state of the quiz screen.
  List<Question> questions = [];    // List of questions of the quiz.
  List<List<bool>> aStates = [];    // State of the answers selected by user.

  // Function: _startQuiz
  // Description: Starts the quiz, changing the quiz screen state from start
  //              state to display the quiz questions.
  void _startQuiz() {
    setState(() {
      startState = false;
    });
  } // end _startQuiz

  // Function: _finishQuiz
  // Description: Finishes the quiz, changing the quiz screen state from the
  //              display of questions to display the finished results.
  void _finishQuiz() {
    setState(() {
      finishState = true;
    });
    // Calculate quiz results.
    _calculateResults();
  } // end _finishQuiz

  // Function: _retryQuiz
  // Description: Resets the quiz, changing the quiz screen state from
  //              displaying the finished results to displaying the start of
  //              the quiz.
  void _retryQuiz(BuildContext context) {
    setState(() {
      // Reset all quiz results.
      score = 0.0;
      attempted = 0;
      correct = 0;
      finishState = false;
      startState = true;
      // Clear the state of all quiz answers.
      _clearAnswerStates();
    });
  } // end _retryQuiz

  // Function: _closeQuiz
  // Description: Closes the quiz, popping the quiz screen off the stack.
  void _closeQuiz(BuildContext context) {
    Navigator.pop(context);
  } // end _closeQuiz

  // Function: initState
  // Description: Initiates the super
  @override
  void initState() {
    super.initState();
  }

  // Function: _getQuestions
  // Description: Retrieves the questions for a specified quiz from the
  //              backend.
  Future<List<Map<String, dynamic>>> _getQuestions() async {
    final Dio dio = new Dio();  // Initiate Dio object.

    try {
      // Retrieve quiz questions from backend.
      var response = await dio.get(
          "$baseURL/quizQuestions",
          queryParameters: {'quiz': quiz['quizID']}
          ).then((response) {
        return response;    // Return data from the Future object.
      })
          .catchError((error) {
        print(error);       // Catch any errors.
      });
      // Convert response data from JSON to List object.
      List<dynamic> vals = json.decode(response.toString());
      List<Map<String, dynamic>> res = [];
      // For each question in the list, convert from dynamic to
      // Map<String, dynamic>.
      for(var el in vals) {
        Map<String, dynamic> val = el;
        res.add(val);
      }
      return Future.value(res);
    } on DioError catch (e) {
      print(e);
    }
    return Future.value([]);
  } // end _getQuestions

  // Function: _getAnswers
  // Description: Retrieves the answers for a specified quiz from the
  //              backend.
  Future<List<List<Map<String, dynamic>>>> _getAnswers() async {
    final Dio dio = new Dio();    // Initiates Dio object.

    try {
      // Retrieve quiz answers from backend.
      var response = await dio.get(
          "$baseURL/quizAnswers",
          queryParameters: {'quiz': quiz['quizID']}
          ).then((response) {
        return response;
      })
          .catchError((error) {
        print(error);
      });
      // Convert response data from JSON to List object.
      List<dynamic> vals = json.decode(response.toString());
      List<List<Map<String, dynamic>>> res = [];
      // For each answer in the list, convert from dynamic to
      // Map<String, dynamic>.
      for(var l in vals) {
        List<dynamic> answers = l;
        List<Map<String, dynamic>> addition = [];
        for(var a in answers) {
          Map<String, dynamic> answer = a;
          addition.add(answer);
        }
        res.add(addition);
      }
      return Future.value(res);
    } on DioError catch (e) {
      print(e);
      return Future.value([]);
    }
  } // end _getAnswers

  // Function: _getQAndA
  // Description: Retrieves the questions and answers for a specified quiz.
  Future<List<Question>> _getQAndA() async {
    // If the questions and answers have already been retrieved.
    if(questions.isNotEmpty) {
      _initAnswerStates();
      return questions;
    }
    // Retrieve the questions.
    var qs = await _getQuestions()
        .then((response) {
          return response;
    })
        .catchError((error) {
          print(error);
    });
    // Retrieve the answers.
    var as = await _getAnswers()
        .then((response) {
      return response;
    })
        .catchError((error) {
      print(error);
    });
    // If the list of questions and answers are of same length.
    if(qs.length == as.length) {
      List<Question> questions = [];
      // For each question and set and related answers, create a new Question
      // object.
      for(int i = 0; i < qs.length; i++) {
        Question q = new Question(question: qs[i], answers: as[i]);
        questions.add(q);
      }
      // Initiate the answer states.
      _initAnswerStates();
      this.questions = questions;
      return questions;
    // If the list of questions and answers are not the same length.
    } else {
      // create an empty list of questions.
      this.questions = [];
      return [];
    }
  } // end _getQAndA

  // Function: initAnswerStates
  // Description: Initiates the answers states of the quiz.
  void _initAnswerStates() {
    // For each question, create a list of states for each answer.
    for(var as in questions) {
      List<bool> states = [];
      // For each answer, set its state to false (not selected)
      for(int i = 0; i < as.answers.length; i++) {
        states.add(false);
      }
      aStates.add(states);
    }
  } // end _initAnswerStates

  // Function: _clearAnswerStates
  // Description: Clears the answer states of the quiz and the quiz statistics.
  void _clearAnswerStates() {
    aStates = [];
    _initAnswerStates();
  } // end _clearAnswerStates

  // Function: _handleAnswerSelectedChange
  // Description: Changes the state of the answer selected for a specified
  //              question.
  void _handleAnswerSelectedChange(int question, int selected) {
    question = question - 1;
    selected = selected - 65;
    setState(() {
      // If the selected question is within range of the list of states
      if(question <= aStates.length &&
          question >= 0) {
        // If the selected answer is within range of the list of states
        if(selected <= aStates[question].length &&
            selected >= 0) {
          // Set all answer states to false.
          for(int i = 0; i < aStates[question].length; i++) {
            aStates[question][i] = false;
          }
          // Changes state of the selected answer
          aStates[question][selected] = !aStates[question][selected];
        }
      }
    });
  } // end _handleAnswerSelectedChange

  // Function: _calculateResults
  // Description: Calculate the results of the attempted quiz.
  void _calculateResults() {
    score = 0;
    // For each question in the quiz.
    for(int i = 0; i < questions.length; i++) {
      // For each answer of a question.
      for(int j = 0; j < questions[i].answers.length; j++) {
        // If the answer was selected and is the correct answer.
        if(questions[i].answers[j]['isCorrect'] && aStates[i][j]) {
          correct++;
          attempted++;
          break;
        // If the answer was selected.
        } else if(aStates[i][j]) {
          attempted++;
        }
      }
    }
    score = correct / questions.length * 100;
  } // end _calculateResults

  // Function: build
  // Description: Displays the menu bar, home page title and the available
  //              quizzes on the application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new CloseButton(
          onPressed: () {
            Navigator.pop(context);
          }
        )
      ),
      body: new FutureBuilder<List<Question>>(
        future: _getQAndA(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // If an empty list was returned or an error occurs in retrieving the
          // list of questions.
          if(snapshot.hasData && snapshot.data.isEmpty || snapshot.hasError) {
            return new Center(
              child: new Text('error')
            );
          // If the list of questions is returned.
          } else if(snapshot.hasData) {
            // If screen is displaying the start screen of the quiz.
            if(startState) {
              return new SingleChildScrollView(
                child: new Column(
                    children: <Widget>[
                      new QuizScreenStartTitle(
                          title: quiz['title'],
                          desc: quiz['description']
                      ),
                      new QuizScreenStart(
                          numQuestions: questions.length,
                          onScreenChanged: _startQuiz
                      ),
                    ]
                ),
              );
            // If screen is displaying the questions of the quiz.
            } else if(!startState && !finishState) {
              return new SingleChildScrollView(
                child: new Column(
                    children: <Widget>[
                      new QuizScreenQuestions(
                          questions: questions,
                          aStates: aStates,
                          onSelected: _handleAnswerSelectedChange
                      ),
                      new QuizScreenQuestionsFinished(
                          onFinish: _finishQuiz
                      ),
                    ]
                ),
              );
            // If screen is displaying the results of the quiz.
            } else {
              return new SingleChildScrollView(
                child: new Container(
                    child: new Column(
                        children: <Widget>[
                          new Container(
                            height: 80,
                          ),
                          new QuizScreenFinished(
                            numQuestions: questions.length,
                            correct: correct,
                            attempted: attempted,
                            score: score
                          ),
                          new QuizScreenFinishedReturn(
                            closeQuiz: _closeQuiz,
                            retryQuiz: _retryQuiz,
                          )
                        ]
                    )
                ),
              );
            }
          // If the list of questions is currently being retrieved.
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      )
    );
  } // end build
} // end _QuizScreenState

// Class: QuizScreenStartTitle
// Description: Displays the title of the quiz, consisting of the quiz topic
//              and its description.
class QuizScreenStartTitle extends StatelessWidget {
  // Constructor
  QuizScreenStartTitle({Key key, this.title, String desc}) : super(key: key) {
    this.desc = desc == null ? 'Give this challenge a try!' : desc;
  }
  final String title;
  String desc = '';

  // Function: build
  // Description: Displays a container consisting of the quiz title and its
  //              description.
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        padding: EdgeInsets.all(20.0),
        width: (MediaQuery.of(context).size.width),
        color: Colors.pink,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              height: 100.0,
              child: new Text(
                title,
                style: new TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            new Container(
              height: 60.0,
              child: new Text(
                  desc,
                  style: new TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  )
              )
            )
          ]
        ),
      ),
    );
  } // end build
} // end QuizScreenStartTitle

// Function: QuizScreenStart
// Description: This will display the details of the quiz, including the number
//              of questions. A start button will move the user to the next
//              stage of the quiz, where they can attempt the questions.
class QuizScreenStart extends StatelessWidget {
  // Constructor
  QuizScreenStart({
    Key key,
    this.numQuestions,
    this.onScreenChanged
  }) : super(key: key);

  final int numQuestions;
  final QuizScreenChangeCallback onScreenChanged;

  // Function: build
  // Description: Displays the details of the exam and the start button.
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Container(
        padding: EdgeInsets.only(
            top: ((MediaQuery.of(context).size.height) / 4)
        ),
        width:(MediaQuery.of(context).size.width) / 1.5,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              child: new Column(
                children: <Widget>[
                  new Container(
                    width: 230.0,
                    height: 40.0,
                    child: new Row(
                      children: <Widget>[
                        new Text(
                            'Number of questions: ',
                            style: new TextStyle(
                              fontSize: 20.0,
                            )
                        ),
                        new Text(
                            numQuestions.toString(),
                            style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                            )
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    width: 230.0,
                    height: 40.0,
                    child: new Row(
                      children: <Widget>[
                        new Text(
                            'Time Limit: ',
                            style: new TextStyle(
                              fontSize: 20.0,
                            )
                        ),
                        new Text(
                            '...',
                            style: new TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ],
                    ),
                  )
                ]
              ),
            ),
            new Column(
              children: <Widget>[
                new Container(
                  child: new ElevatedButton(
                    style: new ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    onPressed: () => onScreenChanged(),
                    child: new Container(
                      width: 80,
                      height: 40,
                      child: new Center(
                        child: new Text(
                            'Start',
                            style: new TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            )
                        ),
                      )
                    )
                  ),
                ),
              ],
            ),
          ]
        ),
      ),
    );
  } // end build
} // end QuizScreenStart

// Class: QuizScreenQuestions
// Description: This will display the quiz questions in a list.
class QuizScreenQuestions extends StatelessWidget {
  // Constructor
  QuizScreenQuestions({
    Key key,
    this.questions,
    this.aStates,
    this.onSelected
  }) : super(key: key);

  final List<Question> questions;
  final List<List<bool>> aStates;
  final QuizQuestionSelectCallback onSelected;

  // Function: build
  // Description: Displays the quiz questions in a list, scrollable from top
  //              to bottom of the screen.
  @override
  Widget build(BuildContext context) {
    return new Column(
        children: <Widget>[
          for(int i = 0; i < questions.length; i++)
            new QuizQuestion(
                question: questions[i],
                num: (i + 1),
                aStates: aStates[i],
                onChange: onSelected
            ),
        ]
    );
  } // end build
} // end QuizScreenQuestions

// Class: QuizQuestion
// Description: This will display a question in the quiz in the form of a
//              multiple choice question.
class QuizQuestion extends StatelessWidget {
  // Constructor
  QuizQuestion({
    Key key,
    this.question,
    this.num,
    this.aStates,
    this.onChange
  }) : super(key: key);

  final Question question;
  final int num;
  final List<bool> aStates;
  final QuizQuestionSelectCallback onChange;

  // Function: build
  // Description: Displays the question of a quiz in multiple choice format.
  //              Each answer will have a corresponding selection button.
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        margin: EdgeInsets.only(top: 80),
        child: new Column(
          children: <Widget>[
            new Container(
              width: (MediaQuery.of(context).size.width / 3),
              child: new Text(
                  ('Question ' + num.toString()),
                  style: new TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  )
              ),
            ),
            new Container(
              padding: EdgeInsets.only(top: 20),
              width: (MediaQuery.of(context).size.width / 3),
              child: new Text(
                question.getQuestion(),
                style: new TextStyle(
                  fontSize: 22,
                )
              ),
            ),
            new Container(
              height: 200,
              width: (MediaQuery.of(context).size.width / 3),
              child: new AnswerSet(
                  question: num,
                  answers: question.answers,
                  aStates: aStates,
                  onChange: onChange
              ),
            ),
          ]
        )
      ),
    );
  } // end build
} // end QuizQuestion

// Class: QuizScreenQuestionsFinished
// Description: This will display that end of the quiz, where the user is
//              notified they have reached the last question and can finish
//              the quiz.
class QuizScreenQuestionsFinished extends StatelessWidget {
  // Constructor
  QuizScreenQuestionsFinished({Key key, this.onFinish}) : super(key: key);

  final QuizScreenChangeCallback onFinish;

  // Function: build
  // Description: Displays the end of quiz text and a button that finishes
  //              the quiz.
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: (MediaQuery.of(context).size.width),
      height: 200,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: (MediaQuery.of(context).size.width / 4),
          ),
          new Container(
            width: ((MediaQuery.of(context).size.width) / 4),
            child: new Text(
                '- - - - - End of Quiz - - - - -',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: 20,
                ),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(
                ((MediaQuery.of(context).size.width) / 9),
                0.0,
                ((MediaQuery.of(context).size.width) / 9),
                0.0
            ),
            child: new ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: new Size(80, 40),
              ),
              onPressed: () => onFinish(),
              child: new Text('Finish')
            )
          ),
        ]
      ),
    );
  } // end build
} // end QuizScreenQuestionsFinished

// Class: QuizScreenFinished
// Description: Displays the results of the quiz and the return options for the
//              user to select.
class QuizScreenFinished extends StatelessWidget {
  // Constructor
  QuizScreenFinished({
    Key key,
    this.numQuestions,
    this.correct,
    this.attempted,
    this.score
  }) : super(key: key);

  final int numQuestions;
  final int correct;
  final int attempted;
  final double score;

  // Function: build
  // Description: Displays the results of the quiz attempt and the returning
  //              options to the user. This includes closing the quiz or
  //              re-attempting the quiz.
  Widget build(BuildContext context) {
    return new Container(
        padding: EdgeInsets.only(top: 20),
        width: 700,
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey,
              width: 3
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: new Column(
            children: <Widget>[
              new Center(
                  child: new Container(
                    margin: EdgeInsets.only(
                        right: ((MediaQuery.of(context).size.width) / 5)
                    ),
                    child: new Text(
                      'Results',
                      style: new TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
              new QuizResults(
                quizLength: numQuestions,
                correct: correct,
                attempted: attempted,
                score: score,
              ),
            ]
        )
    );
  } // end build
} // QuizScreenFinished

// Class: QuizResults
// Description: This will display the results of a quiz attempt.
class QuizResults extends StatelessWidget {
  // Constructor
  QuizResults({
    Key key,
    this.quizLength,
    this.correct,
    this.attempted,
    this.score
  }) : super(key: key);

  final int quizLength;
  final int correct;
  final int attempted;
  final double score;

  // Function: build
  // Description: Displays the statistics of the quiz attempt.
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
          child: new Center(
              child: new Container(
                padding: EdgeInsets.only(top: 20),
                width: 600,
                child: new Row(
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        new Container(
                          width: 250,
                          child: new Text(
                              'Total Questions: ',
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        ),
                        new Container(
                          width: 250,
                          child: new Text(
                              'Total Questions Attempted: ',
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        ),
                        new Container(
                          width: 250,
                          child: new Text(
                              'Total Correct Answers: ',
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        ),
                        new Container(
                          width: 250,
                          child: new Text(
                              'Score: ',
                              textAlign: TextAlign.right,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        )
                      ],
                    ),
                    new Column(
                      children: <Widget>[
                        new Container(
                          padding: EdgeInsets.only(left: 20),
                          width: 200,
                          child: new Text(
                              quizLength.toString(),
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        ),
                        new Container(
                          padding: EdgeInsets.only(left: 20),
                          width: 200,
                          child: new Text(
                              attempted.toString(),
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        ),
                        new Container(
                          padding: EdgeInsets.only(left: 20),
                          width: 200,
                          child: new Text(
                              correct.toString(),
                              textAlign: TextAlign.left,
                              style: new TextStyle(
                                fontSize: 20,
                              )
                          ),
                        ),
                        new Container(
                          padding: EdgeInsets.only(left: 20),
                          width: 200,
                          child: new Text(
                            score.toStringAsFixed(2).toString() + '%',
                            textAlign: TextAlign.left,
                            style: new TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
          )
      ),
    );
  } // end build
} // end QuizResults

// Class: QuizScreenFinishedReturn
// Description: Displays the two buttons, providing the user with the options
//              to either close the quiz or retry the quiz.
class QuizScreenFinishedReturn extends StatelessWidget {
  // Constructor
  QuizScreenFinishedReturn({
    Key key,
    this.closeQuiz,
    this.retryQuiz
  }) : super(key: key);

  final QuizScreenReturnCallback closeQuiz;
  final QuizScreenReturnCallback retryQuiz;

  // Function: build
  Widget build(BuildContext context) {
    return new Container(
        margin: EdgeInsets.only(top: 20),
        width: 700,
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                margin: EdgeInsets.only(right: 20),
                child: new OutlinedButton(
                  onPressed: () => closeQuiz(context),
                  style: OutlinedButton.styleFrom(
                    primary: Colors.blue,
                    backgroundColor: Colors.white,
                    fixedSize: new Size(80, 40),
                  ),
                  child: new Text('Finish'),
                ),
              ),
              new Container(
                  child: new OutlinedButton(
                    onPressed: () => retryQuiz(context),
                    style: OutlinedButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.blue,
                      fixedSize: new Size(80, 40),
                    ),
                    child: new Text('Retry'),
                  )
              ),
            ]
        )
    );
  } // end build
} // end QuizScreenFinishedReturn

// Class: AnswerSet
// Description: This will display the answers of a question, each assigned a
//              a button the user can select.
class AnswerSet extends StatelessWidget {
  // Constructor
  AnswerSet({
    Key key,
    this.question,
    this.answers,
    this.aStates,
    this.onChange
  }) : super(key: key);

  final int question;
  final List<Map<String, dynamic>> answers;
  final List<bool> aStates;
  final QuizQuestionSelectCallback onChange;
  int count = 64;

  // Function: build
  @override
  Widget build(BuildContext context) {
    return new Container(
      //color: Colors.green,
      margin: EdgeInsets.only(top: 10),
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for(int i = 0; i < answers.length; i++)
              new AnswerSetRow(
                  question: question,
                  number: ++count,
                  answer: answers[i]['value'],
                  state: aStates[i],
                  onChange: onChange
              ),
          ]
      ),
    );
  } // end build
} // end AnswerSet

// Class: AnswerSetRow
// Description: Display an answer to a question with a corresponding button
//              used to select that answer.
class AnswerSetRow extends StatelessWidget {
  // Constructor
  AnswerSetRow({
    Key key,
    this.question,
    this.number,
    this.answer,
    this.state,
    this.onChange
  }) : super(key: key);

  final int question;
  final int number;
  final String answer;
  final bool state;
  final QuizQuestionSelectCallback onChange;

  // Function: getButtonStyle
  // Description: Returns the style of the button. If the button has been
  //              selected, it will have a selected style, otherwise
  //              the style will be the default.
  ButtonStyle getButtonStyle() {
    // If this button has been selected
    if(state) {
      return OutlinedButton.styleFrom(
        fixedSize: new Size(40.0, 40.0),
        primary: Colors.white,
        backgroundColor: Colors.teal,
        shape: const CircleBorder(),
      );
    // If this button has not been selected
    } else {
      return OutlinedButton.styleFrom(
        fixedSize: new Size(40.0, 40.0),
        primary: Colors.teal,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
      );
    }
  } // end getButtonStyle

  // Function: build
  @override
  Widget build(BuildContext context) {
    return new Row(
        children: <Widget>[
          new OutlinedButton(
            style: getButtonStyle(),
            onPressed: () => onChange(question, number),
            child: new Text(
                String.fromCharCode(number),
                style: new TextStyle(
                  fontSize: 18,
                )
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 40),
            child: Text(
              answer,
              style: new TextStyle(
                fontSize: 18,
              ),
            ),
          )
        ]
    );
  } // end build
} // end AnswerSetRow

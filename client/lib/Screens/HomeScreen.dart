
// ----- HomeScreen -----
// Description: Displays the home screen title and all quizzes currently
//              available. The quizzes are displayed with two placed in a row,
//              moving down the page.
// Libraries: The HomeScreen implements the QuizDisplay widget, used to display
//            the list of quizzes with two per row.

import 'package:flutter/material.dart';

import '../Components/QuizDisplay.dart';

// Class: HomeScreen
// Description: Displays the home screen of the application. This includes
// the title and available quizzes.
class HomeScreen extends StatelessWidget {
  // Constructor
  HomeScreen({Key key, this.quizzes}) : super(key: key);

  List<Map<String, dynamic>> quizzes = [];  // List of quizzes.

  // Function: build
  // Description: Displays the menu bar, home page title and the available
  // quizzes on the application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.indigoAccent,
        title: new Text('Quiz Topics'),
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            new HomeScreenTitle(),
            new QuizDisplay(quizzes: quizzes),
          ]
        ),
      ),
    );
  } // end build
} // end HomeScreen

// Class: HomeScreenTitle
// Description: This displays the title on the home screen.
class HomeScreenTitle extends StatelessWidget {
  // Constructor
  HomeScreenTitle({Key key}) : super(key : key);

  // Function: _getHeight
  // Description: Returns the desired height for the title area, depending
  //              on the context screen size.
  double _getHeight(BuildContext context) {
    // If the screen height is less than 400.
    if(MediaQuery.of(context).size.height < 400) {
      return 100.0;
    // If the screen height is greater than 400.
    } else {
      return ((MediaQuery.of(context).size.height) / 4);
    }
  } // end getHeight

  // Function: build
  // Description: Returns a container with title of the home screen page.
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: (MediaQuery.of(context).size.width),
      height: _getHeight(context),
      child: new Center(
        child: new Text(
          'Available Quizzes',
          style: TextStyle(
            fontSize: 60.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  } // end build
} // end HomeScreenTitle
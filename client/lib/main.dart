// @dart=2.9

// ----- main -----
// Description: Initiates the application, calling MyApp class. This class
//              requests all available quizzes from the backend and displays
//              them. Application automatically displays the home page, making
//              it the root of the stack.
// Libraries: The MyApp class uses the dio package to make the API requests.
//            The dart convert library is used to convert JSON content to List
//            and Map objects.
//            The HomeScreen widget is implemented as the main screen loaded
//            when the app is loaded.

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'Screens/HomeScreen.dart';

// Main function
void main() => runApp(MyApp());

// Class: MyApp
// Description: This class loads in all quizzes from the backend and
//              passes them in a list object to the HomeScreen.
class MyApp extends StatelessWidget {
  // Server base URL
  final String baseURL = 'http://localhost:8085';

  // Function: _getQuizzes
  // Description: Retrieves the quizzes from the backend.
  Future<List<Map<String,dynamic>>> _getQuizzes() async {
    final Dio dio = new Dio();   // Init Dio object.
    try {
      // Retrieve quizzes from backend.
      var response = await dio.get("$baseURL/quizTitles")
          .then((response) {
        return response;        // Return data from Future object.
      })
          .catchError((error) {
        print(error);           // Catch any errors.
      });
      // Decode json content into a List object with dynamic data.
      List<dynamic> vals = json.decode(response.toString());
      List<Map<String, dynamic>> res = [];
      // Cast all values in the list from dynamic to Map<String, dynamic>.
      for(var value in vals) {
        Map<String, dynamic> convertedValue = value;
        res.add(convertedValue);
      }
      // Return the quizzes.
      return Future.value(res);
    } on DioError catch (e) {
      print(e);
    }
    return Future.value([]);
  } // end _getQuizzes

  // Function: build
  // Description: Returns MaterialApp widget with a FutureBuilder in the
  //              body. The FutureBuilder will return HomeScreen if the
  //              quizzes have been retrieved from the backend. Otherwise,
  //              return CircularProgressIndicator
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'test',
      home: new Container(
          child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getQuizzes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // If quizzes have been returned.
            if(snapshot.hasData) {
              return HomeScreen(quizzes: snapshot.data);
            // If quizzes have not been retrieved yet.
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  } // end build
} // end MyApp
// --- Main File -----
// Description: This main file represents a server with API routes, used to
//              source quiz data. Data is sourced from a MongoDB database
//              on the cloud (the link to this database has been removed)
// Libraries: This server implements the HTTP Server library from the dart io
//            library. Conversions are made from List and Map objects to JSON
//            data with the dart convert library. Queries are sent to the
//            MongoDB database with the mongo_dart package. 

import 'dart:io';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

main() async {
  // Server port number
  int port = 8085;    
  // Database URL
  String database = '...';
  
  var server = await HttpServer.bind('localhost', port);    // Initiate server.
  // Create and open database connection.
  Db db = await Db.create(database);
  await db.open();
  print('Connected to database');     // Display database connection success.
  
  // Retrieve data collections from DB.
  DbCollection quizzes = db.collection('quizzes');
  DbCollection questions = db.collection('questions');
  DbCollection answers = db.collection('answers');

  // If quizzes is empty, add data to the database.
  if(await quizzes.find().isEmpty) {
    // Add algebra quiz.
    await quizzes.insert({'quizID': 1, 'title': 'Algebra', 'description': 'A nice revision quiz'});
    await questions.insert({'quizID': 1, 'questionID': 100, 'question': 'Solve the following: 2x - 3 = 15'});
    await answers.insert({'questionID': 100, 'value': 'x = 6', 'isCorrect': false});
    await answers.insert({'questionID': 100, 'value': 'x = 9', 'isCorrect': true});
    await answers.insert({'questionID': 100, 'value': 'x = 8', 'isCorrect': false});
    await answers.insert({'questionID': 100, 'value': 'x = 2', 'isCorrect': false});
    await questions.insert({'quizID': 1, 'questionID': 101, 'question': 'Solve the following: 10 + x = 14'});
    await answers.insert({'questionID': 101, 'value': 'x = 24', 'isCorrect': false});
    await answers.insert({'questionID': 101, 'value': 'x = 14', 'isCorrect': false});
    await answers.insert({'questionID': 101, 'value': 'x = 4', 'isCorrect': true});
    await answers.insert({'questionID': 101, 'value': 'x = -14', 'isCorrect': false});
    await questions.insert({'quizID': 1, 'questionID': 102, 'question': 'Solve the following: 2x - 4 = 22'});
    await answers.insert({'questionID': 102, 'value': 'x = 13', 'isCorrect': true});
    await answers.insert({'questionID': 102, 'value': 'x = 9', 'isCorrect': false});
    await answers.insert({'questionID': 102, 'value': 'x = 12', 'isCorrect': false});
    await answers.insert({'questionID': 102, 'value': 'x = 8', 'isCorrect': false});
    await questions.insert({'quizID': 1, 'questionID': 103, 'question': 'Solve the following: 7 + 2x = 29'});
    await answers.insert({'questionID': 103, 'value': 'x = 11', 'isCorrect': true});
    await answers.insert({'questionID': 103, 'value': 'x = 10', 'isCorrect': false});
    await answers.insert({'questionID': 103, 'value': 'x = 18', 'isCorrect': false});
    await answers.insert({'questionID': 103, 'value': 'x = 12', 'isCorrect': false});
    await questions.insert({'quizID': 1, 'questionID': 104, 'question': 'Solve the following: 3x + 5 = 23'});
    await answers.insert({'questionID': 104, 'value': 'x = 7', 'isCorrect': false});
    await answers.insert({'questionID': 104, 'value': 'x = 10', 'isCorrect': false});
    await answers.insert({'questionID': 104, 'value': 'x = 9', 'isCorrect': false});
    await answers.insert({'questionID': 104, 'value': 'x = 6', 'isCorrect': true});
    // Add derivatives quiz.
    await quizzes.insert({'quizID': 2, 'title': 'Derivatives 1', 'description': 'A challenging test'});
    await questions.insert({'quizID': 2, 'questionID': 200, 'question': 'Solve the following: d/dx(2x + 1)'});
    await answers.insert({'questionID': 200, 'value': '2', 'isCorrect': true});
    await answers.insert({'questionID': 200, 'value': '3', 'isCorrect': false});
    await answers.insert({'questionID': 200, 'value': '2x', 'isCorrect': false});
    await questions.insert({'quizID': 2, 'questionID': 201, 'question': 'Solve the following: d/dx(4x^2 - 3x)'});
    await answers.insert({'questionID': 201, 'value': '8x - 3', 'isCorrect': true});
    await answers.insert({'questionID': 201, 'value': '4x - 3', 'isCorrect': false});
    await answers.insert({'questionID': 201, 'value': '7', 'isCorrect': false});
    await answers.insert({'questionID': 201, 'value': '8x', 'isCorrect': false});
    await questions.insert({'quizID': 2, 'questionID': 202, 'question': 'Solve the following: d/dx(3x^2 + 8x + 15)'});
    await answers.insert({'questionID': 202, 'value': '6x + 8', 'isCorrect': true});
    await answers.insert({'questionID': 202, 'value': '6x + 15', 'isCorrect': false});
    await answers.insert({'questionID': 202, 'value': '6x - 8', 'isCorrect': false});
    await answers.insert({'questionID': 202, 'value': '6x', 'isCorrect': false});
  }

  // Create route listeners for REST API architecture
  server.listen((HttpRequest request) async {
    //Set access properties
    request.response.headers.add("Access-Control-Allow-Origin", "*");
    request.response.headers.add("Access-Control-Allow-Headers", "*");
    request.response.headers.add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");

    switch (request.uri.path) {
      case '/quizTitles':
        List<dynamic> response = [];
        // Retrieve all quizzes from the database.
        var res = await quizzes.find().toList();
        // For each quiz, remove the database _id value and add to a dynamic list.
        for(var m in res) {
          m.remove('_id');
          response.add(json.encode(m));
        }
        // send response.
        request.response
          ..write(response)
          ..close();
        break;

      case '/quizQuestions':
        List<dynamic> response = [];
        var quizID = request.uri.queryParameters['quiz'];
        String reqID = '';
        // If a quiz Id was sent with the request.
        if(quizID != null)
          reqID = quizID;
        // Retrieve the questions from the specified quiz.
        var resQ = await questions.find(where.eq('quizID', int.parse(reqID))).toList();
        // For each question, remove the database _id and add to dynamic list.
        for(var m in resQ) {
          m.remove('_id');
          response.add(json.encode(m));
        }
        // Send response.
        request.response
          ..write(response)
          ..close();
        break;

      case '/quizAnswers':
        List<List<dynamic>> response = [];
        var quizID = request.uri.queryParameters['quiz'];
        String reqID = '';
        // If a quiz Id was sent with the request.
        if(quizID != null)
          reqID = quizID;
        // Retrieve all questions of the specified quiz.
        var resQ = await questions.find(where.eq('quizID', int.parse(reqID))).toList();
        // For each question in the quiz
        for(var q in resQ) {
          List<dynamic> as = [];
          int qID = q['questionID'];
          // Retrieve all answers associated with this question
          var resA = await answers.find(where.eq('questionID', qID)).toList();
          // For each answer, remove the _id and add to list.
          for(var a in resA) {
            a.remove('_id');
            as.add(json.encode(a));
          }
          // Add list of answers to list.
          response.add(as);
        }
        // Send response.
        request.response
          ..write(response)
          ..close();
        break;

      default:
        // Send error response.
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Error: Unknown route requested')
          ..close();
    }
  });
  // Print server port.
  print('Server listening at http://localhost:$port');
} // end main

// Class: Question
// Description: Consists of a question Map and a list of Answer Maps.
//              A question Map will have the following keys:
//                - quizID
//                - questionID
//                - question
//              An answer Map will have the following keys:
//                - questionID
//                - value
//                - isCorrect
class Question {
  // Constructor
  Question({this.question, this.answers});

  // Function: getQuestion
  // Description: Returns the question from the question map
  String getQuestion() {
    return question['question'];
  } // end getQuestion

  final Map<String, dynamic> question;
  final List<Map<String, dynamic>> answers;
} // end Question
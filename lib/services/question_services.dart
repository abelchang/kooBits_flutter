import 'package:koobits_flutter/models/answer.dart';
import 'package:koobits_flutter/models/answer_result.dart';
import 'package:koobits_flutter/models/question.dart';
import 'package:koobits_flutter/network_utils/api.dart';

class QuestionServices {
  Future<Map<String, dynamic>> getQuestions([int count = 10]) async {
    Map<String, dynamic> result;
    var response = await Network().getData("/getQuestions/$count");
    if (response == null) {
      result = {
        'success': false,
        'message': 'network issue',
      };
    } else if (response['success'] == true) {
      List<Question> questions = (response['questions'] as List)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
      result = {
        'success': true,
        'questions': questions,
      };
    } else {
      result = {
        'success': false,
        'message': response['message'],
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> submitQuestions(
      List<AnswerResult> answerResults) async {
    Map<String, dynamic> result;
    final Map<String, dynamic> answerResultsData = {
      'answerResults': answerResults,
    };
    var response =
        await Network().postData(answerResultsData, '/submitQuestions');
    if (response == null) {
      result = {
        'success': false,
        'message': 'network issue',
      };
    } else if (response['success'] == true) {
      List<Answer> answers = (response['answers'] as List)
          .map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList();
      result = {
        'success': true,
        'answers': answers,
      };
    } else {
      result = {
        'success': false,
        'message': response['message'],
      };
    }
    return result;
  }
}

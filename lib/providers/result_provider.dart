import 'package:flutter/foundation.dart';
import 'package:koobits_flutter/models/answer_result.dart';
import 'package:koobits_flutter/models/question.dart';

class ResultProvider with ChangeNotifier {
  List<AnswerResult> _results = [];
  List<AnswerResult> get results => _results;

  void initAnswwerResults(List<Question> questions) {
    _results.clear();
    for (var question in questions) {
      _results.add(AnswerResult(id: question.id, result: -1));
    }
  }

  void setAnswwerResults(List<AnswerResult> results) {
    _results = results;
    notifyListeners();
  }

  void setSingleAnswerResult(AnswerResult result) {
    _results.any((item) => item.id == result.id)
        ? _results[_results.indexWhere((element) => element.id == result.id)] =
            result
        : _results.add(result);
  }

  String getSingleResult(int qId) {
    int index = _results.indexWhere((element) => element.id == qId);
    if (index > 0) {
      return _results[index].result != -1
          ? _results[index].result.toString()
          : '';
    } else {
      return '';
    }
  }
}

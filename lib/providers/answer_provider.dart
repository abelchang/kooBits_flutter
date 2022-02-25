import 'package:flutter/foundation.dart';
import 'package:koobits_flutter/models/answer.dart';

class AnswerProvider with ChangeNotifier {
  List<Answer> _answers = [];
  List<Answer> get answers => _answers;

  void setAnswers(List<Answer> answers) {
    _answers = answers;
    notifyListeners();
  }
}

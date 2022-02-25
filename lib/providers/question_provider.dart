import 'package:flutter/foundation.dart';

import 'package:koobits_flutter/models/question.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> get questions => _questions;

  void initQuestions(List<Question> questions) {
    _questions = questions;
  }
}

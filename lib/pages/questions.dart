import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:koobits_flutter/models/answer.dart';
import 'package:koobits_flutter/models/answer_result.dart';
import 'package:koobits_flutter/models/question.dart';
import 'package:koobits_flutter/services/question_services.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({Key? key, required this.questions}) : super(key: key);

  final List<Question> questions;

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  List<Question> questions = [];
  List<AnswerResult> answerResult = [];
  List<Answer> answers = [];
  List<TextEditingController> questionControllers = [];
  final formKey = GlobalKey<FormState>();
  int currentQuestion = 0;
  bool isSubmitted = false;
  SubmitResult submitResult = SubmitResult();
  late FocusNode questionNode;

  @override
  void initState() {
    super.initState();
    questionNode = FocusNode();
    questions = widget.questions;
    for (var i = 0; i < questions.length; i++) {
      questionControllers.add(TextEditingController());
      answerResult.add(AnswerResult(
          id: questions[i].id,
          result: -1,
          difficulty: questions[i].difficulty));
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < questionControllers.length; i++) {
      questionControllers[i].dispose();
    }
    questionNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocus,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
              child: SizedBox(
            height: MediaQuery.of(context).size.height * .9,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 32,
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  showQuestion(currentQuestion),
                  const Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  resetQuestions() {
    for (var qController in questionControllers) {
      qController.text = '';
    }
    for (var result in answerResult) {
      result.result = -1;
    }
    submitResult = SubmitResult();
    if (mounted) {
      setState(() {
        isSubmitted = false;
        currentQuestion = 0;
      });
    }
  }

  submitQuestions() async {
    for (var result in answerResult) {
      if (result.result == -1) {
        changeQuestion(answerResult.indexOf(result));
        EasyLoading.showInfo('還有題目沒完成喔！',
            duration: const Duration(seconds: 2), dismissOnTap: true);
        return;
      }
    }
    if (formKey.currentState!.validate()) {
      Map<String, dynamic> res =
          await QuestionServices().submitQuestions(answerResult);
      if (res['success']) {
        answers = res['answers'];
        submitResult = statisticsResult();
      }
      if (mounted) {
        setState(() {
          isSubmitted = true;
        });
      }
      showResultDialog(submitResult);
    }
  }

  changeQuestion(int targetQuestion) {
    if (formKey.currentState == null) {
      debugPrint("formKey.currentState is null!");
    } else if (formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          currentQuestion = targetQuestion;
        });
      }
      if (Platform.isAndroid) {
        unfocus();
      }
    }
  }

  showButton() {
    if (currentQuestion == 0) {
      return ElevatedButton(
          onPressed: () => changeQuestion(currentQuestion + 1),
          child: const Text('下一題'));
    } else if (currentQuestion == questions.length - 1) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () => changeQuestion(currentQuestion - 1),
              child: const Text('上一題')),
          isSubmitted
              ? ElevatedButton(
                  onPressed: () => resetQuestions(), child: const Text('重新作答'))
              : ElevatedButton(
                  onPressed: () => submitQuestions(), child: const Text('提交')),
          isSubmitted
              ? ElevatedButton(
                  onPressed: () => showResultDialog(submitResult),
                  child: const Text('查看結果'))
              : const SizedBox.shrink(),
        ],
      );
    } else {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () => changeQuestion(currentQuestion - 1),
              child: const Text('上一題')),
          ElevatedButton(
              onPressed: () => changeQuestion(currentQuestion + 1),
              child: const Text('下一題')),
        ],
      );
    }
  }

  showQuestion(int questionIndex) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Column(
            children: [
              const Text(
                '加法',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text(
                '兩個自然數相加將他們組合起來的總量運算',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              RichText(
                text: TextSpan(
                  text: '第 ',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${questionIndex + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' 題',
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    showDifficulty(questions[currentQuestion].difficulty!),
                    Text(
                      '題目序號:${questions[currentQuestion].id}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Spacer(
                          flex: 1,
                        ),
                        Text(
                          questions[questionIndex].question!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              scrollPadding: const EdgeInsets.only(bottom: 30),
                              focusNode: questionNode,
                              keyboardType: TextInputType.number,
                              controller: questionControllers[currentQuestion],
                              enabled: !isSubmitted,
                              textAlign: TextAlign.center,
                              onTap: () => questionControllers[currentQuestion]
                                      .selection =
                                  TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          questionControllers[currentQuestion]
                                              .value
                                              .text
                                              .length),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'^0+')),
                              ],
                              decoration: const InputDecoration(
                                helperText: ' ',
                              ),
                              onChanged: (value) {
                                int index = answerResult.indexWhere((element) =>
                                    element.id == questions[questionIndex].id);
                                answerResult[index].result = int.parse(value);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '不能留空喔';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                      ],
                    ),
                    showResult(currentQuestion),
                    const SizedBox(
                      height: 16,
                    ),
                    showButton(),
                    const SizedBox(
                      height: 32,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              showProgress(),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  showResult(int currentQuestion) {
    int qId = questions[currentQuestion].id!;

    if (isSubmitted && answers.isNotEmpty) {
      Answer answer = answers.firstWhere((element) => element.id == qId);
      AnswerResult result =
          answerResult.firstWhere((element) => element.id == qId);
      bool isCorrect = answer.answer == result.result;
      if (isCorrect) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.done,
              color: Colors.green,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              '正確答案!',
              style: TextStyle(color: Colors.green),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.close,
              color: Colors.red,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '糟糕，錯了！ 答案是：${answer.answer}。',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  showDifficulty(int difficulty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('難度：'),
        for (var i = 0; i < difficulty; i++)
          Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
          ),
        for (var i = 0; i < 5 - difficulty; i++)
          Icon(
            Icons.star,
            color: Colors.grey[400],
          ),
      ],
    );
  }

  showProgress() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...answerResult.map((e) {
          var index = answerResult.indexOf(e);
          return GestureDetector(
            onTap: () => changeQuestion(index),
            child: CircleAvatar(
              radius: 14,
              foregroundColor: Colors.white,
              backgroundColor: progressColor(e),
              child: Text('${index + 1}'),
            ),
          );
        })
      ],
    );
  }

  progressColor(AnswerResult result) {
    if (isSubmitted) {
      if (result.result ==
          answers[answers.indexWhere((element) => element.id == result.id)]
              .answer) {
        return Colors.green;
      } else {
        return Colors.red[300];
      }
    } else {
      if (result.result! > 0) {
        return Theme.of(context).colorScheme.primary;
      } else {
        return Colors.grey;
      }
    }
  }

  SubmitResult statisticsResult() {
    SubmitResult submitResult = SubmitResult();
    for (var result in answerResult) {
      int index = submitResult.diffcultyCount
          .indexWhere((element) => element.difficulty == result.difficulty);
      if (result.result ==
          answers[answers.indexWhere((element) => element.id == result.id)]
              .answer) {
        submitResult.correctQuestions += 1;
        submitResult.diffcultyCount[index].correct += 1;
      } else {
        submitResult.wrongAnswer += 1;
        submitResult.diffcultyCount[index].wrong += 1;
      }
      submitResult.total += 1;
    }
    submitResult.diffcultyCount
        .sort((a, b) => a.difficulty.compareTo(b.difficulty));
    return submitResult;
  }

  void showResultDialog(SubmitResult submitResult) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
            title: Image.asset(
              'assets/logo.png',
              height: 32,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '測驗成果',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '題目共',
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${submitResult.total}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '題',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: '答對',
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${submitResult.correctQuestions}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '題',
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: '答錯',
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${submitResult.wrongAnswer}',
                              style: TextStyle(
                                color: Colors.red[300],
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '題',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  ...submitResult.diffcultyCount.map(
                    (e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        showDifficulty(e.difficulty),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                        Text(
                          e.correct.toString(),
                          style: const TextStyle(color: Colors.green),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        const Text(
                          ' : ',
                          style: TextStyle(fontWeight: FontWeight.w200),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Icon(
                          Icons.close,
                          color: Colors.red[300],
                        ),
                        Text(
                          e.wrong.toString(),
                          style: TextStyle(color: Colors.red[300]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class SubmitResult {
  int total;
  int correctQuestions;
  int wrongAnswer;
  List<DifficultyCount> diffcultyCount = List<DifficultyCount>.generate(
      5, (int index) => DifficultyCount(difficulty: index + 1));
  SubmitResult({
    this.total = 0,
    this.correctQuestions = 0,
    this.wrongAnswer = 0,
  });
}

class DifficultyCount {
  int difficulty;
  int total;
  int correct;
  int wrong;
  DifficultyCount({
    this.difficulty = 0,
    this.total = 0,
    this.correct = 0,
    this.wrong = 0,
  });
}

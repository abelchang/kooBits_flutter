import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:koobits_flutter/pages/error.dart';
import 'package:koobits_flutter/pages/questions.dart';
import 'package:koobits_flutter/pages/wait.dart';
import 'package:koobits_flutter/providers/answer_provider.dart';
import 'package:koobits_flutter/providers/question_provider.dart';
import 'package:koobits_flutter/providers/result_provider.dart';
import 'package:koobits_flutter/services/question_services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => AnswerProvider()),
        ChangeNotifierProvider(create: (_) => ResultProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  final spinkit = const SpinKitChasingDots(
    // color: Color(0xFF1C1C1E),
    color: Colors.white,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KooBits Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 239, 130, 67),
        ),
      ),
      builder: EasyLoading.init(),
      home: FutureBuilder(
        future: QuestionServices().getQuestions(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const WaitPage();
            default:
              if (snapshot.hasData) {
                context
                    .read<QuestionProvider>()
                    .initQuestions((snapshot.data! as Map)['questions']);
                context
                    .read<ResultProvider>()
                    .initAnswwerResults((snapshot.data! as Map)['questions']);
                return QuestionsPage(
                  questions: (snapshot.data! as Map)['questions'],
                );
              } else {
                return const ErrorPage();
              }
          }
        },
      ),
    );
  }
}

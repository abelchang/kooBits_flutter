import 'package:json_annotation/json_annotation.dart';
part 'answer_result.g.dart';

@JsonSerializable()
class AnswerResult {
  AnswerResult({this.id, this.result, this.difficulty});
  int? id;
  int? result;
  int? difficulty;

  factory AnswerResult.fromJson(Map<String, dynamic> json) =>
      _$AnswerResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerResultToJson(this);
}

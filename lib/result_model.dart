class ResultModel {
  final String? resultStatus;
  final String? result;
  final String? memo;
  final String? type;

  const ResultModel({
    this.resultStatus,
    this.result,
    this.memo,
    this.type,
  });

  factory ResultModel.fromJson(Map<dynamic, dynamic> json) {
    return ResultModel(
      resultStatus: json['resultStatus'],
      result: json['result'],
      memo: json['memo'],
      type: json['type'],
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'resultStatus': resultStatus,
      'result': result,
      'memo': memo,
      'type': type,
    };
  }
}

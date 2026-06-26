// 历史记录数据模型：单条识别结果的结构化表示与 JSON 序列化。
class HistoryRecord {
  HistoryRecord({
    required this.id,
    required this.createdAt,
    required this.languageName,
    required this.languageFlag,
    required this.text,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      languageName: json['languageName'] as String,
      languageFlag: json['languageFlag'] as String,
      text: json['text'] as String,
    );
  }

  final String id;
  final DateTime createdAt;
  final String languageName;
  final String languageFlag;
  final String text;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'languageName': languageName,
        'languageFlag': languageFlag,
        'text': text,
      };
}

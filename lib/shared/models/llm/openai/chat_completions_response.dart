/// 聊天响应模型
class ChatCompletionsResponse {
  /// 构造函数
  ChatCompletionsResponse({
    this.id,
    this.object,
    this.created,
    required this.choices,
  });

  /// ID字符串，例如："chatcmpl-123"
  final String? id;

  /// 对象字符串，例如："chat.completion"
  final String? object;

  /// 创建时间戳
  final int? created;

  /// 选择列表
  final List<ChoiceModel> choices;

  factory ChatCompletionsResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionsResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      choices: List<ChoiceModel>.from(
          json['choices'].map((x) => ChoiceModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'choices': List<dynamic>.from(choices.map((x) => x.toJson())),
    };
  }
}

/// 选择模型
class ChoiceModel {
  /// 构造函数
  ChoiceModel({
    this.index,
    this.finishReason,
    required this.delta,
  });

  /// 索引号，例如：0
  final int? index;

  /// 完成原因字符串，例如："stop"
  final String? finishReason;

  /// 消息模型
  final Delta delta;

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      index: json['index'],
      finishReason: json['finish_reason'],
      delta: Delta.fromJson(json['delta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'delta': delta.toJson(),
      'finish_reason': finishReason,
    };
  }
}

/// 消息块
class Delta {
  /// 构造函数
  Delta({this.content});

  /// 内容字符串
  final String? content;

  factory Delta.fromJson(Map<String, dynamic> json) {
    return Delta(
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

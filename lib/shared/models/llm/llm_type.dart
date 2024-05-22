enum LLMType {
  openai('openai'), // OpenAI API（兼容该协议的http服务）
  aliyunQwen('aliyun_qwen'); // 阿里云-DashScope-通义千问

  final String value;

  const LLMType(this.value);

  /// 类型描述
  String get description => llmDescription[this] ?? '';

  /// 类型文档url
  String get docUrl => llmDocUrl[this] ?? '';
}

/// 类型描述
const Map<LLMType, String> llmDescription = {
  LLMType.openai: 'OpenAI API（文本补全）',
  LLMType.aliyunQwen: '阿里云-DashScope-通义千问',
};

/// 类型文档url
const Map<LLMType, String> llmDocUrl = {
  LLMType.openai: 'https://openai.apifox.cn/api-55352401',
  LLMType.aliyunQwen:
      'https://help.aliyun.com/zh/dashscope/developer-reference/model-introduction',
};

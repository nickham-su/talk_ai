enum LLMType {
  openai('openai'), // OpenAI API（兼容该协议的http服务）
  aliyunQwen('aliyun_qwen'); // 阿里云-DashScope-通义千问

  final String value;

  const LLMType(this.value);

  /// 类型描述
  String get description {
    switch (this) {
      case LLMType.openai:
        return 'OpenAI API（兼容该协议的http服务）';
      case LLMType.aliyunQwen:
        return '阿里云-DashScope-通义千问';
      default:
        return '';
    }
  }
}

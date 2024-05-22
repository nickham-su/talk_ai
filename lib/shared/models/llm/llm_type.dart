/// 大语言模型类型
enum LLMType {
  openai('openai'), // OpenAI API
  dash_scope('dash_scope'), // 阿里云-DashScope
  qianfan('qianfan'); // 百度云-千帆

  final String value;

  const LLMType(this.value);

  /// 类型描述
  ModelInfo get info => modelInfoMap[this]!;
}

/// 类型描述
const Map<LLMType, ModelInfo> modelInfoMap = {
  LLMType.openai: ModelInfo(description: 'OpenAI API（文本生成）', docList: [
    Doc(
      title: 'API文档',
      url: 'https://openai.apifox.cn/api-55352401',
    )
  ]),
  LLMType.dash_scope: ModelInfo(description: '阿里云-DashScope', docList: [
    Doc(
      title: '通义千问',
      url:
          'https://help.aliyun.com/zh/dashscope/developer-reference/model-introduction',
    ),
    Doc(
      title: '通义千问-开源',
      url:
          'https://help.aliyun.com/zh/dashscope/developer-reference/tongyi-qianwen-7b-14b-72b-api-detailes',
    ),
    Doc(
      title: '更多模型',
      url: 'https://dashscope.console.aliyun.com/model',
    ),
  ]),
  LLMType.qianfan: ModelInfo(description: '百度云-千帆', docList: [
    Doc(
      title: '平台说明',
      url: 'https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html',
    ),
    Doc(
      title: '模型及费用',
      url: 'https://cloud.baidu.com/doc/WENXINWORKSHOP/s/hlrk4akp7',
    ),
    Doc(
      title: '获取access_token',
      url: 'https://cloud.baidu.com/doc/WENXINWORKSHOP/s/Dlkm79mnx',
    ),
  ]),
};

/// 模型信息
class ModelInfo {
  final String description; // 模型描述
  final List<Doc> docList; // 文档列表

  const ModelInfo({required this.description, required this.docList});
}

/// 文档
class Doc {
  final String title;
  final String url;

  const Doc({required this.title, required this.url});
}

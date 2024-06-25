# TalkAI

## 简介

TalkAI 是一款功能强大的桌面端客户端，专为与大语言模型进行对话而设计。作为一个经常使用各种 AI 对话工具的用户，我发现现有的应用无法完全满足我的需求，因此决定开发这款高效的 AI 对话工具。

### 适合人群

- 高频使用大语言模型的专业人士，特别是程序员、文字创作者，可显著提升工作效率。
- 需要频繁切换模型，对比多个模型生成结果的用户。
- 希望保存和管理常用提示词，以处理不同任务的用户。
- 需要在多台设备间同步数据的用户。
- 追求高性价比的用户：相比各平台的会员制，使用API服务，以token用量计费可节省80-90%费用，且没有使用频率限制。
- 本地部署大语言模型的用户，搭配llama.cpp、ollama、LocalAI、vLLM等兼容OpenAI API的本地模型服务使用。

### 不适合人群

- 寻求开箱即用解决方案的用户：TalkAI 需要用户自行注册和配置大语言模型的 API 服务。
- 对模型回答质量要求不高的用户：许多免费AI工具可能已经足够。
- 不熟悉提示词编写技巧的用户：建议先学习相关知识以充分利用 TalkAI 的功能。

## 特性

- **多协议支持**：兼容 OpenAI API、阿里云 DashScope、百度云千帆、Coze扣子等多种协议。
- **跨平台兼容**：支持 Windows 和 MacOS 系统。
- **数据同步**：利用阿里云盘实现跨设备、跨平台的模型和助理（提示词）同步，数据存储在用户个人网盘空间。
- **隐私保护**：纯客户端应用，无后端服务，不上传用户数据。
- **用户友好界面**：简洁的交互设计，优质的使用体验。

## 快速开始

### 安装指南

1. 进入项目 Releases 页面，选择最新版本。

#### Windows 用户：
- 下载 `TalkAI-x.x.x-windows-setup.exe`
- 双击安装文件进行安装

#### MacOS 用户：
- 下载 `TalkAI-x.x.x-macos.zip`
- 解压后将应用移动到"应用程序"文件夹
- 首次启动可能需要在"系统设置"-"隐私与安全"中允许运行

### 从源码构建

- 安装 Flutter 开发环境（SDK 版本要求：3.x+）
- 克隆本仓库
- 运行或编译项目

### 添加模型

以兼容 OpenAI API 的"零一万物"为例：

1. 访问[零一万物官网](https://platform.lingyiwanwu.com/)注册账号(目前有赠送免费额度)
2. 在"工作台"创建 API Key
3. 在 TalkAI 的"模型"页面，点击左上角"+"，选择"OpenAI API"并点击"添加"
4. 填写参数：
    - 自定义名称：`yi-large`
    - URL：`https://api.lingyiwanwu.com`
    - API Key：刚创建的 API Key
    - 模型名称：`yi-large`
5. 点击"保存"

零一万物，还提供其他型号的模型，请参考官网文档。
OpenAI官方API服务、和其他兼容OpenAI API协议的服务，也可以按照类似的步骤添加。

### 添加助理

创建通用对话助理：

1. 在"助理"页面，点击左上角"+"
2. 助理名称填写：通用助理
3. 点击"添加"
4. 开始对话

如需设置特定任务的预设提示词，可在添加助理时进行配置。

### 其他功能

- **切换模型**：通过输入框上方按钮快速切换，或使用回答结尾的圆环箭头重新生成。
- **会话管理**：使用工具栏"+"开启新会话，避免上下文干扰。上下箭头用于会话导航。
- **分享功能**：左上角分享按钮可将模型和助理设置转为代码分享。
- **数据同步**：需注册阿里云盘并授权 TalkAI 使用。

### 模型资源

- 国内很多AI平台兼容OpenAI API协议，例如：零一万物、DeepSeek，目前都有免费体验额度。
- 阿里云DashScope、百度云千帆，目前提供一个月的免费体验额度。
- Coze扣子国内版，目前API服务免费，可以使用豆包、通义千问等模型；海外版提供GPT-4、GPT-4o模型，但需付费。

## 联系方式

如有任何问题或建议，欢迎联系：

- GitHub: [nickham-su](https://github.com/nickham-su)
- 邮箱: 50793247@qq.com
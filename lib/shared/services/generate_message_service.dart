import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/chat/models/conversation_message_model.dart';
import '../../modules/chat/repositorys/message_repository.dart';
import '../models/message/message_status.dart';
import '../models/message/generated_message.dart';
import '../models/llm/llm_model.dart';
import '../models/message/message_model.dart';
import '../repositories/generated_message_repository.dart';
import 'llm_service.dart';

class Listener<T> {
  final int listenerId; // 监听Id
  final T handler; // 事件处理函数

  Listener(this.handler, this.listenerId);
}

class GenerateMessageService extends GetxService {
  /// 当前生成的消息Id
  int? currentGenerateId;

  /// 是否在生成中
  bool get isGenerating => currentGenerateId != null;

  /// 生成事件处理函数缓存, key为generateId
  final Map<int, List<void Function(String)>> _generateHandlerMap = {};

  /// 完成事件处理函数缓存, key为generateId
  final Map<int, List<void Function()>> _doneHandlerMap = {};

  /// 错误事件处理函数缓存, key为generateId
  final Map<int, List<void Function(dynamic)>> _errorHandlerMap = {};

  /// 用户取消事件处理函数缓存, key为generateId
  final Map<int, List<void Function()>> _cancelHandlerMap = {};

  /// 消息更新事件处理函数缓存, key为msgId
  final Map<int, List<Listener<void Function()>>> _updateMessageHandlerMap = {};

  /// 生成列表更新事件处理函数缓存
  final Map<int, List<Listener<void Function(List<GeneratedMessage>)>>>
      _updateGenerateListHandlerMap = {};

  /// 生成消息
  /// 返回generateId生成消息Id
  int generateMessage({
    int? generateId,
    required int llmId,
    required int chatAppId,
    required int msgId,
    required List<MessageModel> messages,
    ConversationMessageModel? sourceMessage,
    void Function(String)? onGenerate,
    void Function()? onDone,
    void Function(dynamic)? onError,
    void Function()? onCancel,
  }) {
    // 去重
    if (isGenerating) {
      throw '正在生成消息，请稍后再试！';
    }

    final llmService = Get.find<LLMService>();
    final LLM? llm = llmService.getLLM(llmId);
    if (llm == null) {
      throw '模型设置错误，请检查！';
    }

    if (generateId == null) {
      // 生成消息对象
      final generatedMessage = GeneratedMessageRepository.insert(
        msgId: msgId,
        chatAppId: chatAppId,
        llmId: llmId,
        llmName: llm.name,
        status: MessageStatus.unsent,
        content: '',
      );
      currentGenerateId = generatedMessage.generateId;
      generateId = generatedMessage.generateId;
    } else {
      GeneratedMessageRepository.update(
        generateId: generateId,
        status: MessageStatus.unsent,
        content: '',
        error: '',
      );
      currentGenerateId = generateId;
    }

    // 监听事件
    listenGenerate(
      generateId: generateId,
      onGenerate: onGenerate,
      onDone: onDone,
      onError: onError,
      onCancel: onCancel,
    );

    // 更新LLM使用时间
    llmService.updateLastUseTime(llmId);

    // 通知生成消息更新
    _handleUpdateGenerateList(msgId);

    // 生成消息
    String content = '';
    llm.chatCompletions(messages: messages).listen(
      (chunk) {
        content += chunk;
        if (!isGenerating) {
          return;
        }
        GeneratedMessageRepository.update(
          generateId: generateId!,
          status: MessageStatus.sending,
          content: content,
        );
        _handleGenerate(generateId, content);
      },
      onDone: () {
        if (isGenerating) {
          GeneratedMessageRepository.update(
            generateId: generateId!,
            status: MessageStatus.completed,
          );
          currentGenerateId = null;
          _handleDone(generateId);
        }
        // 移除事件处理函数
        _removeGenerateListen(generateId!);
      },
      onError: (e) {
        if (isGenerating) {
          GeneratedMessageRepository.update(
            generateId: generateId!,
            status: MessageStatus.failed,
            error: e.toString(),
          );
          currentGenerateId = null;
          _handleError(generateId, e);
        }
        // 移除事件处理函数
        _removeGenerateListen(generateId!);
      },
    );

    return generateId;
  }

  /// 停止生成消息
  void stopGenerate() {
    final generatedMessage = getCurrentGeneratedMessage();
    if (generatedMessage == null) {
      return;
    }
    currentGenerateId = null;
    GeneratedMessageRepository.update(
      generateId: generatedMessage.generateId,
      status: MessageStatus.cancel,
    );
    _handleCancel(generatedMessage.generateId);
    _removeGenerateListen(generatedMessage.generateId);
    final LLM? llm = Get.find<LLMService>().getLLM(generatedMessage.llmId);
    llm?.cancel();
  }

  /// 获取生成消息列表
  List<GeneratedMessage> getMessages(int msgId) {
    return GeneratedMessageRepository.getGeneratedMessageList(msgId);
  }

  /// 获取生成消息
  GeneratedMessage? getMessage(int generateId) {
    return GeneratedMessageRepository.getGeneratedMessage(generateId);
  }

  /// 获取当前生成消息
  GeneratedMessage? getCurrentGeneratedMessage() {
    if (currentGenerateId == null) {
      return null;
    }
    return getMessage(currentGenerateId!);
  }

  /// 删除生成消息
  void removeMessage(int generateId) {
    final generatedMessage = getMessage(generateId);
    if (generatedMessage == null) {
      return;
    }
    GeneratedMessageRepository.delete(generateId);
    _handleUpdateGenerateList(generatedMessage.msgId);
  }

  /// 删除生成消息
  void removeMessages(int msgId) {
    GeneratedMessageRepository.deleteByMsgId(msgId);
  }

  /// 保存消息
  void saveMessage(int generateId) {
    final generatedMessage = getMessage(generateId);
    if (generatedMessage == null) {
      return;
    }
    MessageRepository.updateMessage(
      msgId: generatedMessage.msgId,
      content: generatedMessage.content,
      status: generatedMessage.status,
      llmId: generatedMessage.llmId,
      llmName: generatedMessage.llmName,
      generateId: generatedMessage.generateId,
    );
    _handleUpdateMessage(generatedMessage.msgId);
  }

  /// 监听生成消息
  void listenGenerate({
    int? generateId,
    void Function(String)? onGenerate,
    void Function()? onDone,
    void Function(dynamic)? onError,
    void Function()? onCancel,
  }) {
    if (generateId == null && currentGenerateId == null) {
      return;
    }
    generateId ??= currentGenerateId;

    if (onGenerate != null) {
      if (_generateHandlerMap[generateId] == null) {
        _generateHandlerMap[generateId!] = [];
      }
      _generateHandlerMap[generateId]!.add(onGenerate);
    }
    if (onDone != null) {
      if (_doneHandlerMap[generateId] == null) {
        _doneHandlerMap[generateId!] = [];
      }
      _doneHandlerMap[generateId]!.add(onDone);
    }
    if (onError != null) {
      if (_errorHandlerMap[generateId] == null) {
        _errorHandlerMap[generateId!] = [];
      }
      _errorHandlerMap[generateId]!.add(onError);
    }
    if (onCancel != null) {
      if (_cancelHandlerMap[generateId] == null) {
        _cancelHandlerMap[generateId!] = [];
      }
      _cancelHandlerMap[generateId]!.add(onCancel);
    }
  }

  /// 移除监听生成消息
  void _removeGenerateListen(int generateId) {
    _generateHandlerMap.remove(generateId);
    _doneHandlerMap.remove(generateId);
    _errorHandlerMap.remove(generateId);
    _cancelHandlerMap.remove(generateId);
  }

  /// 处理生成事件
  void _handleGenerate(int generateId, String content) {
    _generateHandlerMap[generateId]?.forEach((handler) {
      try {
        handler(content);
      } catch (e) {}
    });
  }

  /// 处理完成事件
  void _handleDone(int generateId) {
    _doneHandlerMap[generateId]?.forEach((handler) {
      try {
        handler();
      } catch (e) {}
    });
  }

  /// 处理错误事件
  void _handleError(int generateId, dynamic error) {
    _errorHandlerMap[generateId]?.forEach((handler) {
      try {
        handler(error);
      } catch (e) {}
    });
  }

  /// 处理取消事件
  void _handleCancel(int generateId) {
    _cancelHandlerMap[generateId]?.forEach((handler) {
      try {
        handler();
      } catch (e) {}
    });
  }

  /// listenerId索引
  int _listenerId = 0;

  /// 监听消息更新
  int listenUpdateMessage(int msgId, void Function() handler) {
    if (_updateMessageHandlerMap[msgId] == null) {
      _updateMessageHandlerMap[msgId] = [];
    }
    final listenerId = _listenerId++;
    _updateMessageHandlerMap[msgId]!.add(Listener(handler, listenerId));
    return listenerId;
  }

  /// 移除监听消息更新
  void removeListenUpdateMessage(int msgId, int listenerId) {
    _updateMessageHandlerMap[msgId]
        ?.removeWhere((element) => element.listenerId == listenerId);
  }

  /// 更新消息
  void _handleUpdateMessage(int msgId) async {
    await WidgetsBinding.instance.endOfFrame;
    _updateMessageHandlerMap[msgId]?.forEach((listener) {
      try {
        listener.handler();
      } catch (e) {}
    });
  }

  /// 监听生成列表更新
  int listenUpdateGenerateList(
      int msgId, void Function(List<GeneratedMessage>) handler) {
    if (_updateGenerateListHandlerMap[msgId] == null) {
      _updateGenerateListHandlerMap[msgId] = [];
    }
    final listenerId = _listenerId++;
    _updateGenerateListHandlerMap[msgId]!.add(Listener(handler, listenerId));
    return listenerId;
  }

  /// 移除监听生成列表更新
  void removeListenUpdateGenerateList(int msgId, int listenerId) {
    _updateGenerateListHandlerMap[msgId]
        ?.removeWhere((element) => element.listenerId == listenerId);
  }

  /// 更新生成列表
  void _handleUpdateGenerateList(int msgId) async {
    await WidgetsBinding.instance.endOfFrame;
    _updateGenerateListHandlerMap[msgId]?.forEach((listener) {
      try {
        listener.handler(getMessages(msgId));
      } catch (e) {}
    });
  }
}

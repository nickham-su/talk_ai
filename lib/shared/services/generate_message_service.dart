import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/chat/models/conversation_message_model.dart';
import '../../modules/chat/repositorys/message_repository.dart';
import '../models/event_queue/event.dart';
import '../models/event_queue/event_queue.dart';
import '../models/message/message_status.dart';
import '../models/message/generated_message.dart';
import '../models/llm/llm_model.dart';
import '../models/message/message_model.dart';
import '../repositories/generated_message_repository.dart';
import 'llm_service.dart';

import '../models/event_queue/event_listener.dart';
import 'message_service.dart';

/// 生成消息事件类型
enum GenerateEventType {
  generate, // 生成中
  done, // 完成
  error, // 错误
  cancel, // 取消
}

/// 生成消息事件
class GenerateEvent {
  final GenerateEventType type;
  final dynamic data;

  GenerateEvent(this.type, this.data);
}

/// 生成消息服务
class GenerateMessageService extends GetxService {
  /// 当前生成的消息Id
  int? currentGenerateId;

  /// 是否在生成中
  bool get isGenerating => currentGenerateId != null;

  /// 生成消息事件队列
  final _generateEventQueue = EventQueue<GenerateEvent>();

  /// 生成列表更新事件队列
  final _updateGenerateListEventQueue = EventQueue<List<GeneratedMessage>>();

  /// 生成消息
  /// 返回generateId生成消息Id
  int generateMessage({
    int? generateId,
    required int llmId,
    required int chatAppId,
    required int msgId,
    required List<MessageModel> messages,
    ConversationMessageModel? sourceMessage,
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
        _generateEventQueue.emit(generateId,
            Event(GenerateEvent(GenerateEventType.generate, content)));
      },
      onDone: () {
        if (isGenerating) {
          GeneratedMessageRepository.update(
            generateId: generateId!,
            status: MessageStatus.completed,
          );
          currentGenerateId = null;
          _generateEventQueue.emit(
              generateId, Event(GenerateEvent(GenerateEventType.done, null)));
        }
        // 移除事件处理函数
        _generateEventQueue.clear();
      },
      onError: (e) {
        if (isGenerating) {
          GeneratedMessageRepository.update(
            generateId: generateId!,
            status: MessageStatus.failed,
            error: e.toString(),
          );
          currentGenerateId = null;
          _generateEventQueue.emit(
              generateId, Event(GenerateEvent(GenerateEventType.error, e)));
        }
        // 移除事件处理函数
        _generateEventQueue.clear();
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
    _generateEventQueue.emit(generatedMessage.generateId,
        Event(GenerateEvent(GenerateEventType.cancel, null)));
    _generateEventQueue.clear();
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

  /// 监听生成消息
  EventListener listenGenerate(
      int generateId, Function(GenerateEvent) callback) {
    return _generateEventQueue.addListener(generateId, (event) {
      callback(event.data);
    });
  }

  /// 监听生成列表更新
  EventListener listenUpdateGenerateList(
      int msgId, Function(List<GeneratedMessage>) handler) {
    final listener = _updateGenerateListEventQueue.addListener(msgId, (event) {
      handler(event.data);
    });
    return listener;
  }

  /// 更新生成列表
  void _handleUpdateGenerateList(int msgId) async {
    final messages = getMessages(msgId);
    _updateGenerateListEventQueue.emit(msgId, Event(messages));
  }
}

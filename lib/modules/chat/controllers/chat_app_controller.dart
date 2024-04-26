import 'dart:async';
import 'dart:math';

import 'package:TalkAI/shared/models/message/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/snackbar.dart';
import '../../../shared/models/llm/llm_model.dart';
import '../../../shared/models/message/message_status.dart';
import '../../../shared/models/message/generated_message.dart';
import '../../../shared/services/generate_message_service.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/utils/sqlite.dart';
import '../models/chat_app_model.dart';
import '../models/conversation_message_model.dart';
import '../repositorys/conversation_repository.dart';
import '../repositorys/message_repository.dart';
import 'chat_app_list_controller.dart';
import 'conversation_controller.dart';

class ChatAppController extends GetxController {
  /// 当前聊天App
  ChatAppModel? chatApp;

  /// 输入框控制器
  final TextEditingController inputController = TextEditingController();

  /// 输入框焦点
  final inputFocusNode = FocusNode();

  /// 显示搜索框
  bool showSearch = false;

  /// 搜索关键字
  String searchKeyword = '';

  /// 搜索到的当前消息
  ConversationMessageModel? currentMessage;

  /// 搜索到的当前消息的key
  GlobalKey? currentMessageKey;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  /// scrollview的key
  final GlobalKey scrollKey = GlobalKey();

  /// scrollview center上方的会话id列表
  List<int> topConversationIds = [];

  /// scrollview center下方的会话id列表
  List<int> bottomConversationIds = [];

  /// 生成消息服务
  final generateMessageService = Get.find<GenerateMessageService>();

  /// 发送中状态
  get isSending => generateMessageService.isGenerating;

  /// 设置当前聊天App
  void setChatApp(ChatAppModel? chatApp) async {
    final oldChatApp = this.chatApp;

    // 设置当前聊天App
    this.chatApp = chatApp;

    if (chatApp != null &&
        oldChatApp != null &&
        chatApp.chatAppId == oldChatApp.chatAppId &&
        chatApp.prompt == oldChatApp.prompt) {
      // 如果chatApp没有改变，且prompt没有改变，则不需要更新会话列表。
      return;
    }

    closeSearch();
    if (chatApp != null) {
      if (oldChatApp != null &&
          chatApp.chatAppId == oldChatApp.chatAppId &&
          chatApp.prompt != oldChatApp.prompt) {
        // 更新了提示词可能会修改最后一条系统消息，先清空再加载，确保列表刷新
        clearConversationList();
        await WidgetsBinding.instance.endOfFrame;
      }
      // 获取会话列表
      await fetchConversationList(chatApp.chatAppId);
      await WidgetsBinding.instance.endOfFrame;
      // 滚动到底部
      scrollToBottom(animate: false);
      await Future.delayed(const Duration(milliseconds: 100));
      scrollToBottom(animate: false);
      // 聚焦输入框
      inputFocusNode.requestFocus();
      // 如果正在生成消息，则添加监听，吸附到底部
      if (generateMessageService.isGenerating &&
          generateMessageService.getCurrentGeneratedMessage()!.chatAppId ==
              chatApp.chatAppId) {
        generateMessageService.listenGenerate(
          onGenerate: (content) {
            _attachToBottom();
          },
          onDone: () {
            if (!isClosed) update(['editor_toolbar']);
            _attachToBottom(always: true);
          },
          onError: (e) {
            if (!isClosed) update(['editor_toolbar']);
            _attachToBottom(always: true);
          },
          onCancel: () {
            if (!isClosed) update(['editor_toolbar']);
            _attachToBottom(always: true);
          },
        );
      }
    } else {
      // 清空会话列表
      clearConversationList();
    }
  }

  /// 获取会话列表
  fetchConversationList(int chatAppId) async {
    final results = await _asyncConversationList(chatAppId, null);
    topConversationIds = results[0];
    bottomConversationIds = results[1];

    // 如果会话列表为空，则创建新会话
    if (topConversationIds.isEmpty && bottomConversationIds.isEmpty) {
      createConversation();
    }

    update();
  }

  /// 异步获取会话列表，查询和分组都在后台线程运算
  /// chatAppId：聊天App id
  /// centerConversationId：中心会话id，如果为null，则bottomConversationIds保留最新的两条会话，其余的会话放在topConversationIds
  /// 返回值：[topConversationIds, bottomConversationIds]
  Future<List<List<int>>> _asyncConversationList(
      int chatAppId, int? centerConversationId) {
    return compute<Map<String, dynamic>, List<List<int>>>(
      _threadGetConversationIds,
      {
        'dbDir': Sqlite.dbDir,
        'chatAppId': chatAppId,
        'centerConversationId': centerConversationId,
      },
    );
  }

  /// 清空会话列表
  clearConversationList() {
    topConversationIds.clear();
    bottomConversationIds.clear();
    update();
  }

  /// 创建新会话
  void createConversation() {
    if (chatApp == null) {
      return;
    }

    // 如果会话列表最后一个会话中，没有任何用户消息，则当前就是新会话，不再创建
    if (bottomConversationIds.isNotEmpty) {
      final messages =
          MessageRepository.getMessageList(bottomConversationIds.last);
      if (messages.every((element) => element.role != MessageRole.user)) {
        return;
      }
    }

    // 创建新会话
    final conversationId = ConversationRepository.insertConversation(
      chatAppId: chatApp!.chatAppId,
    );
    bottomConversationIds.add(conversationId);

    // 插入系统消息
    MessageRepository.insertMessage(
      chatAppId: chatApp!.chatAppId,
      conversationId: conversationId,
      role: MessageRole.system,
      content: chatApp!.prompt,
      status: MessageStatus.completed,
    );

    // 记录使用chatApp
    useChatApp();

    update();
  }

  /// 删除会话
  void removeConversation(int conversationId) {
    // 删除会话
    ConversationRepository.deleteConversation(conversationId: conversationId);
    // 删除消息和生成记录
    final messages = MessageRepository.getMessageList(conversationId);
    for (var m in messages) {
      MessageRepository.deleteMessage(msgId: m.msgId);
      generateMessageService.removeMessages(m.msgId);
    }
    // 从会话列表中删除
    topConversationIds.remove(conversationId);
    bottomConversationIds.remove(conversationId);

    update();
  }

  /// 最近一次滚动的时间，用于去重
  DateTime lastScrollTime = DateTime.now();

  /// 吸附到底部
  void _attachToBottom({always = false}) {
    if (isClosed) return; // 防止控制器被销毁后调用
    if (scrollController.position.pixels >
        (scrollController.position.maxScrollExtent - 200)) {
      // 如果两次滚动时间间隔小于500ms，则不滚动
      final now = DateTime.now();
      if (now.difference(lastScrollTime) > const Duration(milliseconds: 500) ||
          always) {
        lastScrollTime = now;
        scrollToBottom();
      }
    }
  }

  /// 滚动到底部
  Future scrollToBottom({bool animate = true}) async {
    await WidgetsBinding.instance.endOfFrame;
    if (scrollController.position.pixels <
        (scrollController.position.maxScrollExtent - 2000)) {
      animate = false;
    }

    bool isBottom = true;
    // 如果当前位置不在底部，要分两次滚动到底部，第一次滚到底部，加载底部回话，第二次滚到底部
    for (var i = 0; i < 3; i++) {
      if (scrollController.position.pixels >
          (scrollController.position.maxScrollExtent - 400)) {
        break;
      }
      isBottom = false;
      await _scrollToBottom(animate: animate, curve: Curves.easeIn);
    }
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    await _scrollToBottom(
      animate: animate,
      curve: isBottom ? Curves.easeInOut : Curves.easeOut,
    );
  }

  /// 滚动到底部
  Future _scrollToBottom({
    bool animate = true,
    Curve curve = Curves.easeInOut,
  }) async {
    // 如果已经在底部，则不滚动
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      return;
    }
    if (animate) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: curve,
      );
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  /// 发送消息
  void sendMessage() async {
    if (chatApp == null) {
      return;
    }
    closeSearch();

    // 检查发送中的消息
    if (isSending) {
      snackbar('提示', '请等待发送中的消息发送完成');
      return;
    }

    // 会话id
    int conversationId = bottomConversationIds.last;

    // 查询历史消息
    List<ConversationMessageModel> messages =
        MessageRepository.getMessageList(conversationId);

    // 最新的助理消息
    ConversationMessageModel? lastAssistantMsg;
    for (final msg in messages.reversed) {
      if (msg.role == MessageRole.assistant) {
        lastAssistantMsg = msg;
        break;
      }
    }

    // 获取模型
    int llmId = lastAssistantMsg != null && lastAssistantMsg.llmId != 0
        ? lastAssistantMsg.llmId
        : chatApp!.llmId;
    final LLM? llm = Get.find<LLMService>().getLLM(llmId);
    if (llm == null) {
      snackbar('提示', '模型设置错误，请检查！');
      return;
    }

    // 记录使用chatApp
    useChatApp();
    // 更新会话时间
    ConversationRepository.updateConversationTime(conversationId);

    // 插入用户消息
    MessageRepository.insertMessage(
      chatAppId: chatApp!.chatAppId,
      conversationId: conversationId,
      role: MessageRole.user,
      content: inputController.text.trim(),
      status: MessageStatus.completed,
    );

    // 查询历史消息
    messages = MessageRepository.getMessageList(conversationId);

    // 生成消息
    _generateMessage(
      messages: messages,
      llm: llm,
      conversationId: conversationId,
    );

    // 清空输入框，延迟是等待最后的回车键输入完成
    Future.delayed(const Duration(milliseconds: 100), () {
      inputController.clear();
    });

    // 更新当前会话，如果会话控制器不在内存中，则滚动到底部加载会话。尝试3次。
    for (var i = 0; i < 3; i++) {
      try {
        // 更新会话的消息
        final conversationController = Get.find<ConversationController>(
            tag: 'conversation_$conversationId');
        conversationController.refreshConversation();
        break;
      } catch (e) {
        // 滚动到底部
        if (i == 1) {
          // 第二次还是没有找到会话控制器，则清空会话列表，再加载会话
          clearConversationList();
          await WidgetsBinding.instance.endOfFrame;
          await fetchConversationList(chatApp!.chatAppId);
        }
        await scrollToBottom();
      }
    }

    // 滚动到底部
    await scrollToBottom();
  }

  /// 重新生成消息
  void regenerateMessage({
    required int msgId,
    int? llmId, // 指定llmId重新生成消息，否则为原llmId或chatApp的llmId
    int? generateId, // 指定generateId重新生成消息，否则为新生成
  }) {
    if (isSending) {
      snackbar('提示', '请等待发送中的消息发送完成');
      return;
    }

    final message = MessageRepository.getMessage(msgId);
    if (message.role != MessageRole.assistant) {
      throw Exception('只能再次生成机器人消息');
    }

    // 获取生成消息
    late GeneratedMessage? genMsg;
    if (generateId != null) {
      genMsg = generateMessageService.getMessage(generateId);
    }

    // 获取模型, 优先使用llmId，其次使用genMsg的llmId，再次使用chatApp的llmId
    final LLMService llmService = Get.find<LLMService>();
    LLM? llm = llmId != null ? llmService.getLLM(llmId) : null;
    llm = llm ?? (genMsg != null ? llmService.getLLM(genMsg.llmId) : null);
    llm = llm ?? (chatApp != null ? llmService.getLLM(chatApp!.llmId) : null);
    if (llm == null) {
      snackbar('提示', '模型设置错误，请检查！');
      return;
    }

    // 记录使用chatApp
    useChatApp();

    // 查询历史消息
    final messages = MessageRepository.getMessageList(message.conversationId);
    // 当前消息是否为最后一条消息，如果是，则需要自动滚动到底部
    final isLast = messages.last.msgId == message.msgId &&
        bottomConversationIds.last == message.conversationId;
    // messages保留当前消息之前的消息，不包含当前消息
    messages.removeWhere((element) => element.msgId >= msgId);

    _generateMessage(
      messages: messages,
      llm: llm,
      conversationId: message.conversationId,
      assistantMsgId: msgId,
      generateId: generateId,
      autoScroll: isLast,
    );
  }

  /// 生成消息
  void _generateMessage({
    required List<ConversationMessageModel> messages,
    required LLM llm,
    required int conversationId,
    int? assistantMsgId, // 指定则更新消息，否则为新生成
    int? generateId, // 指定generateId重新生成消息，否则为新生成
    bool autoScroll = true,
  }) {
    final msgList = messages
        .map((e) => MessageModel(
              content: e.content,
              role: e.role,
            ))
        .toList();

    if (assistantMsgId == null) {
      // 插入机器人消息
      assistantMsgId = MessageRepository.insertMessage(
        chatAppId: chatApp!.chatAppId,
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: '',
        status: MessageStatus.unsent,
        llmId: llm.llmId,
        llmName: llm.name,
      );
    } else {
      // 更新消息状态
      MessageRepository.updateMessage(
        msgId: assistantMsgId,
        status: MessageStatus.unsent,
        content: '',
        llmId: llm.llmId,
        llmName: llm.name,
      );
    }

    generateId = generateMessageService.generateMessage(
      generateId: generateId,
      llmId: llm.llmId,
      chatAppId: chatApp!.chatAppId,
      msgId: assistantMsgId,
      messages: msgList,
      onGenerate: (content) {
        MessageRepository.updateMessage(
          msgId: assistantMsgId!,
          content: content,
          status: MessageStatus.sending,
        );
        if (autoScroll) _attachToBottom();
      },
      onDone: () {
        MessageRepository.updateMessage(
          msgId: assistantMsgId!,
          status: MessageStatus.completed,
        );
        if (!isClosed) update(['editor_toolbar']);
        if (autoScroll) _attachToBottom(always: true);
      },
      onError: (e) {
        MessageRepository.updateMessage(
          msgId: assistantMsgId!,
          status: MessageStatus.failed,
        );
        if (!isClosed) update(['editor_toolbar']);
        if (autoScroll) _attachToBottom(always: true);
      },
      onCancel: () {
        MessageRepository.updateMessage(
          msgId: assistantMsgId!,
          status: MessageStatus.cancel,
        );
        if (!isClosed) update(['editor_toolbar']);
        if (autoScroll) _attachToBottom(always: true);
      },
    );

    // 更新generateId
    MessageRepository.updateMessage(
      msgId: assistantMsgId,
      generateId: generateId,
    );

    update(['editor_toolbar']);
  }

  /// 停止接收
  void stopReceive() {
    generateMessageService.stopGenerate();
  }

  /// 删除引用消息之后的消息
  void _removeMessagesAfterQuote(ConversationMessageModel quoteMsg) {
    final messages = MessageRepository.getMessageList(quoteMsg.conversationId);
    if (quoteMsg.role == MessageRole.user) {
      // 修改消息，删除引用消息之后的消息，包括引用消息
      for (var message in messages) {
        if (message.msgId >= quoteMsg.msgId) {
          MessageRepository.deleteMessage(msgId: message.msgId);
          generateMessageService.removeMessages(message.msgId);
        }
      }
    } else {
      // 回复消息，删除引用消息之后的消息
      for (var message in messages) {
        if (message.msgId > quoteMsg.msgId) {
          MessageRepository.deleteMessage(msgId: message.msgId);
          generateMessageService.removeMessages(message.msgId);
        }
      }
    }
  }

  /// 删除当前消息以及之后的所有消息
  void removeMessage(int msgId) async {
    final message = MessageRepository.getMessage(msgId);
    final messages = MessageRepository.getMessageList(message.conversationId);
    for (var m in messages) {
      if (m.msgId >= msgId) {
        MessageRepository.deleteMessage(msgId: m.msgId);
        // 删除生成记录
        generateMessageService.removeMessages(m.msgId);
      }
    }
    try {
      // 更新会话的消息
      Get.find<ConversationController>(
              tag: 'conversation_${message.conversationId}')
          .refreshConversation();
    } catch (e) {
      await fetchConversationList(chatApp!.chatAppId);
      scrollToBottom(animate: false);
    }
  }

  /// 引用消息
  void quote(int msgId) async {
    late ConversationMessageModel quoteMessage;
    try {
      quoteMessage = MessageRepository.getMessage(msgId);
    } catch (e) {
      snackbar('提示', '引用的消息不存在');
      return;
    }
    // 删除引用消息之后的消息
    _removeMessagesAfterQuote(quoteMessage!);
    // 更新会话时间
    ConversationRepository.updateConversationTime(quoteMessage!.conversationId);
    // 刷新会话列表，先删除是为了确保正确更新
    await clearConversationList();
    await fetchConversationList(chatApp!.chatAppId);
    await WidgetsBinding.instance.endOfFrame;
    await scrollToBottom();
    if (quoteMessage.role == MessageRole.user) {
      inputController.text = quoteMessage.content;
    }
    inputFocusNode.requestFocus();
  }

  /// 使用chatApp
  void useChatApp() {
    Get.find<ChatAppListController>().recordLastUseTime(chatApp!.chatAppId);
  }

  /// 切换搜索框显示状态
  void toggleSearch() {
    if (chatApp == null) {
      showSearch = false;
    }
    showSearch = !showSearch;
    currentMessage = null;
    currentMessageKey = null;
    searchKeyword = '';
    update();
  }

  /// 关闭搜索框
  void closeSearch() {
    showSearch = false;
    currentMessage = null;
    currentMessageKey = null;
    searchKeyword = '';
    update();
  }

  /// 搜索消息
  void searchMessage({
    required String keyword,
    required bool isDesc,
  }) async {
    keyword = keyword.trim();
    if (keyword.isEmpty) {
      snackbar('提示', '请输入搜索关键字');
      return;
    }

    // 如果搜索关键字改变，则清空当前搜索结果
    if (keyword != searchKeyword) {
      currentMessage = null;
      currentMessageKey = null;
    }

    // 记录搜索关键字
    searchKeyword = keyword;

    // 设置开始消息id
    late int startMsgId;
    if (currentMessage != null) {
      // 如果有当前消息，则从当前消息开始搜索
      startMsgId = currentMessage!.msgId;
    } else {
      if (!isDesc) {
        snackbar('提示', '没有更多消息了');
        return;
      }
      // 如果没有当前消息，则从最后一条消息开始搜索
      startMsgId = 99999999999;
    }

    // 搜索消息
    final result = MessageRepository.search(
      chatAppId: chatApp!.chatAppId,
      keyword: keyword,
      startMsgId: startMsgId,
      isDesc: isDesc,
    );

    // 没有搜索到消息, 或者搜索到的消息不在当前会话列表中，则提示没有更多消息
    if (result == null ||
        (!topConversationIds.contains(result.conversationId) &&
            !bottomConversationIds.contains(result.conversationId))) {
      snackbar('提示', '没有更多消息了');
      if (currentMessage != null) {
        await _jumpCurrentMessage();
      }
      return;
    }

    // 记录搜索结果
    currentMessage = result;
    currentMessageKey = GlobalKey();

    // 重新加载列表，将搜索结果放在bottomConversationIds的第一条
    final results = await _asyncConversationList(
      chatApp!.chatAppId,
      currentMessage!.conversationId,
    );
    topConversationIds = results[0];
    bottomConversationIds = results[1];
    update();

    // 滚动到当前消息
    await _jumpCurrentMessage();
  }

  /// 跳转到搜索结果的当前消息
  Future _jumpCurrentMessage() async {
    scrollController.jumpTo(0);
    await WidgetsBinding.instance.endOfFrame;
    // 计算搜索结果的消息位置，并滚动到该位置
    final RenderBox msgBox =
        currentMessageKey!.currentContext!.findRenderObject() as RenderBox;
    final msgPosition = msgBox.localToGlobal(Offset.zero);
    scrollController.jumpTo(msgPosition.dy - 130); // 130：方便查看上一条消息
  }

  /// 是否为最后一条消息
  bool isLastMessage({required int msgId, int? conversationId}) {
    if (conversationId == null) {
      final message = MessageRepository.getMessage(msgId);
      conversationId = message.conversationId;
    }

    if (bottomConversationIds.last != conversationId) {
      return false;
    }

    final lastMessage = MessageRepository.getLastMessage(conversationId);
    return msgId == lastMessage?.msgId;
  }

  /// 上次滚动时间
  int _scrollTime = 0;

  /// 是否在滚动
  bool _isScrolling = false;

  /// 开始滚动
  void startScrolling(double direction) {
    const interval = 16; // 间隔
    const speed = 5.0; // 速度
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _scrollTime < interval) {
      return;
    }
    _scrollTime = now;
    _isScrolling = true;
    scrollController.jumpTo(scrollController.offset + direction * speed);

    Future.delayed(const Duration(milliseconds: interval), () {
      if (_isScrolling) {
        startScrolling(direction);
      }
    });
  }

  /// 停止滚动
  void stopScrolling() {
    _isScrolling = false;
  }

  /// 滚动到上一个会话
  scrollToPreviousConversation() {
    final scrollRender =
        scrollKey.currentContext!.findRenderObject() as RenderBox;
    final scrollHeight = scrollRender.size.height;

    // 获取会话Element列表
    List<Element> list = [];
    scrollKey.currentContext!.visitChildElements((element) {
      list.addAll(_getChild(element, 1, 25));
    });

    // 按位置排序，从上到下
    list.sort((a, b) {
      final renderObjectA = a.findRenderObject() as RenderBox;
      final renderObjectB = b.findRenderObject() as RenderBox;
      final positionA = renderObjectA.localToGlobal(Offset.zero);
      final positionB = renderObjectB.localToGlobal(Offset.zero);
      return positionA.dy.compareTo(positionB.dy);
    });

    // 计算移动的距离
    double top = 0;
    for (var element in list) {
      final renderObject = element.findRenderObject() as RenderBox;
      final position = renderObject.localToGlobal(Offset.zero);
      if (position.dy >= (scrollHeight - 50)) {
        break;
      }
      top = position.dy;
    }
    // 移动
    scrollController.animateTo(
      max(scrollController.position.pixels - (scrollHeight - top),
          scrollController.position.minScrollExtent - 50),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  /// 滚动到下一个会话
  scrollToNextConversation() {
    List<Element> list = [];
    scrollKey.currentContext!.visitChildElements((element) {
      list.addAll(_getChild(element, 1, 25));
    });
    // 按位置排序，从上到下
    list.sort((a, b) {
      final renderObjectA = a.findRenderObject() as RenderBox;
      final renderObjectB = b.findRenderObject() as RenderBox;
      final positionA = renderObjectA.localToGlobal(Offset.zero);
      final positionB = renderObjectB.localToGlobal(Offset.zero);
      return positionA.dy.compareTo(positionB.dy);
    });
    // 计算移动的距离
    double top = 0;
    double height = 0;
    for (var element in list) {
      final renderObject = element.findRenderObject() as RenderBox;
      final position = renderObject.localToGlobal(Offset.zero);
      if (position.dy > 50) {
        break;
      }
      top = position.dy;
      height = renderObject.size.height;
    }
    // 移动
    scrollController.animateTo(
      min(
        scrollController.position.pixels + top + height,
        scrollController.position.maxScrollExtent + 50,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  List<Element> _getChild(Element element, int current, int maxLevel) {
    if (current > maxLevel) {
      return [];
    }
    List<Element> list = [];
    element.visitChildElements((element) {
      Key? key = element.widget.key;
      if (key is ValueKey &&
          key.value.toString().contains('key_conversation_')) {
        list.add(element);
        return;
      }
      final children = _getChild(element, current + 1, maxLevel);
      list.addAll(children);
    });
    return list;
  }
}

/// 使用线程获取会话id列表，查询和分组都在后台线程运算
List<List<int>> _threadGetConversationIds(Map<String, dynamic> params) {
  Sqlite.openDB(params['dbDir']);
  final chatAppId = params['chatAppId'];
  final centerConversationId = params['centerConversationId'];
  if (chatAppId == null) {
    return [[], []];
  }

  final allList = ConversationRepository.getAllConversationIds(chatAppId);
  Sqlite.dispose();
  if (allList.isEmpty) {
    return [[], []];
  }
  if (centerConversationId == null) {
    final n = min(2, allList.length);
    return [
      allList.sublist(0, allList.length - n),
      allList.sublist(allList.length - n),
    ];
  }
  final index = allList.indexOf(centerConversationId);
  if (index == -1) {
    return [[], []];
  }
  return [
    allList.sublist(0, index),
    allList.sublist(index),
  ];
}

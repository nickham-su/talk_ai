import 'dart:async';
import 'dart:math';

import 'package:TalkAI/shared/models/message/message_model.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/snackbar.dart';
import '../../../shared/models/event_queue/event_listener.dart';
import '../../../shared/models/llm/llm_model.dart';
import '../../../shared/models/message/message_status.dart';
import '../../../shared/models/message/generated_message.dart';
import '../../../shared/services/conversation_service.dart';
import '../../../shared/services/generate_message_service.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/services/message_service.dart';
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

  /// 会话服务
  final conversationService = Get.find<ConversationService>();

  /// 消息服务
  final messageService = Get.find<MessageService>();

  /// 发送中状态
  get isSending => generateMessageService.isGenerating;

  @override
  void onInit() {
    // 监听消息生成更新editor_toolbar
    _updateToolbarByGenerate();
    super.onInit();
  }

  @override
  void onClose() {
    inputController.dispose();
    inputFocusNode.dispose();
    super.onClose();
  }

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
      // 获取会话列表
      await fetchConversationList(chatApp.chatAppId);
      await WidgetsBinding.instance.endOfFrame;
      // 滚动到底部
      scrollToBottom(animate: false);
      await Future.delayed(const Duration(milliseconds: 100));
      scrollToBottom(animate: false);
      // 聚焦输入框
      inputFocusNode.requestFocus();

      // 判断是否正在生成，且生成的消息是当前chatApp的消息，监听生成消息
      _scrollToBottomByGenerate();
    } else {
      // 清空会话列表
      clearConversationList();
    }
  }

  /// 获取会话列表
  fetchConversationList(int chatAppId) async {
    final all = await conversationService.getAllConversationIds(chatAppId);
    const int n = 2;
    topConversationIds = all.sublist(0, max(0, all.length - n));
    bottomConversationIds = all.sublist(max(0, all.length - n));

    // 如果会话列表为空，则创建新会话
    if (all.isEmpty) {
      createConversation();
    }

    update();
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
          messageService.getMessageList(bottomConversationIds.last);
      if (messages.every((element) => element.role != MessageRole.user)) {
        return;
      }
    }

    // 创建新会话
    final conversation =
        conversationService.insertConversation(chatApp!.chatAppId);
    bottomConversationIds.add(conversation.conversationId);

    // 插入系统消息
    messageService.insertMessage(
      chatAppId: chatApp!.chatAppId,
      conversationId: conversation.conversationId,
      role: MessageRole.system,
      content: chatApp!.prompt,
      status: MessageStatus.completed,
    );

    // 记录使用chatApp
    useChatApp();

    update();
  }

  /// 删除会话
  void removeConversation(int conversationId) async {
    // 删除会话
    await conversationService.deleteConversation(
        conversationId: conversationId);
    // 删除消息和生成记录
    final messages = messageService.getMessageList(conversationId);
    for (var m in messages) {
      messageService.deleteMessage(msgId: m.msgId);
      generateMessageService.removeMessages(m.msgId);
    }
    // 从会话列表中删除
    topConversationIds.remove(conversationId);
    bottomConversationIds.remove(conversationId);
    // bottomConversationIds删空了，则从topConversationIds中取一个
    if (bottomConversationIds.isEmpty && topConversationIds.isNotEmpty) {
      bottomConversationIds.add(topConversationIds.removeLast());
    }
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
  void sendMessage(String text) async {
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
        messageService.getMessageList(conversationId);

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
    conversationService.updateConversationTime(conversationId);

    // 插入用户消息
    messageService.insertMessage(
      chatAppId: chatApp!.chatAppId,
      conversationId: conversationId,
      role: MessageRole.user,
      content: text,
      status: MessageStatus.completed,
    );

    // 查询历史消息
    messages = messageService.getMessageList(conversationId);

    // 生成消息
    _generateMessage(
      messages: messages,
      llm: llm,
      conversationId: conversationId,
    );

    // 更新当前会话，如果会话控制器不在内存中，则滚动到底部加载会话。尝试3次。
    // for (var i = 0; i < 3; i++) {
    //   try {
    //     // 更新会话的消息
    //     final conversationController = Get.find<ConversationController>(
    //         tag: 'conversation_$conversationId');
    //     conversationController.refreshConversation();
    //     break;
    //   } catch (e) {
    //     // 滚动到底部
    //     if (i == 1) {
    //       // 第二次还是没有找到会话控制器，则清空会话列表，再加载会话
    //       clearConversationList();
    //       await WidgetsBinding.instance.endOfFrame;
    //       await fetchConversationList(chatApp!.chatAppId);
    //     }
    //     await scrollToBottom();
    //   }
    // }

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

    final message = messageService.getMessage(msgId);
    if (message == null) {
      snackbar('提示', '消息不存在');
      return;
    }
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
    final messages = messageService.getMessageList(message.conversationId);
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
      final assistantMsg = messageService.insertMessage(
        chatAppId: chatApp!.chatAppId,
        conversationId: conversationId,
        role: MessageRole.assistant,
        content: '',
        status: MessageStatus.unsent,
        llmId: llm.llmId,
        llmName: llm.name,
      );
      assistantMsgId = assistantMsg.msgId;
    } else {
      // 更新消息状态
      messageService.updateMessage(
        msgId: assistantMsgId,
        status: MessageStatus.unsent,
        content: '',
        llmId: llm.llmId,
        llmName: llm.name,
      );
    }

    // 生成消息
    generateId = generateMessageService.generateMessage(
      generateId: generateId,
      llmId: llm.llmId,
      chatAppId: chatApp!.chatAppId,
      msgId: assistantMsgId,
      messages: msgList,
    );

    // 监听事件，更新消息
    generateMessageService.listenGenerate(generateId, (event) {
      final message = messageService.getMessage(assistantMsgId!);
      if (message?.generateId != generateId) {
        return;
      }
      switch (event.type) {
        case GenerateEventType.generate:
          messageService.updateMessage(
            msgId: assistantMsgId!,
            content: event.data as String,
            status: MessageStatus.sending,
          );
          break;
        case GenerateEventType.done:
          messageService.updateMessage(
            msgId: assistantMsgId!,
            status: MessageStatus.completed,
          );
          break;
        case GenerateEventType.error:
          messageService.updateMessage(
            msgId: assistantMsgId!,
            status: MessageStatus.failed,
          );
          break;
        case GenerateEventType.cancel:
          messageService.updateMessage(
            msgId: assistantMsgId!,
            status: MessageStatus.cancel,
          );
          break;
      }
    });

    // 监听消息生成并滚动到底部
    _scrollToBottomByGenerate();
    // 更新工具栏
    _updateToolbarByGenerate();

    // 更新generateId
    messageService.updateMessage(
      msgId: assistantMsgId,
      generateId: generateId,
    );

    update(['editor_toolbar']);
  }

  /// 监听消息生成更新editor_toolbar，生成结束时，更新工具栏
  void _updateToolbarByGenerate() {
    final generateId = generateMessageService.currentGenerateId;
    if (generateId == null) return;
    generateMessageService.listenGenerate(generateId, (event) {
      if (isClosed) return;
      if (event.type != GenerateEventType.generate) {
        update(['editor_toolbar']);
      }
    });
  }

  /// 滚动到底部监听
  EventListener? _scrollToBottomByGenerateListener;

  /// 监听消息生成并滚动到底部
  void _scrollToBottomByGenerate() {
    // 判断是否正在生成，且生成的消息是当前chatApp的消息，监听生成消息
    if (!generateMessageService.isGenerating) return;
    final genMsg = generateMessageService.getCurrentGeneratedMessage();
    if (genMsg!.chatAppId != chatApp?.chatAppId) return;

    // 先取消之前的监听
    _scrollToBottomByGenerateListener?.cancel();
    // 监听生成消息
    _scrollToBottomByGenerateListener =
        generateMessageService.listenGenerate(genMsg.generateId, (event) {
      if (isClosed) return;
      // 如果是最后一条消息，则滚动到底部
      if (isLastMessage(msgId: genMsg.msgId)) {
        _attachToBottom(always: event.type != GenerateEventType.generate);
      }
    });
  }

  /// 停止接收
  void stopReceive() {
    generateMessageService.stopGenerate();
  }

  /// 删除当前消息以及之后的所有消息
  void removeMessage(int msgId) async {
    final message = messageService.getMessage(msgId);
    if (message == null) {
      await fetchConversationList(chatApp!.chatAppId);
      await WidgetsBinding.instance.endOfFrame;
      scrollToBottom(animate: false);
      return;
    }
    final messages = messageService.getMessageList(message.conversationId);
    for (var m in messages) {
      if (m.msgId >= msgId) {
        // 删除消息
        messageService.deleteMessage(msgId: m.msgId);
        // 删除生成记录
        generateMessageService.removeMessages(m.msgId);
      }
    }
  }

  /// 引用消息
  void quote(int msgId) async {
    final quoteMessage = messageService.getMessage(msgId);
    if (quoteMessage == null) {
      snackbar('提示', '引用的消息不存在');
      return;
    }
    // 更新会话时间
    conversationService.updateConversationTime(quoteMessage.conversationId);
    // 删除引用消息之后的消息
    _removeMessagesAfterQuote(quoteMessage);
    // 获取会话列表
    await fetchConversationList(chatApp!.chatAppId);
    await WidgetsBinding.instance.endOfFrame;
    // 滚动到底部
    await scrollToBottom();
    // 如果是用户消息，则将消息内容放入输入框
    if (quoteMessage.role == MessageRole.user) {
      inputController.text = quoteMessage.content;
    }
    inputFocusNode.requestFocus();
  }

  /// 删除引用消息之后的消息
  _removeMessagesAfterQuote(ConversationMessageModel quoteMsg) {
    final messages = messageService.getMessageList(quoteMsg.conversationId);
    if (quoteMsg.role == MessageRole.user) {
      // 修改消息，删除引用消息之后的消息，包括引用消息
      for (var message in messages) {
        if (message.msgId >= quoteMsg.msgId) {
          messageService.deleteMessage(msgId: message.msgId);
          generateMessageService.removeMessages(message.msgId);
        }
      }
    } else {
      // 回复消息，删除引用消息之后的消息
      for (var message in messages) {
        if (message.msgId > quoteMsg.msgId) {
          messageService.deleteMessage(msgId: message.msgId);
          generateMessageService.removeMessages(message.msgId);
        }
      }
    }
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
    final result = messageService.search(
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
    final all =
        await conversationService.getAllConversationIds(chatApp!.chatAppId);
    final index = all.indexOf(currentMessage!.conversationId);
    topConversationIds = all.sublist(0, index);
    bottomConversationIds = all.sublist(index);

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
      final message = messageService.getMessage(msgId);
      if (message == null) {
        return false;
      }
      conversationId = message.conversationId;
    }

    if (bottomConversationIds.last != conversationId) {
      return false;
    }

    final lastMessage = messageService.getLastMessage(conversationId);
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

  /// 遍历子元素
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

  /// 输入Enter键
  void onEnterKey() {
    final text1 = inputController.text; // 按Enter键前的文本
    Future.delayed(const Duration(milliseconds: 16), () {
      final text2 = inputController.text; // 按Enter键后的文本
      // 比较按Enter键前后的文本，如果是插入换行，则发送消息
      final dmp = DiffMatchPatch();
      List<Diff> diffs = dmp.diff(text1, text2);
      if ((diffs.length == 2 || diffs.length == 3) &&
          (diffs[0].text == '\n' || diffs[1].text == '\n')) {
        // 清空输入框
        inputController.text = '';
        // 发送消息，用text1是因为text2包含换行
        sendMessage(text1.trim());
      }
    });
  }
}

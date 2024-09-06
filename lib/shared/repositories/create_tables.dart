import '../../modules/chat/repositorys/chat_app_picture_repository.dart';
import '../../modules/chat/repositorys/chat_app_repository.dart';
import '../../modules/chat/repositorys/conversation_repository.dart';
import 'message_repository.dart';
import 'generated_message_repository.dart';
import 'llm_repository.dart';

/// 创建数据库表
void initDBTables(){
  ChatAppRepository.initTable();
  ChatAppPictureRepository.initTable();
  LLMRepository.initTable();
  ConversationRepository.initTable();
  MessageRepository.initTable();
  GeneratedMessageRepository.initTable();
}
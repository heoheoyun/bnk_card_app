import '../repositories/ai_repository.dart';
class SendChatMessageUsecase {
  final AiRepository _repo;
  SendChatMessageUsecase(this._repo);
  Future<Map<String, dynamic>> call(String message, String sessionId) => _repo.chat(message, sessionId);
}

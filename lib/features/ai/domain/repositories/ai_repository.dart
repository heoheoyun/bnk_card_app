abstract class AiRepository {
  Future<Map<String, dynamic>> chat(String message, String sessionId);
  Future<List<Map<String, dynamic>>> getChatHistory(String sessionId);
  Future<List<Map<String, dynamic>>> getMySpending();
  Future<int> updateSpending(List<Map<String, dynamic>> patterns);
}

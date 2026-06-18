import '../../domain/repositories/ai_repository.dart';
import '../datasource/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDatasource _ds;
  AiRepositoryImpl(this._ds);

  @override Future<Map<String, dynamic>> chat(String message, String sessionId) =>
      _ds.chat(message, sessionId);

  @override Future<List<Map<String, dynamic>>> getChatHistory(String sessionId) async {
    final list = await _ds.getChatHistory(sessionId);
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override Future<List<Map<String, dynamic>>> getMySpending() async {
    final list = await _ds.getMySpending();
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override Future<int> updateSpending(List<Map<String, dynamic>> patterns) =>
      _ds.updateSpending(patterns);
}

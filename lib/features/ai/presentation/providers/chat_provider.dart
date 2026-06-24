import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasource/ai_remote_datasource.dart';
import '../../data/models/chat_message_model.dart';
import '../../../../core/constants/storage_keys.dart';

final aiDatasourceProvider = Provider<AiRemoteDatasource>(
      (_) => AiRemoteDatasource(),
);

String _generateSessionId() =>
    'session_${DateTime.now().millisecondsSinceEpoch}';

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isLoading;
  const ChatState({this.messages = const [], this.isLoading = false});

  ChatState copyWith({List<ChatMessageModel>? messages, bool? isLoading}) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AiRemoteDatasource _ds;
  late String _sessionId;

  ChatNotifier(this._ds) : super(const ChatState()) {
    _initSession();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(StorageKeys.chatSessionId) ??
        _generateSessionId();
    await prefs.setString(StorageKeys.chatSessionId, _sessionId);
  }

  Future<void> sendMessage(String message) async {
    final userMsg = ChatMessageModel(
      role: ChatRole.user,
      content: message,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final res = await _ds.chat(message, _sessionId);
      final reply =
          res['response'] as String? ?? res['answer'] as String? ?? res['message'] as String? ?? '';
      final botMsg = ChatMessageModel(
        role: ChatRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (_) {
      final errMsg = ChatMessageModel(
        role: ChatRole.assistant,
        content: '오류가 발생했습니다. 다시 시도해 주세요.',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errMsg],
        isLoading: false,
      );
    }
  }

  void clearChat() => state = const ChatState();
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
      (ref) => ChatNotifier(ref.watch(aiDatasourceProvider)),
);
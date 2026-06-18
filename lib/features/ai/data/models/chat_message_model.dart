enum ChatRole { user, assistant }
class ChatMessageModel {
  final ChatRole role;
  final String   content;
  final DateTime createdAt;
  const ChatMessageModel({required this.role, required this.content, required this.createdAt});
  factory ChatMessageModel.fromJson(Map<String, dynamic> j) => ChatMessageModel(
    role: j['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
    content: j['content'] as String,
    createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

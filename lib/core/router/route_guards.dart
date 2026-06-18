import 'package:go_router/go_router.dart';
import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

class RouteGuards {
  RouteGuards._();
  static const _publicPrefixes = ['/login', '/signup', '/find-id', '/reset-password', '/', '/search', '/ai/chat'];

  static Future<String?> redirect(_, GoRouterState state) async {
    final isPublic = _publicPrefixes.any((p) => state.matchedLocation == p || state.matchedLocation.startsWith('/cards'));
    if (isPublic) return null;
    final token = await SecureStorage.read(StorageKeys.accessToken);
    if (token == null) return '/login';
    return null;
  }
}

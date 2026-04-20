import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/add_item_page.dart';
import '../pages/chat_page.dart';
import '../pages/home_page.dart';
import '../pages/item_detail_page.dart';
import '../pages/login_page.dart';
import '../pages/tags_page.dart';
import '../providers/auth_provider.dart';

class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}

GoRouter buildRouter(Ref ref) {
  final notifier = _AuthRouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;
      final isLogin = state.matchedLocation == '/login';
      if (!auth.isAuthenticated && !isLogin) return '/login';
      if (auth.isAuthenticated && isLogin) return '/home';
      return null;
    },
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (ctx, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add-item',
        builder: (ctx, state) {
          final url = state.uri.queryParameters['url'];
          return AddItemPage(initialUrl: url);
        },
      ),
      GoRoute(
        path: '/item/:id',
        builder: (ctx, state) =>
            ItemDetailPage(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat',
        builder: (ctx, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/tags',
        builder: (ctx, state) => const TagsPage(),
      ),
    ],
  );
}

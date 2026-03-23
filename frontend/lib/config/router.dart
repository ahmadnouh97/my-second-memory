import 'package:go_router/go_router.dart';

import '../pages/add_item_page.dart';
import '../pages/chat_page.dart';
import '../pages/home_page.dart';
import '../pages/item_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
      builder: (ctx, state) {
        final id = state.pathParameters['id']!;
        return ItemDetailPage(itemId: id);
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (ctx, state) => const ChatPage(),
    ),
  ],
);

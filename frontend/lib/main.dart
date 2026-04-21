import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'services/share_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: SecondMemoryApp()));
}

class SecondMemoryApp extends ConsumerStatefulWidget {
  const SecondMemoryApp({super.key});

  @override
  ConsumerState<SecondMemoryApp> createState() => _SecondMemoryAppState();
}

class _SecondMemoryAppState extends ConsumerState<SecondMemoryApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(ref);
    _checkInitialShareIntent();
    _listenForShareIntents();
  }

  Future<void> _checkInitialShareIntent() async {
    final url = await ShareService.getInitialSharedUrl();
    if (url == null || !mounted) return;

    // Wait for auth initialization to settle before navigating — without this,
    // the router redirect can fire while isLoading=false but isAuthenticated=false
    // (cold start race) and send the user to /login instead of /add-item.
    var auth = ref.read(authProvider);
    if (auth.isLoading) {
      auth = await ref
          .read(authProvider.notifier)
          .stream
          .firstWhere((s) => !s.isLoading);
    }

    if (auth.isAuthenticated && mounted) {
      _router.go('/add-item?url=${Uri.encodeComponent(url)}');
    }
  }

  void _listenForShareIntents() {
    ShareService.urlStream.listen((url) {
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        _router.go('/add-item?url=${Uri.encodeComponent(url)}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Second Memory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}

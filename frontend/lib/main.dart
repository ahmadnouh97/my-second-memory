import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/router.dart';
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
    _router = appRouter;
    _checkInitialShareIntent();
    _listenForShareIntents();
  }

  Future<void> _checkInitialShareIntent() async {
    final url = await ShareService.getInitialSharedUrl();
    if (url != null && mounted) {
      _router.go('/add-item?url=${Uri.encodeComponent(url)}');
    }
  }

  void _listenForShareIntents() {
    ShareService.urlStream.listen((url) {
      if (mounted) {
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

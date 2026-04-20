import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

class AuthState {
  const AuthState({this.token, this.isLoading = false, this.error});

  final String? token;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? Function()? token,
    bool? isLoading,
    String? Function()? error,
  }) =>
      AuthState(
        token: token != null ? token() : this.token,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._service) : super(const AuthState(isLoading: true));

  final AuthService _service;

  Future<void> initialize() async {
    final token = await _service.getToken();
    state = AuthState(token: token);
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final token = await _service.login(username, password);
      state = AuthState(token: token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> logout() async {
    await _service.clearToken();
    state = const AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref.watch(authServiceProvider));
  notifier.initialize();
  return notifier;
});

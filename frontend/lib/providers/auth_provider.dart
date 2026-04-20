import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthState {
  const AuthState({this.token, this.user, this.isLoading = false, this.error});

  final String? token;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? Function()? token,
    UserModel? Function()? user,
    bool? isLoading,
    String? Function()? error,
  }) =>
      AuthState(
        token: token != null ? token() : this.token,
        user: user != null ? user() : this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error != null ? error() : this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._service) : super(const AuthState(isLoading: true));

  final AuthService _service;

  Future<void> initialize() async {
    final token = await _service.getToken();
    if (token == null) {
      state = const AuthState();
      return;
    }
    // Try to fetch fresh user info; fall back to cached user on network error
    try {
      final freshUser = await _service.fetchMe(token);
      state = AuthState(token: token, user: freshUser);
    } catch (_) {
      final cachedUser = await _service.getUser();
      if (cachedUser != null) {
        state = AuthState(token: token, user: cachedUser);
      } else {
        // Token exists but server rejected it and no cache — log out
        await _service.clearSession();
        state = const AuthState();
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _service.login(email, password);
      state = AuthState(token: result.token, user: result.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _service.register(email, password);
      state = AuthState(token: result.token, user: result.user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> updateProfile({
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final updated = await _service.updateProfile(
        token: state.token,
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false, user: () => updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _service.clearSession();
    state = const AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((_) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref.watch(authServiceProvider));
  notifier.initialize();
  return notifier;
});

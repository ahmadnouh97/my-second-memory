import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment.dart';
import '../models/user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({required this.token, required this.user});
  final String token;
  final UserModel user;
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _store(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<AuthResult> login(String email, String password) async {
    final uri = Uri.parse('${Environment.baseUrl}/api/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      String detail = 'Login failed';
      try {
        detail = (jsonDecode(res.body) as Map<String, dynamic>)['detail']?.toString() ?? detail;
      } catch (_) {}
      throw AuthException(detail);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _store(token, user);
    return AuthResult(token: token, user: user);
  }

  Future<AuthResult> register(String email, String password) async {
    final uri = Uri.parse('${Environment.baseUrl}/api/auth/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 201) {
      String detail = 'Registration failed';
      try {
        detail = (jsonDecode(res.body) as Map<String, dynamic>)['detail']?.toString() ?? detail;
      } catch (_) {}
      throw AuthException(detail);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _store(token, user);
    return AuthResult(token: token, user: user);
  }

  Future<UserModel> fetchMe(String token) async {
    final uri = Uri.parse('${Environment.baseUrl}/api/auth/me');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw const AuthException('Session expired');
    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? token,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final authToken = token ?? await getToken();
    if (authToken == null) throw const AuthException('Not authenticated');
    final body = <String, dynamic>{};
    if (email != null) body['email'] = email;
    if (currentPassword != null) body['current_password'] = currentPassword;
    if (newPassword != null) body['new_password'] = newPassword;

    final uri = Uri.parse('${Environment.baseUrl}/api/auth/me');
    final res = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      String detail = 'Update failed';
      try {
        detail = (jsonDecode(res.body) as Map<String, dynamic>)['detail']?.toString() ?? detail;
      } catch (_) {}
      throw AuthException(detail);
    }
    final user = UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }
}

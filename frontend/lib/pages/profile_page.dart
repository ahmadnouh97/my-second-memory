import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _newEmailCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _emailSuccess;
  String? _passwordSuccess;

  @override
  void dispose() {
    _newEmailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _emailSuccess = null);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            email: _newEmailCtrl.text.trim(),
          );
      _newEmailCtrl.clear();
      if (mounted) setState(() => _emailSuccess = 'Email updated successfully');
    } catch (_) {}
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _passwordSuccess = null);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            currentPassword: _currentPassCtrl.text,
            newPassword: _newPassCtrl.text,
          );
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      if (mounted) setState(() => _passwordSuccess = 'Password updated successfully');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Account info ──────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(user?.email ?? '—'),
                    ],
                  ),
                  if (user?.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Member since ${user!.createdAt.year}-'
                          '${user.createdAt.month.toString().padLeft(2, '0')}-'
                          '${user.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Change email ──────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Change Email', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Form(
                    key: _emailFormKey,
                    child: TextFormField(
                      controller: _newEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'New Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),
                  if (_emailSuccess != null) ...[
                    const SizedBox(height: 8),
                    Text(_emailSuccess!, style: const TextStyle(color: Colors.green)),
                  ],
                  if (auth.error != null && _emailSuccess == null) ...[
                    const SizedBox(height: 8),
                    Text(auth.error!, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _changeEmail,
                    child: const Text('Update Email'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Change password ───────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Change Password', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Form(
                    key: _passwordFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPassCtrl,
                          obscureText: _obscureCurrent,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newPassCtrl,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscureNew = !_obscureNew),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 8) return 'At least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v != _newPassCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_passwordSuccess != null) ...[
                    const SizedBox(height: 8),
                    Text(_passwordSuccess!, style: const TextStyle(color: Colors.green)),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _changePassword,
                    child: const Text('Update Password'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Logout ────────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

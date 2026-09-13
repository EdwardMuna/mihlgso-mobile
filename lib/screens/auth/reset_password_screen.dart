import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../providers/core_providers.dart';

/// The reset link is emailed as a website URL (…/reset-password?token=…)
/// since email is the delivery channel regardless of web or mobile. The user
/// copies the token portion of that link into this screen. Reaching the
/// backend here reuses the exact same POST /api/auth/reset-password endpoint
/// the emailed page would call.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final strings = AppStrings.of(context);
    try {
      await ref.read(apiClientProvider).post('/auth/reset-password', data: {
        'token': _tokenController.text.trim(),
        'password': _passwordController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.passwordResetSignInMessage)),
        );
        context.go('/login');
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.resetPasswordTitle)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 38),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                strings.pasteResetTokenInstructions,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(labelText: strings.resetToken),
                validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.newPassword),
                validator: (v) => (v == null || v.length < 8) ? strings.atLeast8Characters : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.confirmNewPassword),
                validator: (v) => v != _passwordController.text ? strings.passwordsDoNotMatch : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(strings.resetPasswordTitle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

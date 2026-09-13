import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/core_providers.dart';

/// Lets an applicant check their membership application status by email —
/// mirrors the website's /membership/status page (CheckStatusForm).
class MembershipStatusScreen extends ConsumerStatefulWidget {
  const MembershipStatusScreen({super.key});

  @override
  ConsumerState<MembershipStatusScreen> createState() => _MembershipStatusScreenState();
}

class _MembershipStatusScreenState extends ConsumerState<MembershipStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  String? _error;
  String? _status;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
      _status = null;
    });
    try {
      final status = await ref.read(applicationServiceProvider).checkStatus(_emailController.text.trim());
      setState(() => _status = status);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  (String, Color, IconData) _statusDisplay(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    switch (status) {
      case 'APPROVED':
        return (strings.statusApprovedMessage, Colors.green, Icons.check_circle_outline);
      case 'PENDING':
        return (strings.statusPendingMessage, Colors.orange, Icons.hourglass_top_outlined);
      case 'REJECTED':
        return (strings.statusRejectedMessage, scheme.error, Icons.cancel_outlined);
      default:
        return (strings.statusNotFoundMessage, scheme.outline, Icons.help_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.checkApplicationStatus)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
        children: [
          Text(
            strings.enterEmailForStatusInstructions,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: strings.email, border: const OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return strings.emailRequired;
                if (!v.contains('@')) return strings.enterValidEmail;
                return null;
              },
              onFieldSubmitted: (_) => _checkStatus(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _submitting ? null : _checkStatus,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(strings.checkStatus),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_status != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Builder(builder: (context) {
              final (message, color, icon) = _statusDisplay(context, _status!);
              return Card(
                color: color.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 12),
                      Expanded(child: Text(message, style: TextStyle(color: color))),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

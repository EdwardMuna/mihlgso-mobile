import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../models/contribution_type.dart';

bool _isAnnualSubscription(String name) => name.toLowerCase().contains('annual subscription');

class _AccountGroup {
  _AccountGroup({
    required this.bankName,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.bankBranch,
    required this.items,
  });

  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankBranch;
  final List<ContributionType> items;
}

// Mirrors the website's WhereToPayMenu: several contribution types often pay
// into the same bank account, so group by account number and list the
// contribution types that share it underneath instead of repeating details.
List<_AccountGroup> _groupByAccount(List<ContributionType> items) {
  final groups = <String, _AccountGroup>{};
  final order = <String>[];
  for (final item in items) {
    final key = (item.bankAccountNumber?.trim().isNotEmpty ?? false)
        ? 'num:${item.bankAccountNumber!.trim().toLowerCase()}'
        : 'id:${item.id}';
    final existing = groups[key];
    if (existing != null) {
      existing.items.add(item);
    } else {
      groups[key] = _AccountGroup(
        bankName: item.bankName,
        bankAccountName: item.bankAccountName,
        bankAccountNumber: item.bankAccountNumber,
        bankBranch: item.bankBranch,
        items: [item],
      );
      order.add(key);
    }
  }
  return [for (final k in order) groups[k]!];
}

/// Bottom-sheet button + contents mirroring the website's `WhereToPayMenu`
/// (components/portal/WhereToPayMenu.tsx) on the member payments page:
/// tabs for Annual Subscription vs other contribution types' bank accounts,
/// grouped by account, with a copy-to-clipboard action per account number.
class WhereToPayButton extends StatelessWidget {
  const WhereToPayButton({super.key, required this.accounts, required this.currency});

  final List<ContributionType> accounts;
  final String Function(double) currency;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return OutlinedButton.icon(
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _WhereToPaySheet(accounts: accounts, currency: currency),
      ),
      icon: const Icon(Icons.account_balance_outlined, size: 18),
      label: Text('${strings.bankAccountsTitle}${accounts.isNotEmpty ? ' (${accounts.length})' : ''}'),
    );
  }
}

class _WhereToPaySheet extends StatefulWidget {
  const _WhereToPaySheet({required this.accounts, required this.currency});

  final List<ContributionType> accounts;
  final String Function(double) currency;

  @override
  State<_WhereToPaySheet> createState() => _WhereToPaySheetState();
}

class _WhereToPaySheetState extends State<_WhereToPaySheet> {
  late bool _showAnnual;

  List<ContributionType> get _annual => widget.accounts.where((a) => _isAnnualSubscription(a.name)).toList();
  List<ContributionType> get _other => widget.accounts.where((a) => !_isAnnualSubscription(a.name)).toList();

  @override
  void initState() {
    super.initState();
    _showAnnual = _annual.isNotEmpty || _other.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final visible = _showAnnual ? _annual : _other;
    final groups = _groupByAccount(visible);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.account_balance_outlined),
                const SizedBox(width: AppSpacing.sm),
                Text(strings.bankAccountsTitle, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(strings.bankAccountsSubtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text('${strings.bankTabAnnual}${_annual.isNotEmpty ? ' (${_annual.length})' : ''}'),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('${strings.bankTabOthers}${_other.isNotEmpty ? ' (${_other.length})' : ''}'),
                ),
              ],
              selected: {_showAnnual},
              onSelectionChanged: (s) => setState(() => _showAnnual = s.first),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: groups.isEmpty
                  ? Center(child: Text(strings.bankAccountsEmpty, style: Theme.of(context).textTheme.bodyMedium))
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _AccountCard(group: groups[i], currency: widget.currency),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.group, required this.currency});

  final _AccountGroup group;
  final String Function(double) currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (group.bankName != null && group.bankName!.isNotEmpty)
            _row(context, Icons.account_balance_outlined, group.bankName!, bold: true),
          if (group.bankAccountName != null && group.bankAccountName!.isNotEmpty)
            _row(context, Icons.person_outline, group.bankAccountName!),
          if (group.bankAccountNumber != null && group.bankAccountNumber!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  const Icon(Icons.tag, size: 16, color: Colors.grey),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      group.bankAccountNumber!,
                      style: const TextStyle(fontFamily: 'monospace', letterSpacing: 0.5),
                    ),
                  ),
                  _CopyIconButton(value: group.bankAccountNumber!),
                ],
              ),
            ),
          if (group.bankBranch != null && group.bankBranch!.isNotEmpty)
            _row(context, Icons.location_on_outlined, group.bankBranch!),
          const Divider(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in group.items)
                Chip(
                  label: Text('${item.name} · ${currency(item.amount)}'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
            ),
          ],
        ),
      );
}

class _CopyIconButton extends StatefulWidget {
  const _CopyIconButton({required this.value});

  final String value;

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: _copied ? strings.copied : strings.copy,
      icon: Icon(_copied ? Icons.check : Icons.copy, size: 16, color: _copied ? AppColors.secondary : Colors.grey),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.value));
        setState(() => _copied = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _copied = false);
        });
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../models/contribution_type.dart';
import 'fade_slide_in.dart';

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

/// Bottom-sheet trigger + contents mirroring the website's `WhereToPayMenu`
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _WhereToPaySheet(accounts: accounts, currency: currency),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: [
              BoxShadow(color: AppColors.gradientBlue.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_outlined, size: 17, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                strings.bankAccountsTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (accounts.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${accounts.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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

  // Tabs follow the bank account, not the contribution type name: any type
  // that shares the annual subscription's account (e.g. Office Construction)
  // belongs in the same tab, so members see one account instead of hunting
  // across tabs for the details they already found.
  List<_AccountGroup> get _allGroups => _groupByAccount(widget.accounts);
  List<_AccountGroup> get _annualGroups =>
      _allGroups.where((g) => g.items.any((it) => _isAnnualSubscription(it.name))).toList();
  List<_AccountGroup> get _otherGroups =>
      _allGroups.where((g) => g.items.every((it) => !_isAnnualSubscription(it.name))).toList();
  List<ContributionType> get _annual => _annualGroups.expand((g) => g.items).toList();
  List<ContributionType> get _other => _otherGroups.expand((g) => g.items).toList();

  @override
  void initState() {
    super.initState();
    _showAnnual = _annual.isNotEmpty || _other.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final groups = _showAnnual ? _annualGroups : _otherGroups;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
                        child: const Icon(Icons.account_balance_outlined, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          strings.bankAccountsTitle,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(strings.bankAccountsSubtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.md),
                  _TabSwitch(
                    showAnnual: _showAnnual,
                    annualLabel: strings.bankTabAnnual,
                    annualCount: _annual.length,
                    otherLabel: strings.bankTabOthers,
                    otherCount: _other.length,
                    onChanged: (v) => setState(() => _showAnnual = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: groups.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.account_balance_outlined, size: 32, color: theme.disabledColor),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                strings.bankAccountsEmpty,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        key: ValueKey(_showAnnual),
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                        itemCount: groups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) => FadeSlideIn(
                          index: i,
                          child: _AccountCard(group: groups[i], currency: widget.currency),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated pill-style tab switch (mirrors the website's segmented tab
/// control) with a sliding highlight instead of Material's default
/// SegmentedButton, so switching tabs feels smoother.
class _TabSwitch extends StatelessWidget {
  const _TabSwitch({
    required this.showAnnual,
    required this.annualLabel,
    required this.annualCount,
    required this.otherLabel,
    required this.otherCount,
    required this.onChanged,
  });

  final bool showAnnual;
  final String annualLabel;
  final int annualCount;
  final String otherLabel;
  final int otherCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = (constraints.maxWidth - 8) / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: showAnnual ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  width: segmentWidth,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _TabLabel(
                    text: annualCount > 0 ? '$annualLabel ($annualCount)' : annualLabel,
                    selected: showAnnual,
                    onTap: () => onChanged(true),
                  ),
                  _TabLabel(
                    text: otherCount > 0 ? '$otherLabel ($otherCount)' : otherLabel,
                    selected: !showAnnual,
                    onTap: () => onChanged(false),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.text, required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 34,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelMedium!.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : theme.textTheme.bodySmall?.color,
              ),
              child: Text(text, overflow: TextOverflow.ellipsis),
            ),
          ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
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
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.tag, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      group.bankAccountNumber!,
                      style: const TextStyle(fontFamily: 'monospace', letterSpacing: 0.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _CopyIconButton(value: group.bankAccountNumber!),
                ],
              ),
            ),
          if (group.bankBranch != null && group.bankBranch!.isNotEmpty)
            _row(context, Icons.location_on_outlined, group.bankBranch!),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in group.items)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${item.name} · ${currency(item.amount)}',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
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

class _CopyIconButtonState extends State<_CopyIconButton> with SingleTickerProviderStateMixin {
  bool _copied = false;
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.value));
        _bounce.forward(from: 0.85);
        setState(() => _copied = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      child: ScaleTransition(
        scale: _bounce,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _copied ? AppColors.secondary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Tooltip(
            message: _copied ? strings.copied : strings.copy,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _copied ? Icons.check : Icons.copy,
                key: ValueKey(_copied),
                size: 16,
                color: _copied ? AppColors.secondary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

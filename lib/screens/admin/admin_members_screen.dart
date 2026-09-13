import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/admin_member.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/state_views.dart';
import 'member_detail_screen.dart';
import 'member_form_screen.dart';

const _employmentStatusLabel = employmentStatusLabel;
const _memberAvatarImage = memberAvatarImage;

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleStatus(BuildContext context, WidgetRef ref, AdminMember member) async {
    final newStatus = member.status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE';
    try {
      await ref.read(adminServiceProvider).setMemberStatus(member.id, member, newStatus);
      ref.invalidate(adminMembersProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showMemberDetail(BuildContext context, WidgetRef ref, AdminMember summary) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MemberDetailScreen(memberId: summary.id, fallback: summary)),
    );
  }

  Future<void> _addMember(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MemberFormScreen()),
    );
    if (created == true) ref.invalidate(adminMembersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final membersAsync = ref.watch(adminMembersProvider);
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMember(context, ref),
        tooltip: strings.addMemberTooltip,
        child: const Icon(Icons.person_add_outlined),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminMembersProvider),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: strings.searchMembersHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchController.clear()),
                      ),
              ),
              onSubmitted: (_) => setState(() {}),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            membersAsync.when(
              loading: () => const SizedBox(height: 200, child: LoadingView()),
              error: (e, _) => SizedBox(
                height: 200,
                child: ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminMembersProvider)),
              ),
              data: (members) {
                final q = _searchController.text.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? members
                    : members
                        .where((m) =>
                            m.name.toLowerCase().contains(q) ||
                            m.email.toLowerCase().contains(q) ||
                            (m.phone ?? '').toLowerCase().contains(q) ||
                            (m.educationLevel ?? '').toLowerCase().contains(q))
                        .toList();

                if (filtered.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: EmptyView(message: strings.noMembersFound, icon: Icons.people_outline),
                  );
                }
                return Column(
                  children: [
                    for (final m in filtered)
                      Card(
                        child: InkWell(
                          onTap: () => _showMemberDetail(context, ref, m),
                          child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: _memberAvatarImage(m.photoDataUrl),
                                    child: _memberAvatarImage(m.photoDataUrl) == null
                                        ? const Icon(Icons.person_outline, size: 18)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Text(m.name, style: Theme.of(context).textTheme.titleMedium),
                                        if (m.isDonor)
                                          Chip(
                                            label: Text(strings.donorChip),
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                                          ),
                                        if (m.role == 'ADMIN')
                                          Chip(
                                            label: Text(strings.adminChip),
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: m.status == 'ACTIVE',
                                    onChanged: (_) => _toggleStatus(context, ref, m),
                                  ),
                                ],
                              ),
                              Text(
                                '${m.email}${m.institution != null && m.institution!.isNotEmpty ? ' · ${m.institution}' : ''}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  if (m.educationLevel != null && m.educationLevel!.isNotEmpty)
                                    _InfoChip(icon: Icons.school_outlined, label: m.educationLevel!),
                                  if (m.graduatedYear != null)
                                    _InfoChip(icon: Icons.event_outlined, label: '${strings.graduatedPrefix} ${m.graduatedYear}'),
                                  if (m.academicDiscipline != null && m.academicDiscipline!.isNotEmpty)
                                    _InfoChip(icon: Icons.menu_book_outlined, label: m.academicDiscipline!),
                                  if (m.employer != null && m.employer!.isNotEmpty)
                                    _InfoChip(icon: Icons.work_outline, label: m.employer!),
                                  if (m.gender != null && m.gender!.isNotEmpty)
                                    _InfoChip(icon: Icons.person_outline, label: m.gender!),
                                  if (m.employmentStatus != null && m.employmentStatus!.isNotEmpty)
                                    _InfoChip(icon: Icons.badge_outlined, label: _employmentStatusLabel(m.employmentStatus!, strings)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(m.status),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: m.status == 'ACTIVE'
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                                    labelStyle: TextStyle(
                                      color: m.status == 'ACTIVE' ? Colors.green : Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                  if (m.createdAt != null)
                                    Text('${strings.joinedPrefix} ${dateFmt.format(m.createdAt!)}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

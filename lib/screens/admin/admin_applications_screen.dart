import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/state_views.dart';
import 'member_detail_screen.dart' show memberAvatarImage;

class AdminApplicationsScreen extends ConsumerStatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  ConsumerState<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends ConsumerState<AdminApplicationsScreen> {
  final _busyIds = <int>{};

  Future<void> _approve(BuildContext context, WidgetRef ref, int id) async {
    if (_busyIds.contains(id)) return;
    setState(() => _busyIds.add(id));
    final strings = AppStrings.of(context);
    try {
      final tempPassword = await ref.read(adminServiceProvider).approveApplication(id);
      ref.invalidate(adminApplicationsProvider);
      ref.invalidate(adminOrgStatsProvider);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(strings.applicationApprovedTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.memberAccountCreatedMessage),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(strings.temporaryPasswordLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: SelectableText(
                        tempPassword,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: strings.copyPasswordTooltip,
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: tempPassword));
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(strings.copiedToClipboard)),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(strings.emailedToApplicantMessage),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(strings.ok))],
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, int id) async {
    if (_busyIds.contains(id)) return;
    setState(() => _busyIds.add(id));
    try {
      await ref.read(adminServiceProvider).rejectApplication(id);
      ref.invalidate(adminApplicationsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final applicationsAsync = ref.watch(adminApplicationsProvider);
    final dateFmt = DateFormat.yMMMd();

    return RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminApplicationsProvider),
        child: applicationsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminApplicationsProvider)),
          data: (apps) {
            if (apps.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noPendingApplications, icon: Icons.inbox_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: apps.length,
              itemBuilder: (context, i) {
                final a = apps[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a.photoDataUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CircleAvatar(radius: 22, backgroundImage: memberAvatarImage(a.photoDataUrl)),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.name, style: Theme.of(context).textTheme.titleMedium),
                                  Text('${a.email} · ${a.phone}'),
                                  Text('${a.registrationType} · ${dateFmt.format(a.createdAt)}',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (a.registrationType == 'MEMBER') ...[
                          const SizedBox(height: 6),
                          _Detail(label: strings.memberType, value: a.memberType),
                          _Detail(label: strings.institution, value: a.institution),
                          _Detail(label: strings.graduatedYearLabel, value: a.graduatedYear?.toString()),
                          _Detail(label: strings.postalAddress, value: a.postalAddress),
                          _Detail(label: strings.currentResidential, value: a.currentResidential),
                          _Detail(label: strings.employmentStatus, value: a.employmentStatus),
                          _Detail(label: strings.levelOfEducation, value: a.levelOfEducation),
                          _Detail(label: strings.gender, value: a.gender),
                          _Detail(label: strings.academicDiscipline, value: a.academicDiscipline),
                          _Detail(label: strings.employerOffice, value: a.employer),
                          _Detail(label: strings.nationality, value: a.nationality),
                          _Detail(label: strings.placeOfLiving, value: a.placeOfLiving),
                        ],
                        if (a.message != null && a.message!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text('"${a.message}"', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                        ],
                        if (a.reviewedAt != null)
                          Text('${strings.reviewedPrefix} ${dateFmt.format(a.reviewedAt!)}', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _busyIds.contains(a.id) ? null : () => _reject(context, ref, a.id),
                                child: Text(strings.reject),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: FilledButton(
                                onPressed: _busyIds.contains(a.id) ? null : () => _approve(context, ref, a.id),
                                child: _busyIds.contains(a.id)
                                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text(strings.approve),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

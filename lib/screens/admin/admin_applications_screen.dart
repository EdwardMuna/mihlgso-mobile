import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/member_application.dart';
import '../../providers/admin_providers.dart';
import '../../services/export_service.dart';
import '../../widgets/admin_card_shell.dart';
import '../../widgets/export_buttons.dart';
import '../../widgets/fade_slide_in.dart';
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

  List<List<String>> _exportRows(List<MemberApplicationSummary> apps, DateFormat dateFmt) {
    return apps
        .map((a) => [
              a.name,
              a.email,
              a.phone,
              a.registrationType,
              a.institution ?? '',
              a.employmentStatus ?? '',
              a.levelOfEducation ?? '',
              a.status.name,
              dateFmt.format(a.createdAt),
            ])
        .toList();
  }

  Future<void> _export(BuildContext context, Future<void> Function() run) async {
    try {
      await run();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).savedToDownloads)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
              itemCount: apps.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: ExportButtonsRow(
                      onExcel: () => _export(context, () => ExportService.exportExcel(
                            filename: 'mihlgso_applications',
                            title: strings.exportedFileTitleApplications,
                            headers: const ['Name', 'Email', 'Phone', 'Type', 'Institution', 'Employment', 'Education', 'Status', 'Submitted'],
                            rows: _exportRows(apps, dateFmt),
                          )),
                      onPdf: () => _export(context, () => ExportService.exportPdf(
                            filename: 'mihlgso_applications',
                            title: strings.exportedFileTitleApplications,
                            headers: const ['Name', 'Email', 'Phone', 'Type', 'Institution', 'Employment', 'Education', 'Status', 'Submitted'],
                            rows: _exportRows(apps, dateFmt),
                          )),
                      onCsv: () => _export(context, () => ExportService.exportCsv(
                            filename: 'mihlgso_applications',
                            title: strings.exportedFileTitleApplications,
                            headers: const ['Name', 'Email', 'Phone', 'Type', 'Institution', 'Employment', 'Education', 'Status', 'Submitted'],
                            rows: _exportRows(apps, dateFmt),
                          )),
                    ),
                  );
                }
                final i = index - 1;
                final a = apps[i];
                final isMember = a.registrationType == 'MEMBER';
                return FadeSlideIn(
                  index: i,
                  child: AdminCardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                              backgroundImage: memberAvatarImage(a.photoDataUrl),
                              child: a.photoDataUrl == null
                                  ? Text(
                                      a.name.isNotEmpty ? a.name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          a.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StatusPill(
                                        label: a.registrationType,
                                        color: isMember ? AppColors.primary : AppColors.secondaryDark,
                                        icon: isMember ? Icons.school_outlined : Icons.handshake_outlined,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${a.email} · ${a.phone}', style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_outlined, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(dateFmt.format(a.createdAt), style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (a.message != null && a.message!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '"${a.message}"',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        if (isMember) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.xs),
                              title: Text(strings.applicationDetails, style: Theme.of(context).textTheme.labelMedium),
                              leading: const Icon(Icons.info_outline, size: 18),
                              children: [
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
                            ),
                          ),
                        ],
                        const Divider(height: AppSpacing.lg),
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

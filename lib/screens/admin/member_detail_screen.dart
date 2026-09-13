import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/admin_member.dart';
import '../../providers/admin_providers.dart';
import 'member_form_screen.dart';

String employmentStatusLabel(String value, AppStrings strings) {
  switch (value) {
    case 'EMPLOYED':
      return strings.employmentStatusEmployed;
    case 'UNEMPLOYED':
      return strings.employmentStatusUnemployed;
    case 'SELF_EMPLOYED':
      return strings.employmentStatusSelfEmployed;
    case 'RETIRED':
      return strings.employmentStatusRetired;
    default:
      return value;
  }
}

ImageProvider? memberAvatarImage(String? photoDataUrl) {
  if (photoDataUrl == null || photoDataUrl.isEmpty) return null;
  final commaIndex = photoDataUrl.indexOf(',');
  if (commaIndex == -1) return null;
  try {
    final bytes = base64Decode(photoDataUrl.substring(commaIndex + 1));
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

/// Full member detail page, fetched separately from the list (GET
/// /admin/members/:id) — mirrors the website's admin member detail page.
class MemberDetailScreen extends ConsumerStatefulWidget {
  const MemberDetailScreen({super.key, required this.memberId, required this.fallback});

  final int memberId;
  final AdminMember fallback;

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  late Future<AdminMember> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(adminServiceProvider).fetchMember(widget.memberId);
  }

  Widget _detailRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
          Text(value == null || value.isEmpty ? '—' : value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final dateFmt = DateFormat.yMMMd();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fallback.name),
        actions: [
          FutureBuilder<AdminMember>(
            future: _future,
            builder: (context, snapshot) {
              final m = snapshot.data ?? widget.fallback;
              return IconButton(
                tooltip: strings.editTooltip,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => MemberFormScreen(existing: m)),
                  );
                  if (updated == true) {
                    ref.invalidate(adminMembersProvider);
                    setState(_load);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<AdminMember>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : snapshot.error.toString();
            return Center(child: Text('${strings.failedToLoadMemberPrefix}$message'));
          }
          final m = snapshot.data ?? widget.fallback;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: memberAvatarImage(m.photoDataUrl),
                      child: memberAvatarImage(m.photoDataUrl) == null ? const Icon(Icons.person_outline, size: 28) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: Theme.of(context).textTheme.titleLarge),
                          Text(m.email, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _detailRow(context, strings.roleLabel, m.role),
                _detailRow(context, strings.phone, m.phone),
                _detailRow(context, strings.institution, m.institution),
                _detailRow(context, strings.educationLevelLabel, m.educationLevel),
                _detailRow(context, strings.academicDisciplineLabel, m.academicDiscipline),
                _detailRow(context, strings.graduatedYearLabel, m.graduatedYear?.toString()),
                _detailRow(context, strings.employerOffice, m.employer),
                _detailRow(context, strings.employmentStatusLabel2, m.employmentStatus != null ? employmentStatusLabel(m.employmentStatus!, strings) : null),
                _detailRow(context, strings.gender, m.gender),
                _detailRow(context, strings.postalAddressLabel, m.postalAddress),
                _detailRow(context, strings.currentResidentialAddressLabel, m.currentResidential),
                _detailRow(context, strings.status, m.status),
                _detailRow(context, strings.donorLabel, m.isDonor ? strings.yes : strings.no),
                if (m.createdAt != null) _detailRow(context, strings.joined, dateFmt.format(m.createdAt!)),
              ],
            ),
          );
        },
      ),
    );
  }
}

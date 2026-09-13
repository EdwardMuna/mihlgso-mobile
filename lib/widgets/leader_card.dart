import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/api_config.dart';
import '../models/public/leadership_member.dart';

/// A leader's photo/name/role card, tappable to show their bio when present.
/// Shared by the Leadership Overview, Board, and Executive screens.
class LeaderCard extends StatelessWidget {
  const LeaderCard({super.key, required this.member});
  final LeadershipMember member;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: CachedNetworkImageProvider(ApiConfig.resolveAssetUrl(member.photo)),
        ),
        title: Text(member.name),
        subtitle: Text(member.role),
        isThreeLine: member.bio != null,
        onTap: member.bio == null
            ? null
            : () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(member.name),
                    content: Text(member.bio!),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    ],
                  ),
                ),
      ),
    );
  }
}

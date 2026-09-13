import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../widgets/state_views.dart';

/// Mirrors the website's Inbox page — the MoSMS developer API has no
/// inbound-message endpoint (only a carrier→MoSMS delivery webhook, not
/// callable by clients), so this always renders empty, same as the website.
class MoSmsInboxScreen extends StatelessWidget {
  const MoSmsInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.inbox)),
      body: EmptyView(
        message: strings.noInboundMessages,
        icon: Icons.inbox_outlined,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsItemsProvider);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.newsAndMilestonesTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(newsItemsProvider),
        child: newsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(newsItemsProvider)),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noNewsYet, icon: Icons.article_outlined),
                  const SizedBox(height: 20),
                  const AppFooter(),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                if (i == items.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: AppFooter(),
                  );
                }
                final item = items[i];
                final date = DateTime.tryParse(item.date);
                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(item.title)),
                        if (item.type.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Chip(label: Text(item.type), visualDensity: VisualDensity.compact),
                        ],
                      ],
                    ),
                    subtitle: Text(item.summary),
                    isThreeLine: true,
                    trailing: date == null ? null : Text(DateFormat.yMMMd().format(date), style: Theme.of(context).textTheme.bodySmall),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(item.title),
                        content: Text(item.summary),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.close)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

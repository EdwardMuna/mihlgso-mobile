import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/public/gallery_album.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(galleryAlbumsProvider);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.gallery)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(galleryAlbumsProvider),
        child: albumsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(galleryAlbumsProvider)),
          data: (albums) {
            if (albums.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noPhotosYet, icon: Icons.photo_library_outlined),
                  const SizedBox(height: 20),
                  const AppFooter(),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: albums.length + 1,
              itemBuilder: (context, i) {
                if (i == albums.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: AppFooter(),
                  );
                }
                final album = albums[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(album.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: album.images.length,
                        itemBuilder: (context, j) {
                          final img = album.images[j];
                          return GestureDetector(
                            onTap: () => _openViewer(context, album, j),
                            child: Tooltip(
                              message: img.alt.isNotEmpty ? img.alt : album.name,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                child: CachedNetworkImage(
                                  imageUrl: ApiConfig.resolveAssetUrl(img.src),
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                  errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                                  imageBuilder: (_, imageProvider) => Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    semanticLabel: img.alt.isNotEmpty ? img.alt : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openViewer(BuildContext context, GalleryAlbum album, int startIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GalleryViewerScreen(album: album, startIndex: startIndex),
      ),
    );
  }
}

class _GalleryViewerScreen extends StatefulWidget {
  const _GalleryViewerScreen({required this.album, required this.startIndex});
  final GalleryAlbum album;
  final int startIndex;

  @override
  State<_GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}

class _GalleryViewerScreenState extends State<_GalleryViewerScreen> {
  late final PageController _controller = PageController(initialPage: widget.startIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.album.images;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text(widget.album.name)),
      body: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        itemBuilder: (context, i) {
          final img = images[i];
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: ApiConfig.resolveAssetUrl(img.src),
                fit: BoxFit.contain,
                imageBuilder: (_, imageProvider) => Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  semanticLabel: img.alt.isNotEmpty ? img.alt : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

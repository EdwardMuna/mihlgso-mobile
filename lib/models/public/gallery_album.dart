class GalleryImage {
  const GalleryImage({required this.id, required this.src, required this.alt});

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id']?.toString() ?? '',
      src: json['src'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
    );
  }

  final String id;
  final String src;
  final String alt;
}

class GalleryAlbum {
  const GalleryAlbum({required this.key, required this.name, required this.images});

  factory GalleryAlbum.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>? ?? [];
    return GalleryAlbum(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      images: imagesList.map((e) => GalleryImage.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String key;
  final String name;
  final List<GalleryImage> images;
}

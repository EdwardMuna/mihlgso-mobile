class MoSmsMeta {
  const MoSmsMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory MoSmsMeta.fromJson(Map<String, dynamic> json) {
    return MoSmsMeta(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      from: (json['from'] as num?)?.toInt(),
      to: (json['to'] as num?)?.toInt(),
    );
  }

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  bool get hasMore => currentPage < lastPage;
}

/// Generic wrapper for MoSMS's `{ data: [...], meta: {...} }` list responses.
class MoSmsPaginated<T> {
  const MoSmsPaginated({required this.data, required this.meta});

  factory MoSmsPaginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final list = json['data'] as List<dynamic>? ?? [];
    final metaJson = json['meta'] as Map<String, dynamic>?;
    return MoSmsPaginated(
      data: list.map((e) => itemFromJson(e as Map<String, dynamic>)).toList(),
      meta: metaJson != null
          ? MoSmsMeta.fromJson(metaJson)
          : MoSmsMeta(currentPage: 1, lastPage: 1, perPage: list.length, total: list.length),
    );
  }

  final List<T> data;
  final MoSmsMeta meta;
}

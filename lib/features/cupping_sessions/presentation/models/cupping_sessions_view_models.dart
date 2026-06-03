class CuppingSessionsFilter {
  const CuppingSessionsFilter({
    this.origin,
    this.variety,
    this.processing,
    this.sessionDate,
  });

  final String? origin;
  final String? variety;
  final String? processing;
  final DateTime? sessionDate;

  static const empty = CuppingSessionsFilter();

  CuppingSessionsFilter copyWith({
    String? origin,
    String? variety,
    String? processing,
    DateTime? sessionDate,
    bool clearOrigin = false,
    bool clearVariety = false,
    bool clearProcessing = false,
    bool clearDate = false,
  }) {
    return CuppingSessionsFilter(
      origin: clearOrigin ? null : origin ?? this.origin,
      variety: clearVariety ? null : variety ?? this.variety,
      processing: clearProcessing ? null : processing ?? this.processing,
      sessionDate: clearDate ? null : sessionDate ?? this.sessionDate,
    );
  }

  bool get hasActiveFilters =>
      (origin != null && origin!.isNotEmpty) ||
      (variety != null && variety!.isNotEmpty) ||
      (processing != null && processing!.isNotEmpty) ||
      sessionDate != null;
}

enum CuppingSessionsSortOption {
  mostRecent,
  oldest,
  nameAsc,
}

extension CuppingSessionsSortOptionLabel on CuppingSessionsSortOption {
  String get label => switch (this) {
        CuppingSessionsSortOption.mostRecent => 'Más recientes',
        CuppingSessionsSortOption.oldest => 'Más antiguas',
        CuppingSessionsSortOption.nameAsc => 'Nombre A-Z',
      };
}

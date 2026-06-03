import 'package:cafelab_iot_mobile/features/cupping_sessions/data/cupping_sessions_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/cupping_sessions_repository.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/create_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/update_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/models/cupping_sessions_view_models.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';

class CuppingSessionsController extends ChangeNotifier {
  CuppingSessionsController({CuppingSessionsRepository? repository})
      : _repository = repository ?? CuppingSessionsRepositoryImpl();

  final CuppingSessionsRepository _repository;
  final List<CuppingSession> _allItems = <CuppingSession>[];

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? _lastActionMessage;
  String _searchQuery = '';
  bool _favoritesOnly = false;
  CuppingSessionsSortOption _sortOption = CuppingSessionsSortOption.mostRecent;
  CuppingSessionsFilter _filters = CuppingSessionsFilter.empty;

  List<CuppingSession> get allItems => List<CuppingSession>.unmodifiable(_allItems);

  List<CuppingSession> get items {
    Iterable<CuppingSession> filtered = _allItems;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(query) ||
            item.origin.toLowerCase().contains(query) ||
            item.variety.toLowerCase().contains(query);
      });
    }

    if (_favoritesOnly) {
      filtered = filtered.where((item) => item.favorite);
    }

    if (_filters.origin != null && _filters.origin!.isNotEmpty) {
      filtered = filtered.where((item) => item.origin == _filters.origin);
    }
    if (_filters.variety != null && _filters.variety!.isNotEmpty) {
      filtered = filtered.where((item) => item.variety == _filters.variety);
    }
    if (_filters.processing != null && _filters.processing!.isNotEmpty) {
      filtered = filtered.where((item) => item.processing == _filters.processing);
    }
    if (_filters.sessionDate != null) {
      filtered = filtered.where((item) {
        final date = _filters.sessionDate!;
        return item.sessionDate.year == date.year &&
            item.sessionDate.month == date.month &&
            item.sessionDate.day == date.day;
      });
    }

    final list = filtered.toList()
      ..sort((left, right) {
        return switch (_sortOption) {
          CuppingSessionsSortOption.mostRecent =>
            right.sessionDate.compareTo(left.sessionDate),
          CuppingSessionsSortOption.oldest =>
            left.sessionDate.compareTo(right.sessionDate),
          CuppingSessionsSortOption.nameAsc => left.name.toLowerCase().compareTo(
              right.name.toLowerCase(),
            ),
        };
      });

    return List<CuppingSession>.unmodifiable(list);
  }

  bool get hasItems => _allItems.isNotEmpty;
  bool get favoritesOnly => _favoritesOnly;
  CuppingSessionsSortOption get sortOption => _sortOption;
  CuppingSessionsFilter get filters => _filters;

  List<String> get availableOrigins => _uniqueSortedBy((item) => item.origin);
  List<String> get availableVarieties => _uniqueSortedBy((item) => item.variety);
  List<String> get availableProcessing => _uniqueSortedBy((item) => item.processing);

  Future<void> loadSessions() async {
    await _run(() async {
      final sessions = await _repository.list();
      _allItems
        ..clear()
        ..addAll(sessions);
      hasLoaded = true;
    });
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  void updateSortOption(CuppingSessionsSortOption value) {
    _sortOption = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  void updateFilters(CuppingSessionsFilter value) {
    _filters = value;
    notifyListeners();
  }

  void clearFilters() {
    _filters = CuppingSessionsFilter.empty;
    notifyListeners();
  }

  String? consumeActionMessage() {
    final message = _lastActionMessage;
    _lastActionMessage = null;
    return message;
  }

  Future<bool> create(CreateCuppingSessionRequest request) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.create(request);
      await _refreshSessions();
      _lastActionMessage = 'Sesión de cata creada correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> update(int id, UpdateCuppingSessionRequest request) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.update(id, request);
      await _refreshSessions();
      _lastActionMessage = 'Sesión de cata guardada correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> delete(int id) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.delete(id);
      await _refreshSessions();
      _lastActionMessage = 'Sesión de cata eliminada correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> toggleFavorite(CuppingSession session) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.update(
        session.id,
        UpdateCuppingSessionRequest(
          name: session.name,
          origin: session.origin,
          variety: session.variety,
          processing: session.processing,
          sessionDate: session.sessionDate,
          favorite: !session.favorite,
          resultsJson: session.resultsJson,
          roastStyleNotes: session.roastStyleNotes,
        ),
      );
      await _refreshSessions();
      _lastActionMessage = !session.favorite
          ? 'Sesión marcada como favorita.'
          : 'Sesión removida de favoritos.';
      isSuccess = true;
    });
    return isSuccess;
  }

  void replaceSession(CuppingSession updated) {
    final index = _allItems.indexWhere((item) => item.id == updated.id);
    if (index < 0) {
      return;
    }
    _allItems[index] = updated;
    notifyListeners();
  }

  List<String> _uniqueSortedBy(String Function(CuppingSession item) selector) {
    final values = _allItems.map(selector).where((value) => value.trim().isNotEmpty).toSet().toList()
      ..sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    return List<String>.unmodifiable(values);
  }

  Future<void> _refreshSessions() async {
    final sessions = await _repository.list();
    _allItems
      ..clear()
      ..addAll(sessions);
    hasLoaded = true;
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on ProductionApiException catch (error) {
      errorMessage = error.userMessage;
    } catch (error) {
      errorMessage = 'Error inesperado: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

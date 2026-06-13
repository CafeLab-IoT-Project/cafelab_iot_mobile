import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/roast_profiles_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/update_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/roast_profiles_repository.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';

class RoastProfilesController extends ChangeNotifier {
  RoastProfilesController({
    RoastProfilesRepository? repository,
    CoffeeLotsRepository? coffeeLotsRepository,
  }) : _repository = repository ?? RoastProfilesRepositoryImpl(),
       _coffeeLotsRepository =
           coffeeLotsRepository ?? CoffeeLotsRepositoryImpl();

  final RoastProfilesRepository _repository;
  final CoffeeLotsRepository _coffeeLotsRepository;
  final List<RoastProfile> _allItems = <RoastProfile>[];
  final List<CoffeeLot> _coffeeLots = <CoffeeLot>[];

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? _lastActionMessage;
  String _searchQuery = '';
  bool _sortOldestFirst = false;
  String? _typeFilter;
  bool _favoritesOnly = false;
  RoastProfile? selected;
  RoastProfile? compareLeft;
  RoastProfile? compareRight;

  List<RoastProfile> get items {
    Iterable<RoastProfile> filtered = _allItems;

    if (_searchQuery.isNotEmpty) {
      final normalizedQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(normalizedQuery) ||
            item.type.toLowerCase().contains(normalizedQuery);
      });
    }

    if (_typeFilter != null && _typeFilter!.isNotEmpty) {
      filtered = filtered.where((item) => item.type == _typeFilter);
    }

    if (_favoritesOnly) {
      filtered = filtered.where((item) => item.isFavorite);
    }

    final list = filtered.toList()
      ..sort((left, right) => _sortOldestFirst
          ? left.id.compareTo(right.id)
          : right.id.compareTo(left.id));

    return List<RoastProfile>.unmodifiable(list);
  }

  List<CoffeeLot> get coffeeLots => List<CoffeeLot>.unmodifiable(_coffeeLots);
  bool get hasItems => _allItems.isNotEmpty;
  bool get hasCoffeeLots => _coffeeLots.isNotEmpty;
  bool get sortOldestFirst => _sortOldestFirst;
  String? get typeFilter => _typeFilter;
  bool get favoritesOnly => _favoritesOnly;

  Future<void> loadAll() async {
    await _run(() async {
      await _refreshData();
    });
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  void updateTypeFilter(String? value) {
    _typeFilter = value == null || value.isEmpty ? null : value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortOldestFirst = !_sortOldestFirst;
    notifyListeners();
  }

  void clearFilters() {
    _typeFilter = null;
    _favoritesOnly = false;
    notifyListeners();
  }

  void selectProfile(RoastProfile profile) {
    selected = profile;
    notifyListeners();
  }

  void setComparisonProfiles({
    RoastProfile? left,
    RoastProfile? right,
  }) {
    compareLeft = left;
    compareRight = right;
    notifyListeners();
  }

  String? consumeActionMessage() {
    final message = _lastActionMessage;
    _lastActionMessage = null;
    return message;
  }

  Future<bool> create(CreateRoastProfileInput input) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.create(input);
      await _refreshData();
      _lastActionMessage = 'Perfil de tueste registrado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> update(int id, UpdateRoastProfileInput input) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.update(id, input);
      await _refreshData();
      _lastActionMessage = 'Perfil de tueste actualizado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> delete(int id) async {
    var isSuccess = false;
    await _run(() async {
      final message = await _repository.delete(id);
      await _refreshData();
      _lastActionMessage = message.isEmpty
          ? 'Perfil de tueste eliminado correctamente.'
          : message;
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> toggleFavorite(RoastProfile profile) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.update(
        profile.id,
        UpdateRoastProfileInput(
          name: profile.name,
          type: profile.type,
          duration: profile.duration,
          tempStart: profile.tempStart,
          tempEnd: profile.tempEnd,
          lot: profile.coffeeLotId,
          isFavorite: !profile.isFavorite,
        ),
      );
      await _refreshData();
      _lastActionMessage = !profile.isFavorite
          ? 'Perfil marcado como favorito.'
          : 'Perfil removido de favoritos.';
      isSuccess = true;
    });
    return isSuccess;
  }

  String lotLabelFor(int lotId) {
    final match = _coffeeLots.cast<CoffeeLot?>().firstWhere(
      (lot) => lot?.id == lotId,
      orElse: () => null,
    );
    if (match == null) {
      return 'Lote #$lotId';
    }
    return match.lotName;
  }

  Future<void> _refreshData() async {
    final results = await Future.wait<dynamic>([
      _repository.getAll(),
      _coffeeLotsRepository.getAll(),
    ]);
    final profiles = results[0] as List<RoastProfile>;
    final lots = results[1] as List<CoffeeLot>;
    _allItems
      ..clear()
      ..addAll(profiles);
    _coffeeLots
      ..clear()
      ..addAll(lots);
    hasLoaded = true;

    if (selected != null) {
      final selectedId = selected!.id;
      selected = _allItems.any((item) => item.id == selectedId)
          ? _allItems.firstWhere((item) => item.id == selectedId)
          : null;
    }

    if (compareLeft != null) {
      final leftId = compareLeft!.id;
      compareLeft = _allItems.any((item) => item.id == leftId)
          ? _allItems.firstWhere((item) => item.id == leftId)
          : null;
    }

    if (compareRight != null) {
      final rightId = compareRight!.id;
      compareRight = _allItems.any((item) => item.id == rightId)
          ? _allItems.firstWhere((item) => item.id == rightId)
          : null;
    }
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

import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/roast_profiles_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/update_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/roast_profiles_repository.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';

class RoastProfilesController extends ChangeNotifier {
  RoastProfilesController({RoastProfilesRepository? repository})
      : _repository = repository ?? RoastProfilesRepositoryImpl();

  final RoastProfilesRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? lastActionMessage;
  List<RoastProfile> items = [];
  RoastProfile? selected;

  Future<void> loadAll() async {
    await _run(() async {
      items = await _repository.getAll();
      lastActionMessage = 'Perfiles de tueste cargados';
    });
  }

  Future<void> filterByUserId(int userId) async {
    await _run(() async {
      items = await _repository.getByUserId(userId);
      lastActionMessage = 'Filtrado por userId=$userId';
    });
  }

  Future<void> filterByLotId(int lotId) async {
    await _run(() async {
      items = await _repository.getByCoffeeLotId(lotId);
      lastActionMessage = 'Filtrado por lot=$lotId';
    });
  }

  Future<void> getById(int id) async {
    await _run(() async {
      selected = await _repository.getById(id);
      lastActionMessage = 'Detalle cargado para id=$id';
    });
  }

  Future<void> create(CreateRoastProfileInput input) async {
    await _run(() async {
      final created = await _repository.create(input);
      lastActionMessage = 'Perfil creado (id=${created.id})';
      await loadAll();
    });
  }

  Future<void> update(int id, UpdateRoastProfileInput input) async {
    await _run(() async {
      final updated = await _repository.update(id, input);
      lastActionMessage = 'Perfil actualizado (id=${updated.id})';
      await loadAll();
    });
  }

  Future<void> delete(int id) async {
    await _run(() async {
      final msg = await _repository.delete(id);
      lastActionMessage = msg;
      await loadAll();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'Error inesperado: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

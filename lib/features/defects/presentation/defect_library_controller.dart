import 'package:cafelab_iot_mobile/features/defects/data/defects_api_service.dart';
import 'package:cafelab_iot_mobile/features/defects/data/defects_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/defects_repository.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/defect_model.dart';
import 'package:flutter/foundation.dart';

class DefectLibraryController extends ChangeNotifier {
  DefectLibraryController({DefectsRepository? repository})
      : _repository = repository ?? DefectsRepositoryImpl();

  final DefectsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<DefectModel> items = [];
  String coffeeSearchQuery = '';
  String defectSearchQuery = '';

  List<DefectModel> get filteredItems {
    final coffee = coffeeSearchQuery.trim().toLowerCase();
    final defect = defectSearchQuery.trim().toLowerCase();
    return items.where((row) {
      final coffeeLabel = row.coffeeDisplayName.toLowerCase();
      final defectLabel = row.name.toLowerCase();
      final coffeeMatch = coffee.isEmpty || coffeeLabel.contains(coffee);
      final defectMatch = defect.isEmpty || defectLabel.contains(defect);
      return coffeeMatch && defectMatch;
    }).toList();
  }

  Future<void> loadDefects() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      items = await _repository.getDefects();
    } on DefectsApiException catch (e) {
      errorMessage = e.displayMessage;
    } catch (e) {
      errorMessage = 'No se pudieron cargar los defectos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DefectModel?> getById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final defect = await _repository.getDefectById(id);
      isLoading = false;
      notifyListeners();
      return defect;
    } on DefectsApiException catch (e) {
      errorMessage = e.displayMessage;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = 'No se pudo cargar el defecto: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<DefectModel?> create(CreateDefectRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _repository.createDefect(request);
      await loadDefects();
      return created;
    } on DefectsApiException catch (e) {
      errorMessage = e.displayMessage;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = 'No se pudo registrar el defecto: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void updateCoffeeSearch(String value) {
    coffeeSearchQuery = value;
    notifyListeners();
  }

  void updateDefectSearch(String value) {
    defectSearchQuery = value;
    notifyListeners();
  }
}

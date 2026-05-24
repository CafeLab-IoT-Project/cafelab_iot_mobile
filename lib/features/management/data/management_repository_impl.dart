import 'package:cafelab_iot_mobile/features/management/data/management_api_service.dart';
import 'package:cafelab_iot_mobile/features/management/domain/management_repository.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/message_response.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/update_inventory_entry_request.dart';

class ManagementRepositoryImpl implements ManagementRepository {
  ManagementRepositoryImpl({ManagementApiService? apiService})
      : _apiService = apiService ?? ManagementApiService();

  final ManagementApiService _apiService;

  @override
  Future<InventoryEntry> createInventoryEntry(CreateInventoryEntryRequest request) {
    return _apiService.createInventoryEntry(request);
  }

  @override
  Future<List<InventoryEntry>> listInventoryEntries() {
    return _apiService.listInventoryEntries();
  }

  @override
  Future<List<InventoryEntry>> listInventoryEntriesByProfile(int userId) {
    return _apiService.listInventoryEntriesByProfile(userId);
  }

  @override
  Future<List<InventoryEntry>> listInventoryEntriesByCoffeeLot(int coffeeLotId) {
    return _apiService.listInventoryEntriesByCoffeeLot(coffeeLotId);
  }

  @override
  Future<InventoryEntry> getInventoryEntryById(int inventoryEntryId) {
    return _apiService.getInventoryEntryById(inventoryEntryId);
  }

  @override
  Future<InventoryEntry> updateInventoryEntry(
    int inventoryEntryId,
    UpdateInventoryEntryRequest request,
  ) {
    return _apiService.updateInventoryEntry(inventoryEntryId, request);
  }

  @override
  Future<MessageResponse> deleteInventoryEntry(int inventoryEntryId) {
    return _apiService.deleteInventoryEntry(inventoryEntryId);
  }
}

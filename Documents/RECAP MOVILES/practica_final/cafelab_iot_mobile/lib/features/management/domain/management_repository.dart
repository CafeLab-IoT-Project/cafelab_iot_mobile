import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/message_response.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/update_inventory_entry_request.dart';

abstract class ManagementRepository {
  Future<InventoryEntry> createInventoryEntry(CreateInventoryEntryRequest request);
  Future<List<InventoryEntry>> listInventoryEntries();
  Future<List<InventoryEntry>> listInventoryEntriesByProfile(int userId);
  Future<List<InventoryEntry>> listInventoryEntriesByCoffeeLot(int coffeeLotId);
  Future<InventoryEntry> getInventoryEntryById(int inventoryEntryId);
  Future<InventoryEntry> updateInventoryEntry(
    int inventoryEntryId,
    UpdateInventoryEntryRequest request,
  );
  Future<MessageResponse> deleteInventoryEntry(int inventoryEntryId);
}

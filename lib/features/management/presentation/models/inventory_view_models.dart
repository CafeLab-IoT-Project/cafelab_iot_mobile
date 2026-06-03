import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';

enum InventoryGrainType { green, roasted }

extension InventoryGrainTypeX on InventoryGrainType {
  String get label => switch (this) {
    InventoryGrainType.green => 'Verde',
    InventoryGrainType.roasted => 'Tostado',
  };

  String get sectionTitle => switch (this) {
    InventoryGrainType.green => 'Cafe verde',
    InventoryGrainType.roasted => 'Cafe tostado',
  };
}

InventoryGrainType inventoryGrainTypeFromStatus(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized.contains('roast') ||
      normalized.contains('tost') ||
      normalized.contains('toast')) {
    return InventoryGrainType.roasted;
  }
  return InventoryGrainType.green;
}

class InventoryLotSnapshot {
  const InventoryLotSnapshot({
    required this.lot,
    required this.supplier,
    required this.consumed,
    required this.currentStock,
  });

  final CoffeeLot lot;
  final Supplier? supplier;
  final double consumed;
  final double currentStock;

  InventoryGrainType get grainType => inventoryGrainTypeFromStatus(lot.status);

  bool get hasStock => currentStock > 0.0001;

  String get supplierLabel => supplier?.name ?? 'Proveedor #${lot.supplierId}';

  String get statusLabel => lot.status.trim().isEmpty ? 'N/A' : lot.status;
}

class InventoryEntryRecord {
  const InventoryEntryRecord({
    required this.entry,
    required this.lotSnapshot,
  });

  final InventoryEntry entry;
  final InventoryLotSnapshot? lotSnapshot;

  InventoryGrainType get grainType =>
      lotSnapshot?.grainType ?? InventoryGrainType.green;

  String get lotLabel =>
      lotSnapshot?.lot.lotName ?? 'Lote #${entry.coffeeLotId}';

  String get coffeeTypeLabel => lotSnapshot?.lot.coffeeType ?? 'N/A';

  String get supplierLabel => lotSnapshot?.supplierLabel ?? 'N/A';

  String get originLabel => lotSnapshot?.lot.origin ?? 'N/A';

  String get statusLabel => lotSnapshot?.statusLabel ?? 'N/A';

  double get currentLotStock => lotSnapshot?.currentStock ?? 0;
}

class InventorySummaryData {
  const InventorySummaryData({
    required this.totalStock,
    required this.selectedCoffeeType,
    required this.selectedTypeStock,
    required this.activeLotsCount,
    required this.suppliersCount,
  });

  final double totalStock;
  final String selectedCoffeeType;
  final double selectedTypeStock;
  final int activeLotsCount;
  final int suppliersCount;
}

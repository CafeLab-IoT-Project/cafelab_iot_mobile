import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';

class UpdateInventoryEntryRequest {
  const UpdateInventoryEntryRequest({
    required this.coffeeLotId,
    required this.quantityUsed,
    required this.dateUsed,
    required this.finalProduct,
  });

  final int coffeeLotId;
  final double quantityUsed;
  final DateTime dateUsed;
  final String finalProduct;

  Map<String, dynamic> toJson() => {
        'coffeeLotId': coffeeLotId,
        'quantityUsed': quantityUsed,
        'dateUsed': inventoryEntryDateToWire(dateUsed),
        'finalProduct': finalProduct,
      };
}

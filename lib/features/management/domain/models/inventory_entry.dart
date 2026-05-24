String inventoryEntryDateToWire(DateTime value) {
  final y = value.year.toString().padLeft(4, '0');
  final m = value.month.toString().padLeft(2, '0');
  final d = value.day.toString().padLeft(2, '0');
  final hh = value.hour.toString().padLeft(2, '0');
  final mm = value.minute.toString().padLeft(2, '0');
  final ss = value.second.toString().padLeft(2, '0');
  return '$y-$m-$d' 'T' '$hh:$mm:$ss';
}

DateTime inventoryEntryDateFromWire(String raw) => DateTime.parse(raw);

class InventoryEntry {
  const InventoryEntry({
    required this.id,
    required this.userId,
    required this.coffeeLotId,
    required this.quantityUsed,
    required this.dateUsed,
    required this.finalProduct,
  });

  final int id;
  final int userId;
  final int coffeeLotId;
  final double quantityUsed;
  final DateTime dateUsed;
  final String finalProduct;

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
    return InventoryEntry(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      coffeeLotId: (json['coffeeLotId'] as num).toInt(),
      quantityUsed: (json['quantityUsed'] as num).toDouble(),
      dateUsed: inventoryEntryDateFromWire(json['dateUsed'] as String),
      finalProduct: json['finalProduct'] as String,
    );
  }
}

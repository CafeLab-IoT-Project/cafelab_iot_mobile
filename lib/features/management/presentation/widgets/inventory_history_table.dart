import 'package:cafelab_iot_mobile/features/management/presentation/models/inventory_view_models.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_common.dart';
import 'package:flutter/material.dart';

class InventoryHistoryTable extends StatefulWidget {
  const InventoryHistoryTable({
    super.key,
    required this.items,
    required this.onView,
  });

  static const double _horizontalPadding = 16;
  static const double _tableWidth =
      120 + 150 + 120 + 140 + 94 + (_horizontalPadding * 2);
  static const double _headerHeight = 56;
  static const double _rowHeight = 68;

  final List<InventoryEntryRecord> items;
  final ValueChanged<InventoryEntryRecord> onView;

  @override
  State<InventoryHistoryTable> createState() => _InventoryHistoryTableState();
}

class _InventoryHistoryTableState extends State<InventoryHistoryTable> {
  late final ScrollController _horizontalController;
  late final ScrollController _verticalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleRows = widget.items.length.clamp(1, 5);
    final tableHeight =
        InventoryHistoryTable._headerHeight +
        (InventoryHistoryTable._rowHeight * visibleRows) +
        (visibleRows - 1);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox(
          height: tableHeight.toDouble(),
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: InventoryHistoryTable._tableWidth,
                child: Column(
                  children: [
                    Container(
                      height: InventoryHistoryTable._headerHeight,
                      color: const Color(0xFFA6C8C6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: InventoryHistoryTable._horizontalPadding,
                      ),
                      child: const Row(
                        children: [
                          _TableCell(label: 'Fecha', width: 120, isHeader: true),
                          _TableCell(label: 'Lote', width: 150, isHeader: true),
                          _TableCell(label: 'Consumo', width: 120, isHeader: true),
                          _TableCell(
                            label: 'Stock actual',
                            width: 140,
                            isHeader: true,
                          ),
                          _TableCell(label: 'Acciones', width: 94, isHeader: true),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: _verticalController,
                        padding: EdgeInsets.zero,
                        itemCount: widget.items.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Color(0xFFDDD8D2),
                        ),
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          return Material(
                            color: Colors.white,
                            child: InkWell(
                              onTap: () => widget.onView(item),
                              child: SizedBox(
                                height: InventoryHistoryTable._rowHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        InventoryHistoryTable._horizontalPadding,
                                  ),
                                  child: Row(
                                    children: [
                                      _TableCell(
                                        label:
                                            formatInventoryDate(item.entry.dateUsed),
                                        width: 120,
                                      ),
                                      _TableCell(label: item.lotLabel, width: 150),
                                      _TableCell(
                                        label:
                                            '${formatInventoryWeight(item.entry.quantityUsed)} kg',
                                        width: 120,
                                      ),
                                      _TableCell(
                                        label:
                                            '${formatInventoryWeight(item.currentLotStock)} kg',
                                        width: 140,
                                      ),
                                      SizedBox(
                                        width: 94,
                                        child: Center(
                                          child: InventoryActionIconButton(
                                            icon: Icons.search_rounded,
                                            tooltip: 'Ver detalle',
                                            onPressed: () => widget.onView(item),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.label,
    required this.width,
    this.isHeader = false,
  });

  final String label;
  final double width;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        maxLines: isHeader ? 1 : 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isHeader ? Colors.white : const Color(0xFF3E4234),
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          fontSize: isHeader ? 15 : 14,
        ),
      ),
    );
  }
}

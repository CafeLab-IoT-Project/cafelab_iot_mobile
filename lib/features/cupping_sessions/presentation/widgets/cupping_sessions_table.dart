import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:flutter/material.dart';

class CuppingSessionsTable extends StatelessWidget {
  const CuppingSessionsTable({
    super.key,
    required this.items,
    required this.horizontalController,
    required this.verticalController,
    required this.onFavorite,
    required this.onView,
    required this.onDelete,
  });

  final List<CuppingSession> items;
  final ScrollController horizontalController;
  final ScrollController verticalController;
  final ValueChanged<CuppingSession> onFavorite;
  final ValueChanged<CuppingSession> onView;
  final ValueChanged<CuppingSession> onDelete;

  static const double _tableWidth = 950;
  static const double _tableHeaderHeight = 56;
  static const double _tableRowHeight = 72;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = items.length;
        final separatorsHeight = itemCount > 0 ? itemCount - 1.0 : 0.0;
        final contentHeight =
            _tableHeaderHeight + (_tableRowHeight * itemCount) + separatorsHeight;
        final targetHeight = contentHeight.clamp(
          _tableHeaderHeight + _tableRowHeight,
          constraints.maxHeight,
        );
        final bodyHeight = targetHeight - _tableHeaderHeight;

        return Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
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
                height: targetHeight,
                child: Scrollbar(
                  controller: horizontalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _tableWidth,
                      child: Column(
                        children: [
                          const _TableHeader(),
                          SizedBox(
                            height: bodyHeight,
                            child: Scrollbar(
                              controller: verticalController,
                              thumbVisibility: itemCount > 1,
                              child: ListView.separated(
                                controller: verticalController,
                                padding: EdgeInsets.zero,
                                itemCount: itemCount,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFDDD8D2),
                                ),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return _TableRow(
                                    item: item,
                                    onFavorite: () => onFavorite(item),
                                    onView: () => onView(item),
                                    onDelete: () => onDelete(item),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AuthColors.header,
      height: CuppingSessionsTable._tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          _TableCell(label: 'Nombre', width: 250, isHeader: true),
          _TableCell(label: 'Fecha', width: 150, isHeader: true),
          _TableCell(label: 'Origen', width: 170, isHeader: true),
          _TableCell(label: 'Variedad', width: 170, isHeader: true),
          _TableCell(label: 'Acciones', width: 170, isHeader: true),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.item,
    required this.onFavorite,
    required this.onView,
    required this.onDelete,
  });

  final CuppingSession item;
  final VoidCallback onFavorite;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onView,
        child: SizedBox(
          height: CuppingSessionsTable._tableRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TableCell(label: item.name, width: 250),
                _TableCell(
                  label: formatSessionTableDate(item.sessionDate),
                  width: 150,
                ),
                _TableCell(label: item.origin, width: 170),
                _TableCell(label: item.variety, width: 170),
                SizedBox(
                  width: 170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: onFavorite,
                        splashRadius: 20,
                        tooltip: item.favorite
                            ? 'Quitar de favoritos'
                            : 'Marcar como favorito',
                        icon: Icon(
                          item.favorite ? Icons.star_rounded : Icons.star_border_rounded,
                          color: item.favorite
                              ? const Color(0xFFC7912B)
                              : const Color(0xFF4F5649),
                        ),
                      ),
                      IconButton(
                        onPressed: onView,
                        splashRadius: 20,
                        tooltip: 'Ver detalle',
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF4F5649),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        splashRadius: 20,
                        tooltip: 'Eliminar sesión',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFB83C3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

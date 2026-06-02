import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:flutter/material.dart';

class RoastProfilesTable extends StatelessWidget {
  const RoastProfilesTable({
    super.key,
    required this.items,
    required this.horizontalController,
    required this.verticalController,
    required this.lotLabelBuilder,
    required this.onFavorite,
    required this.onView,
    required this.onEdit,
    required this.onCompare,
    required this.onDelete,
  });

  static const double tableWidth = 760;
  static const double tableHeaderHeight = 56;
  static const double tableRowHeight = 72;

  final List<RoastProfile> items;
  final ScrollController horizontalController;
  final ScrollController verticalController;
  final String Function(int coffeeLotId) lotLabelBuilder;
  final ValueChanged<RoastProfile> onFavorite;
  final ValueChanged<RoastProfile> onView;
  final ValueChanged<RoastProfile> onEdit;
  final ValueChanged<RoastProfile> onCompare;
  final ValueChanged<RoastProfile> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = items.length;
        final separatorsHeight = itemCount > 0 ? itemCount - 1.0 : 0.0;
        final contentHeight =
            tableHeaderHeight + (tableRowHeight * itemCount) + separatorsHeight;
        final targetHeight = contentHeight.clamp(
          tableHeaderHeight + tableRowHeight,
          constraints.maxHeight,
        );
        final bodyHeight = targetHeight - tableHeaderHeight;

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
                      width: tableWidth,
                      child: Column(
                        children: [
                          const _RoastProfilesTableHeader(),
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
                                  final profile = items[index];
                                  return _RoastProfileRow(
                                    profile: profile,
                                    lotLabel: lotLabelBuilder(profile.coffeeLotId),
                                    onFavorite: () => onFavorite(profile),
                                    onView: () => onView(profile),
                                    onEdit: () => onEdit(profile),
                                    onCompare: () => onCompare(profile),
                                    onDelete: () => onDelete(profile),
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

class _RoastProfilesTableHeader extends StatelessWidget {
  const _RoastProfilesTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFA6C8C6),
      height: RoastProfilesTable.tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          _TableCell(label: 'Nombre', width: 180, isHeader: true),
          _TableCell(label: 'Tipo', width: 120, isHeader: true),
          _TableCell(label: 'Lote', width: 180, isHeader: true),
          _TableCell(label: 'Acciones', width: 248, isHeader: true),
        ],
      ),
    );
  }
}

class _RoastProfileRow extends StatelessWidget {
  const _RoastProfileRow({
    required this.profile,
    required this.lotLabel,
    required this.onFavorite,
    required this.onView,
    required this.onEdit,
    required this.onCompare,
    required this.onDelete,
  });

  final RoastProfile profile;
  final String lotLabel;
  final VoidCallback onFavorite;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onCompare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onView,
        child: SizedBox(
          height: RoastProfilesTable.tableRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TableCell(label: profile.name, width: 180),
                _TableCell(label: profile.type, width: 120),
                _TableCell(label: lotLabel, width: 180),
                SizedBox(
                  width: 248,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onFavorite,
                        splashRadius: 20,
                        tooltip: profile.isFavorite
                            ? 'Quitar favorito'
                            : 'Marcar favorito',
                        icon: Icon(
                          profile.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: profile.isFavorite
                              ? const Color(0xFFC89666)
                              : const Color(0xFF8F8A84),
                        ),
                      ),
                      _ActionIconButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'Ver detalle',
                        onPressed: onView,
                      ),
                      _ActionIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Editar perfil',
                        onPressed: onEdit,
                      ),
                      _ActionIconButton(
                        icon: Icons.compare_arrows_rounded,
                        tooltip: 'Comparar perfil',
                        onPressed: onCompare,
                      ),
                      _ActionIconButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Eliminar perfil',
                        color: const Color(0xFFB83C3C),
                        onPressed: onDelete,
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

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = const Color(0xFF3E4234),
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 20,
      tooltip: tooltip,
      icon: Icon(icon, color: color, size: 22),
    );
  }
}

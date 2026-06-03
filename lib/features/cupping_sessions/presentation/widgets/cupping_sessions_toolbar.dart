import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/models/cupping_sessions_view_models.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:flutter/material.dart';

class CuppingSessionsToolbar extends StatelessWidget {
  const CuppingSessionsToolbar({
    super.key,
    required this.searchController,
    required this.sortOption,
    required this.favoritesOnly,
    required this.isLoading,
    required this.onFilterPressed,
    required this.onComparePressed,
    required this.onSortChanged,
    required this.onFavoritesChanged,
  });

  final TextEditingController searchController;
  final CuppingSessionsSortOption sortOption;
  final bool favoritesOnly;
  final bool isLoading;
  final VoidCallback onFilterPressed;
  final VoidCallback onComparePressed;
  final ValueChanged<CuppingSessionsSortOption?> onSortChanged;
  final ValueChanged<bool> onFavoritesChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 980;
        final searchField = SizedBox(
          width: isNarrow ? double.infinity : 265,
          child: _SearchField(
            controller: searchController,
            enabled: !isLoading,
          ),
        );
        final filterButton = IconButton(
          onPressed: isLoading ? null : onFilterPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AuthColors.primary,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFD7D1C9)),
            ),
          ),
          icon: const Icon(Icons.filter_alt_outlined),
          tooltip: 'Filtrar sesiones',
        );
        final sortDropdown = SizedBox(
          width: isNarrow ? double.infinity : 210,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 6),
                child: Text(
                  'Ordenar por',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF66675F),
                  ),
                ),
              ),
              DropdownButtonFormField<CuppingSessionsSortOption>(
                initialValue: sortOption,
                decoration: cuppingInputDecoration(hintText: 'Ordenar por'),
                items: CuppingSessionsSortOption.values
                    .map(
                      (option) => DropdownMenuItem<CuppingSessionsSortOption>(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                borderRadius: BorderRadius.circular(18),
                dropdownColor: Colors.white,
                onChanged: isLoading ? null : onSortChanged,
              ),
            ],
          ),
        );
        final favoriteSwitch = Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch.adaptive(
                value: favoritesOnly,
                activeThumbColor: AuthColors.primary,
                onChanged: isLoading ? null : onFavoritesChanged,
              ),
              const Flexible(
                child: Text(
                  'Solo favoritos',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3E4234),
                  ),
                ),
              ),
            ],
          ),
        );
        final compareButton = SizedBox(
          width: isNarrow ? double.infinity : 190,
          child: AuthPrimaryButton(
            label: 'Comparar sesiones',
            onPressed: isLoading ? null : onComparePressed,
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  filterButton,
                  const SizedBox(width: 12),
                  Expanded(child: sortDropdown),
                ],
              ),
              const SizedBox(height: 10),
              favoriteSwitch,
              const SizedBox(height: 12),
              compareButton,
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            searchField,
            filterButton,
            sortDropdown,
            favoriteSwitch,
            compareButton,
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: const InputDecoration(
          hintText: 'Buscar sesiones',
          suffixIcon: Icon(Icons.search_rounded),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

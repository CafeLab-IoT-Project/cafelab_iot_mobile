import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:flutter/material.dart';

class RoastProfilesToolbar extends StatelessWidget {
  const RoastProfilesToolbar({
    super.key,
    required this.searchController,
    required this.isLoading,
    required this.canCreate,
    required this.sortOldestFirst,
    required this.onCreatePressed,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onComparePressed,
  });

  final TextEditingController searchController;
  final bool isLoading;
  final bool canCreate;
  final bool sortOldestFirst;
  final VoidCallback onCreatePressed;
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final VoidCallback onComparePressed;

  @override
  Widget build(BuildContext context) {
    final secondaryButtons = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SecondaryPillButton(
          label: 'Filtrar',
          icon: Icons.filter_list_rounded,
          onPressed: onFilterPressed,
        ),
        _SecondaryPillButton(
          label: sortOldestFirst ? 'Mas reciente' : 'Mas antiguo',
          icon: Icons.arrow_downward_rounded,
          onPressed: onSortPressed,
        ),
        _SecondaryPillButton(
          label: 'Comparar',
          icon: Icons.compare_arrows_rounded,
          onPressed: onComparePressed,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 620;
        final searchField = Container(
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
            controller: searchController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              hintText: 'Buscar perfil de tueste',
              prefixIcon: Icon(Icons.search_rounded),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            ),
          ),
        );

        final createButton = SizedBox(
          width: isStacked ? double.infinity : 240,
          child: AuthPrimaryButton(
            label: 'Registrar perfil de tueste',
            onPressed: isLoading || !canCreate ? null : onCreatePressed,
          ),
        );

        if (isStacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 12),
              secondaryButtons,
              const SizedBox(height: 14),
              createButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 14),
                createButton,
              ],
            ),
            const SizedBox(height: 12),
            secondaryButtons,
          ],
        );
      },
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  const _SecondaryPillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: const Color(0xFF575757)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF575757),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

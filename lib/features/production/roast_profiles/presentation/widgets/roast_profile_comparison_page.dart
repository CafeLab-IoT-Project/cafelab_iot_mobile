import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/roast_profiles_controller.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_curve_chart.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:flutter/material.dart';

class RoastProfileComparisonPage extends StatefulWidget {
  const RoastProfileComparisonPage({
    super.key,
    required this.profiles,
    required this.initialLeft,
    required this.initialRight,
    required this.controller,
  });

  final List<RoastProfile> profiles;
  final RoastProfile initialLeft;
  final RoastProfile initialRight;
  final RoastProfilesController controller;

  @override
  State<RoastProfileComparisonPage> createState() =>
      _RoastProfileComparisonPageState();
}

class _RoastProfileComparisonPageState extends State<RoastProfileComparisonPage> {
  late RoastProfile _left;
  late RoastProfile _right;

  @override
  void initState() {
    super.initState();
    _left = widget.initialLeft;
    _right = widget.initialRight;
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      onFeatures: () => Navigator.of(context).pop(),
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Perfiles de tueste > Comparacion de perfiles',
                  style: TextStyle(
                    color: Color(0xFF4E5342),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                _ComparisonSelectorCard(
                  title: 'Perfil de tueste 1',
                  value: _left.id,
                  profiles: widget.profiles,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _left = widget.profiles.firstWhere((item) => item.id == value);
                      widget.controller.setComparisonProfiles(
                        left: _left,
                        right: _right,
                      );
                    });
                  },
                ),
                const SizedBox(height: 18),
                _ComparisonSelectorCard(
                  title: 'Perfil de tueste 2',
                  value: _right.id,
                  profiles: widget.profiles,
                  trailingIcon: Icons.add_circle_outline_rounded,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _right = widget.profiles.firstWhere((item) => item.id == value);
                      widget.controller.setComparisonProfiles(
                        left: _left,
                        right: _right,
                      );
                    });
                  },
                ),
                const SizedBox(height: 26),
                const Text(
                  'Comparacion de perfiles de tueste',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E4234),
                  ),
                ),
                const SizedBox(height: 14),
                GraphCard(
                  child: RoastCurveChart.comparison(
                    left: _left,
                    right: _right,
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

class _ComparisonSelectorCard extends StatelessWidget {
  const _ComparisonSelectorCard({
    required this.title,
    required this.value,
    required this.profiles,
    required this.onChanged,
    this.trailingIcon,
  });

  final String title;
  final int value;
  final List<RoastProfile> profiles;
  final ValueChanged<int?> onChanged;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3E4234),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: value,
                decoration: roundedFieldDecoration('Selecciona un perfil'),
                items: profiles
                    .map(
                      (profile) => DropdownMenuItem<int>(
                        value: profile.id,
                        child: Text(
                          profile.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 12),
              Icon(trailingIcon, size: 34, color: const Color(0xFF8F8A84)),
            ],
          ],
        ),
      ],
    );
  }
}

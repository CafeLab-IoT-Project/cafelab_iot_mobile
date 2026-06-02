import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_curve_chart.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:flutter/material.dart';

class RoastProfileDetailDialog extends StatelessWidget {
  const RoastProfileDetailDialog({
    super.key,
    required this.profile,
    required this.lotLabel,
  });

  final RoastProfile profile;
  final String lotLabel;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.82;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 390, maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Detalles',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E4234),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DetailRow(label: 'Nombre', value: profile.name),
                DetailRow(label: 'Tipo de cafe', value: profile.type),
                DetailRow(
                  label: 'Duracion total del tueste (min)',
                  value: profile.duration.toString(),
                ),
                DetailRow(
                  label: 'Temperatura inicial del grano (°C)',
                  value: formatTemperature(profile.tempStart),
                ),
                DetailRow(
                  label: 'Temperatura final deseada del grano (°C)',
                  value: formatTemperature(profile.tempEnd),
                ),
                DetailRow(label: 'Lote vinculado', value: lotLabel),
                const SizedBox(height: 12),
                const Text(
                  'Curva de tueste',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E4234),
                  ),
                ),
                const SizedBox(height: 12),
                GraphCard(
                  child: RoastCurveChart.detail(profile: profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

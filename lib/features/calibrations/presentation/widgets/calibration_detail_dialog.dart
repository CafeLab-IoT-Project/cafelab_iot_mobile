import 'dart:convert';
import 'dart:typed_data';

import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalibrationDetailDialog extends StatelessWidget {
  const CalibrationDetailDialog({super.key, required this.calibration});

  final GrindCalibration calibration;

  static final _dateFormat = DateFormat('d/M/yyyy');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle de calibración',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: CostManagementColors.headerGreen,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_decodeBase64Image(calibration.sampleImage) != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _decodeBase64Image(calibration.sampleImage)!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    _DetailRow('Nombre', calibration.name),
                    _DetailRow('Método', calibration.method),
                    _DetailRow('Equipo', calibration.equipment),
                    _DetailRow('Molienda', calibration.grindNumber),
                    _DetailRow('Apertura', calibration.aperture.toString()),
                    _DetailRow(
                      'Volumen de taza',
                      calibration.cupVolume.toString(),
                    ),
                    _DetailRow(
                      'Volumen final',
                      calibration.finalVolume.toString(),
                    ),
                    _DetailRow(
                      'Fecha',
                      _dateFormat.format(calibration.calibrationDate),
                    ),
                    if (calibration.comments != null &&
                        calibration.comments!.trim().isNotEmpty)
                      _DetailRow('Comentarios', calibration.comments!),
                    if (calibration.notes != null &&
                        calibration.notes!.trim().isNotEmpty)
                      _DetailRow('Notas', calibration.notes!),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CostManagementColors.headerGreen,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Uint8List? _decodeBase64Image(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    try {
      final data = source.contains(',') ? source.split(',').last : source;
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

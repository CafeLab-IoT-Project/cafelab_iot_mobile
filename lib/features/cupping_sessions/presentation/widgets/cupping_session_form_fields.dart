import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:flutter/material.dart';

class CuppingSessionFormFields extends StatelessWidget {
  const CuppingSessionFormFields({
    super.key,
    required this.nameController,
    required this.originController,
    required this.varietyController,
    required this.notesController,
    required this.selectedProcessing,
    required this.selectedDate,
    required this.onProcessingChanged,
    required this.onPickDate,
    required this.fieldErrors,
    this.enabled = true,
  });

  final TextEditingController nameController;
  final TextEditingController originController;
  final TextEditingController varietyController;
  final TextEditingController notesController;
  final String selectedProcessing;
  final DateTime? selectedDate;
  final ValueChanged<String?> onProcessingChanged;
  final Future<void> Function() onPickDate;
  final Map<String, String> fieldErrors;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final processingItems = <String>{
      ...cuppingProcessingOptions,
      if (selectedProcessing.trim().isNotEmpty) selectedProcessing,
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          label: 'Nombre de la sesión',
          controller: nameController,
          errorText: fieldErrors['name'],
          enabled: enabled,
          hintText: 'Ingrese el nombre de la sesión',
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Origen',
          controller: originController,
          errorText: fieldErrors['origin'],
          enabled: enabled,
          hintText: 'Origen',
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'Variedad',
          controller: varietyController,
          errorText: fieldErrors['variety'],
          enabled: enabled,
          hintText: 'Variedad',
        ),
        const SizedBox(height: 14),
        CuppingFieldLabel('Procesamiento'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedProcessing,
          items: processingItems
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: enabled ? onProcessingChanged : null,
          decoration: cuppingInputDecoration(
            hintText: 'Procesamiento',
            errorText: fieldErrors['processing'],
          ),
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        const SizedBox(height: 14),
        CuppingFieldLabel('Fecha de la sesión'),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onPickDate : null,
          borderRadius: BorderRadius.circular(18),
          child: InputDecorator(
            decoration: cuppingInputDecoration(
              hintText: 'Fecha de la sesión',
              errorText: fieldErrors['sessionDate'],
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            child: Text(
              selectedDate == null
                  ? 'Fecha de la sesión'
                  : formatSessionFormDate(selectedDate!),
              style: TextStyle(
                color: selectedDate == null
                    ? const Color(0xFF9A958F)
                    : Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        CuppingFieldLabel('Notas de tueste / proceso'),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          enabled: enabled,
          minLines: 4,
          maxLines: 4,
          decoration: cuppingInputDecoration(
            hintText: 'Notas de tueste / proceso (opcional)',
            errorText: fieldErrors['roastStyleNotes'],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuppingFieldLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: cuppingInputDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

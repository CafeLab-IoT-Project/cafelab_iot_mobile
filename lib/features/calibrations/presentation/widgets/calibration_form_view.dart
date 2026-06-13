import 'dart:convert';

import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/constants/calibration_options.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CalibrationFormView extends StatefulWidget {
  const CalibrationFormView({
    super.key,
    required this.isEdit,
    this.initial,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
  });

  final bool isEdit;
  final GrindCalibration? initial;
  final bool isSubmitting;
  final Future<void> Function(
    CreateGrindCalibrationRequest? create,
    UpdateGrindCalibrationRequest? update,
  ) onSubmit;
  final VoidCallback onCancel;

  @override
  State<CalibrationFormView> createState() => _CalibrationFormViewState();
}

class _CalibrationFormViewState extends State<CalibrationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _method;
  String? _equipment;
  String? _grindNumber;
  double? _aperture;
  double? _cupVolume;
  double? _finalVolume;
  DateTime? _calibrationDate;
  String? _sampleImage;
  String? _sampleImageName;
  String? _imageError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nameCtrl.text = initial.name;
      _method = initial.method;
      _equipment = initial.equipment;
      _grindNumber = initial.grindNumber;
      _aperture = initial.aperture;
      _cupVolume = initial.cupVolume;
      _finalVolume = initial.finalVolume;
      _calibrationDate = initial.calibrationDate;
      _commentsCtrl.text = initial.comments ?? '';
      _notesCtrl.text = initial.notes ?? '';
      _sampleImage = initial.sampleImage;
      if (_sampleImage != null && _sampleImage!.isNotEmpty) {
        _sampleImageName = 'Imagen adjunta';
      }
    } else {
      _aperture = CalibrationOptions.apertures.first;
      _cupVolume = CalibrationOptions.cupVolumes.first;
      _finalVolume = CalibrationOptions.finalVolumes.first;
      _calibrationDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commentsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 70,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (bytes.length > CalibrationOptions.maxSampleImageBytes) {
      setState(() {
        _imageError =
            'La imagen no debe superar ${CalibrationOptions.maxSampleImageBytes ~/ 1024} KB.';
      });
      return;
    }

    final mime = file.mimeType ?? 'image/jpeg';
    setState(() {
      _sampleImage = 'data:$mime;base64,${base64Encode(bytes)}';
      _sampleImageName = file.name;
      _imageError = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_method == null ||
        _equipment == null ||
        _grindNumber == null ||
        _aperture == null ||
        _cupVolume == null ||
        _finalVolume == null ||
        _calibrationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos obligatorios.')),
      );
      return;
    }

    final comments = _commentsCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    if (widget.isEdit) {
      await widget.onSubmit(
        null,
        UpdateGrindCalibrationRequest(
          name: _nameCtrl.text.trim(),
          method: _method!,
          equipment: _equipment!,
          grindNumber: _grindNumber!,
          aperture: _aperture!,
          cupVolume: _cupVolume!,
          finalVolume: _finalVolume!,
          calibrationDate: _calibrationDate!,
          comments: comments.isEmpty ? null : comments,
          notes: notes.isEmpty ? null : notes,
          sampleImage: _sampleImage,
        ),
      );
      return;
    }

    await widget.onSubmit(
      CreateGrindCalibrationRequest(
        name: _nameCtrl.text.trim(),
        method: _method!,
        equipment: _equipment!,
        grindNumber: _grindNumber!,
        aperture: _aperture!,
        cupVolume: _cupVolume!,
        finalVolume: _finalVolume!,
        calibrationDate: _calibrationDate!,
        comments: comments.isEmpty ? null : comments,
        notes: notes.isEmpty ? null : notes,
        sampleImage: _sampleImage,
      ),
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _calibrationDate != null
        ? DateFormat('yyyy-MM-dd').format(_calibrationDate!)
        : 'Seleccionar fecha';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isEdit ? 'Editar calibración' : 'Registrar calibración',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _FormCard(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nombre requerido' : null,
                ),
                const SizedBox(height: 12),
                _DropdownField<String>(
                  label: 'Método *',
                  value: _method,
                  items: CalibrationOptions.methods,
                  itemLabel: (v) => v,
                  onChanged: (v) => setState(() => _method = v),
                ),
                const SizedBox(height: 12),
                _DropdownField<String>(
                  label: 'Equipo *',
                  value: _equipment,
                  items: CalibrationOptions.equipment,
                  itemLabel: (v) => v,
                  onChanged: (v) => setState(() => _equipment = v),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: widget.isSubmitting ? null : _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Adjuntar muestra visual'),
                ),
                if (_sampleImageName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _sampleImageName!,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ),
                if (_imageError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _imageError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            child: Column(
              children: [
                _DropdownField<String>(
                  label: 'Molienda *',
                  value: _grindNumber,
                  items: CalibrationOptions.grindNumbers,
                  itemLabel: (v) => v,
                  onChanged: (v) => setState(() => _grindNumber = v),
                ),
                const SizedBox(height: 12),
                _DropdownField<double>(
                  label: 'Apertura *',
                  value: _aperture,
                  items: CalibrationOptions.apertures,
                  itemLabel: (v) => v.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _aperture = v),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: widget.isSubmitting
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _calibrationDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _calibrationDate = picked);
                          }
                        },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de calibración *',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(dateLabel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            child: Column(
              children: [
                _DropdownField<double>(
                  label: 'Volumen de taza *',
                  value: _cupVolume,
                  items: CalibrationOptions.cupVolumes,
                  itemLabel: (v) => v.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _cupVolume = v),
                ),
                const SizedBox(height: 12),
                _DropdownField<double>(
                  label: 'Volumen final *',
                  value: _finalVolume,
                  items: CalibrationOptions.finalVolumes,
                  itemLabel: (v) => v.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _finalVolume = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentsCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comentarios',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: CostManagementColors.headerGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.isEdit ? 'Actualizar' : 'Registrar calibración'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.isSubmitting ? null : widget.onCancel,
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: (v) => v == null ? '$label es obligatorio' : null,
      builder: (field) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: field.errorText,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            hint: const Text('Seleccionar'),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(itemLabel(item)),
                  ),
                )
                .toList(),
            onChanged: (selected) {
              onChanged(selected);
              field.didChange(selected);
            },
          ),
        ),
      ),
    );
  }
}

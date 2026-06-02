import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/update_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:flutter/material.dart';

class RoastProfileFormDialog extends StatefulWidget {
  const RoastProfileFormDialog({
    super.key,
    required this.coffeeLots,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.profile,
  });

  final RoastProfile? profile;
  final List<CoffeeLot> coffeeLots;
  final String title;
  final String submitLabel;
  final Future<String?> Function(RoastProfileFormValue value) onSubmit;

  @override
  State<RoastProfileFormDialog> createState() => _RoastProfileFormDialogState();
}

class _RoastProfileFormDialogState extends State<RoastProfileFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _tempStartController;
  late final TextEditingController _tempEndController;
  int? _selectedLotId;
  String? _selectedType;
  final Map<String, String> _fieldErrors = <String, String>{};
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _selectedType = resolveDropdownValue(
      currentValue: profile?.type,
      allowedValues: roastProfileTypeOptions,
    );
    _durationController = TextEditingController(
      text: profile?.duration.toString() ?? '',
    );
    _tempStartController = TextEditingController(
      text: profile == null ? '' : formatTemperature(profile.tempStart),
    );
    _tempEndController = TextEditingController(
      text: profile == null ? '' : formatTemperature(profile.tempEnd),
    );
    _selectedLotId = profile?.coffeeLotId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _tempStartController.dispose();
    _tempEndController.dispose();
    super.dispose();
  }

  RoastProfileFormValue? _validateForm() {
    _fieldErrors.clear();

    final duration = int.tryParse(_durationController.text.trim());
    final tempStart = double.tryParse(_tempStartController.text.trim());
    final tempEnd = double.tryParse(_tempEndController.text.trim());

    if (_nameController.text.trim().isEmpty) {
      _fieldErrors['name'] = 'Ingresa el nombre del perfil.';
    }
    if (_selectedType == null || _selectedType!.isEmpty) {
      _fieldErrors['type'] = 'Selecciona el tipo de cafe.';
    }
    if (duration == null || duration < 1 || duration > 1440) {
      _fieldErrors['duration'] =
          'La duracion debe ser un entero entre 1 y 1440.';
    }
    if (tempStart == null || tempStart < 0 || tempStart > 300) {
      _fieldErrors['tempStart'] =
          'La temperatura inicial debe estar entre 0 y 300.';
    }
    if (tempEnd == null || tempEnd < 0 || tempEnd > 300) {
      _fieldErrors['tempEnd'] =
          'La temperatura final debe estar entre 0 y 300.';
    }
    if (_selectedLotId == null || _selectedLotId! <= 0) {
      _fieldErrors['lot'] = 'Selecciona un lote vinculado.';
    }

    if (_fieldErrors.isNotEmpty ||
        duration == null ||
        tempStart == null ||
        tempEnd == null) {
      return null;
    }

    return RoastProfileFormValue(
      name: _nameController.text.trim(),
      type: _selectedType!,
      duration: duration,
      tempStart: tempStart,
      tempEnd: tempEnd,
      lotId: _selectedLotId!,
      isFavorite: widget.profile?.isFavorite ?? false,
    );
  }

  Future<void> _submit() async {
    final value = _validateForm();
    if (value == null) {
      setState(() {
        _submitError = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final errorMessage = await widget.onSubmit(value);
    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSubmitting = false;
      _submitError = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4234),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Informacion del perfil',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _RoastProfileInputField(
                  label: 'Nombre de perfil',
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  errorText: _fieldErrors['name'],
                ),
                const SizedBox(height: 14),
                _RoastProfileSelectField(
                  label: 'Tipo de cafe',
                  value: _selectedType,
                  options: roastProfileTypeOptions,
                  enabled: !_isSubmitting,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  errorText: _fieldErrors['type'],
                ),
                const SizedBox(height: 14),
                _RoastProfileInputField(
                  label: 'Duracion total del tueste (min)',
                  controller: _durationController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  errorText: _fieldErrors['duration'],
                ),
                const SizedBox(height: 14),
                _RoastProfileInputField(
                  label: 'Temperatura inicial del grano (°C)',
                  controller: _tempStartController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _fieldErrors['tempStart'],
                ),
                const SizedBox(height: 14),
                _RoastProfileInputField(
                  label: 'Temperatura final deseada del grano (°C)',
                  controller: _tempEndController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _fieldErrors['tempEnd'],
                ),
                const SizedBox(height: 14),
                _RoastProfileLotField(
                  label: 'Lote vinculado',
                  lots: widget.coffeeLots,
                  value: _selectedLotId,
                  enabled: !_isSubmitting,
                  onChanged: (value) {
                    setState(() {
                      _selectedLotId = value;
                    });
                  },
                  errorText: _fieldErrors['lot'],
                ),
                if (_submitError != null) ...[
                  const SizedBox(height: 14),
                  MessageBanner(
                    message: _submitError!,
                    backgroundColor: const Color(0xFFF8D9D9),
                    foregroundColor: const Color(0xFF8C1D1D),
                  ),
                ],
                const SizedBox(height: 22),
                AuthPrimaryButton(
                  label: widget.submitLabel,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoastProfileFormValue {
  const RoastProfileFormValue({
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.lotId,
    required this.isFavorite,
  });

  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int lotId;
  final bool isFavorite;

  CreateRoastProfileInput toCreateInput() {
    return CreateRoastProfileInput(
      name: name,
      type: type,
      duration: duration,
      tempStart: tempStart,
      tempEnd: tempEnd,
      lot: lotId,
      isFavorite: isFavorite,
    );
  }

  UpdateRoastProfileInput toUpdateInput() {
    return UpdateRoastProfileInput(
      name: name,
      type: type,
      duration: duration,
      tempStart: tempStart,
      tempEnd: tempEnd,
      lot: lotId,
      isFavorite: isFavorite,
    );
  }
}

class _RoastProfileLotField extends StatelessWidget {
  const _RoastProfileLotField({
    required this.label,
    required this.lots,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final List<CoffeeLot> lots;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: value,
          items: lots
              .map(
                (lot) => DropdownMenuItem<int>(
                  value: lot.id,
                  child: Text(
                    lot.lotName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: roundedFieldDecoration(label),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _RoastProfileSelectField extends StatelessWidget {
  const _RoastProfileSelectField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: roundedFieldDecoration(label),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _RoastProfileInputField extends StatelessWidget {
  const _RoastProfileInputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        _RoastProfileRoundedField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          hintText: label,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _RoastProfileRoundedField extends StatelessWidget {
  const _RoastProfileRoundedField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: roundedFieldDecoration(hintText),
    );
  }
}

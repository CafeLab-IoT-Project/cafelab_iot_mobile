import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/models/cupping_sessions_view_models.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:flutter/material.dart';

Future<CuppingSessionsFilter?> showCuppingSessionsFilterSheet({
  required BuildContext context,
  required CuppingSessionsFilter initialFilter,
  required List<String> origins,
  required List<String> varieties,
  required List<String> processingOptions,
}) {
  return showModalBottomSheet<CuppingSessionsFilter>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => CuppingSessionsFilterSheet(
      initialFilter: initialFilter,
      origins: origins,
      varieties: varieties,
      processingOptions: processingOptions,
    ),
  );
}

class CuppingSessionsFilterSheet extends StatefulWidget {
  const CuppingSessionsFilterSheet({
    super.key,
    required this.initialFilter,
    required this.origins,
    required this.varieties,
    required this.processingOptions,
  });

  final CuppingSessionsFilter initialFilter;
  final List<String> origins;
  final List<String> varieties;
  final List<String> processingOptions;

  @override
  State<CuppingSessionsFilterSheet> createState() =>
      _CuppingSessionsFilterSheetState();
}

class _CuppingSessionsFilterSheetState extends State<CuppingSessionsFilterSheet> {
  late String? _origin;
  late String? _variety;
  late String? _processing;
  late DateTime? _date;

  @override
  void initState() {
    super.initState();
    _origin = widget.initialFilter.origin;
    _variety = widget.initialFilter.variety;
    _processing = widget.initialFilter.processing;
    _date = widget.initialFilter.sessionDate;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar sesiones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E4234),
                  ),
                ),
                const SizedBox(height: 18),
                _DropdownField(
                  label: 'Origen',
                  value: _origin,
                  hintText: 'Cualquiera',
                  items: widget.origins,
                  onChanged: (value) => setState(() => _origin = value),
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Variedad',
                  value: _variety,
                  hintText: 'Cualquiera',
                  items: widget.varieties,
                  onChanged: (value) => setState(() => _variety = value),
                ),
                const SizedBox(height: 14),
                _DateField(
                  label: 'Fecha',
                  value: _date,
                  onTap: _pickDate,
                  onClear:
                      _date == null ? null : () => setState(() => _date = null),
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Procesamiento',
                  value: _processing,
                  hintText: 'Cualquiera',
                  items: widget.processingOptions,
                  onChanged: (value) => setState(() => _processing = value),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: secondaryPillButtonStyle(),
                        onPressed: () => Navigator.of(context).pop(
                          CuppingSessionsFilter.empty,
                        ),
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthPrimaryButton(
                        label: 'Aplicar filtros',
                        onPressed: () {
                          Navigator.of(context).pop(
                            CuppingSessionsFilter(
                              origin: _origin,
                              variety: _variety,
                              processing: _processing,
                              sessionDate: _date,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuppingFieldLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: value,
          decoration: cuppingInputDecoration(hintText: hintText),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(hintText, overflow: TextOverflow.ellipsis),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String?>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuppingFieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: InputDecorator(
            decoration: cuppingInputDecoration(
              hintText: 'Fecha',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onClear != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.calendar_today_outlined),
                  ),
                ],
              ),
            ),
            child: Text(
              value == null ? 'Fecha' : formatSessionFormDate(value!),
              style: TextStyle(
                color: value == null ? const Color(0xFF9A958F) : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

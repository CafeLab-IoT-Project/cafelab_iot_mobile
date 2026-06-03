import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const List<String> cuppingProcessingOptions = <String>[
  'Lavado',
  'Natural',
  'Honey',
  'Fermentación anaeróbica',
  'Maceración carbónica',
];

String formatSessionTableDate(DateTime date) {
  return DateFormat('MMM d, y').format(date);
}

String formatSessionFormDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String buildSessionOptionLabel(CuppingSession session) {
  return '${session.name} - ${cuppingSessionDateToWire(session.sessionDate)}';
}

InputDecoration cuppingInputDecoration({
  required String hintText,
  String? errorText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    errorText: errorText,
    hintStyle: const TextStyle(color: Color(0xFF9A958F)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD7D1C9)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD7D1C9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AuthColors.primary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFB3261E)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.4),
    ),
  );
}

ButtonStyle secondaryPillButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: AuthColors.primary,
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFFB8B4AC)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: const StadiumBorder(),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );
}

class CuppingSectionCard extends StatelessWidget {
  const CuppingSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class CuppingFieldLabel extends StatelessWidget {
  const CuppingFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E2E),
      ),
    );
  }
}

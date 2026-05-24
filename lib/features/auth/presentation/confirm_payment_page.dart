import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/plan_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PaymentMethod { visa, mastercard }

/// Pantalla reservada para confirmar el pago del plan seleccionado.
class ConfirmPaymentPage extends StatefulWidget {
  const ConfirmPaymentPage({
    super.key,
    required this.selectedPlan,
  });

  final SubscriptionPlan selectedPlan;

  @override
  State<ConfirmPaymentPage> createState() => _ConfirmPaymentPageState();
}

class _ConfirmPaymentPageState extends State<ConfirmPaymentPage> {
  PaymentMethod? _selectedMethod;
  String _country = 'Perú';

  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardholderController = TextEditingController();

  static const _countries = ['Perú', 'México', 'Colombia', 'Chile', 'Ecuador'];

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenBackground(
        backgroundAsset: AuthAssets.selectPlansBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AuthPillButton(
                          label: 'Volver a planes',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PlanSummaryCard(plan: widget.selectedPlan),
                              const SizedBox(height: 16),
                              _PaymentFormCard(
                                selectedMethod: _selectedMethod,
                                onMethodChanged: (method) {
                                  setState(() {
                                    _selectedMethod = method;
                                  });
                                },
                                emailController: _emailController,
                                cardNumberController: _cardNumberController,
                                expiryController: _expiryController,
                                cvcController: _cvcController,
                                cardholderController: _cardholderController,
                                country: _country,
                                countries: _countries,
                                onCountryChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _country = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthPrimaryButton(
                        label: 'Confirmar pago',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentFormCard extends StatelessWidget {
  const _PaymentFormCard({
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.emailController,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvcController,
    required this.cardholderController,
    required this.country,
    required this.countries,
    required this.onCountryChanged,
  });

  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onMethodChanged;
  final TextEditingController emailController;
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvcController;
  final TextEditingController cardholderController;
  final String country;
  final List<String> countries;
  final ValueChanged<String?> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _PaymentMethodOption(
                label: 'VISA',
                labelColor: const Color(0xFF1A1F71),
                isSelected: selectedMethod == PaymentMethod.visa,
                onTap: () => onMethodChanged(PaymentMethod.visa),
              ),
              const SizedBox(width: 24),
              _PaymentMethodOption(
                label: 'Mastercard',
                labelColor: const Color(0xFFEB001B),
                isSelected: selectedMethod == PaymentMethod.mastercard,
                onTap: () => onMethodChanged(PaymentMethod.mastercard),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _PaymentField(
            label: 'Email',
            controller: emailController,
            hintText: 'correo@ejemplo.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const _PaymentFieldLabel(text: 'Información de tarjeta'),
          const SizedBox(height: 8),
          _PaymentField(
            controller: cardNumberController,
            hintText: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PaymentField(
                  controller: expiryController,
                  hintText: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PaymentField(
                  controller: cvcController,
                  hintText: 'CVC',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PaymentField(
            label: 'Nombre del titular',
            controller: cardholderController,
            hintText: 'Nombre completo',
          ),
          const SizedBox(height: 16),
          const _PaymentFieldLabel(text: 'País'),
          const SizedBox(height: 8),
          _PaymentDropdown(
            value: country,
            items: countries,
            onChanged: onCountryChanged,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.label,
    required this.labelColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color labelColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: AuthColors.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w700,
              fontSize: label == 'VISA' ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentFieldLabel extends StatelessWidget {
  const _PaymentFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  const _PaymentField({
    this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
  });

  final String? label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          _PaymentFieldLabel(text: label!),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          decoration: _paymentInputDecoration(hintText),
        ),
      ],
    );
  }
}

class _PaymentDropdown extends StatelessWidget {
  const _PaymentDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: _paymentInputDecoration(value),
      icon: const Icon(Icons.keyboard_arrow_down),
      style: const TextStyle(color: Colors.black87, fontSize: 15),
    );
  }
}

InputDecoration _paymentInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.black.withValues(alpha: 0.4),
      fontSize: 14,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AuthColors.primary, width: 1.5),
    ),
  );
}

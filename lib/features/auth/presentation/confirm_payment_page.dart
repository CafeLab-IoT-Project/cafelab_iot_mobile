import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/payment_validators.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/profile_flow_navigation.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_api_error_banner.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/plan_summary_card.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_onboarding_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PaymentMethod { visa, mastercard }

/// Confirmación de pago (solo validación visual; actualiza `hasPlan` en backend).
class ConfirmPaymentPage extends StatefulWidget {
  const ConfirmPaymentPage({
    super.key,
    required this.selectedPlan,
    required this.userRole,
    this.flowMode = PlanFlowMode.initialOnboarding,
  });

  final SubscriptionPlan selectedPlan;
  final AuthUserRole userRole;
  final PlanFlowMode flowMode;

  bool get _isChangePlan => flowMode == PlanFlowMode.changePlan;

  @override
  State<ConfirmPaymentPage> createState() => _ConfirmPaymentPageState();
}

class _ConfirmPaymentPageState extends State<ConfirmPaymentPage> {
  final _onboardingService = ProfileOnboardingService();

  PaymentMethod? _selectedMethod;
  String _country = 'Perú';
  ProfileModel? _profile;

  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardholderController = TextEditingController();

  bool _isLoadingProfile = true;
  bool _isSubmitting = false;
  bool _formSubmitted = false;
  String _apiError = '';
  Map<String, String> _fieldErrors = {};

  static const _countries = ['Perú', 'México', 'Colombia', 'Chile', 'Ecuador'];

  @override
  void initState() {
    super.initState();
    _loadProfileEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileEmail() async {
    try {
      final profile = await _onboardingService.fetchCurrentProfile();
      if (!mounted) return;
      _profile = profile;
      _emailController.text = profile.email;
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'No se pudo cargar el correo del perfil.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _confirmPayment() async {
    setState(() {
      _formSubmitted = true;
      _apiError = '';
    });

    final fieldErrors = PaymentValidators.validate(
      hasPaymentMethod: _selectedMethod != null,
      email: _emailController.text,
      cardNumber: _cardNumberController.text,
      expiry: _expiryController.text,
      cvc: _cvcController.text,
      cardholder: _cardholderController.text,
      country: _country,
    );

    if (fieldErrors.isNotEmpty) {
      setState(() {
        _fieldErrors = fieldErrors;
      });
      return;
    }

    final profile = _profile;
    if (profile == null) {
      setState(() {
        _apiError = 'Perfil no disponible. Vuelve a seleccionar un plan.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _fieldErrors = {};
    });

    final paymentMethod =
        _selectedMethod == PaymentMethod.visa ? 'visa' : 'mastercard';

    try {
      final updatedProfile = await _onboardingService.completePayment(
        profile: profile,
        paymentMethod: paymentMethod,
        planOverride: widget._isChangePlan
            ? widget.selectedPlan.apiPlanValue
            : null,
      );

      if (!mounted) return;

      ProfileFlowNavigation.navigateAfterPlanChangePayment(
        context,
        updatedProfile: updatedProfile,
        selectedPlanType: widget.selectedPlan.type,
      );
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'Error al confirmar el pago.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoadingProfile || _isSubmitting;

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
                          onPressed: isBusy
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _isLoadingProfile
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_apiError.isNotEmpty) ...[
                                      AuthApiErrorBanner(message: _apiError),
                                      const SizedBox(height: 12),
                                    ],
                                    PlanSummaryCard(plan: widget.selectedPlan),
                                    const SizedBox(height: 16),
                                    _PaymentFormCard(
                                      selectedMethod: _selectedMethod,
                                      onMethodChanged: (method) {
                                        setState(() {
                                          _selectedMethod = method;
                                          _fieldErrors = Map<String, String>.from(
                                            _fieldErrors,
                                          )..remove('paymentMethod');
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
                                          _fieldErrors = Map<String, String>.from(
                                            _fieldErrors,
                                          )..remove('country');
                                        });
                                      },
                                      fieldErrors: _fieldErrors,
                                      formSubmitted: _formSubmitted,
                                      enabled: !isBusy,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      AuthPrimaryButton(
                        label: 'Confirmar pago',
                        isLoading: _isSubmitting,
                        onPressed: isBusy ? null : _confirmPayment,
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
    required this.fieldErrors,
    required this.formSubmitted,
    required this.enabled,
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
  final Map<String, String> fieldErrors;
  final bool formSubmitted;
  final bool enabled;

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
                onTap: enabled ? () => onMethodChanged(PaymentMethod.visa) : null,
              ),
              const SizedBox(width: 24),
              _PaymentMethodOption(
                label: 'Mastercard',
                labelColor: const Color(0xFFEB001B),
                isSelected: selectedMethod == PaymentMethod.mastercard,
                onTap: enabled
                    ? () => onMethodChanged(PaymentMethod.mastercard)
                    : null,
              ),
            ],
          ),
          if (fieldErrors['paymentMethod'] != null) ...[
            const SizedBox(height: 6),
            _FieldErrorText(fieldErrors['paymentMethod']!),
          ],
          const SizedBox(height: 20),
          _PaymentField(
            label: 'Email',
            controller: emailController,
            hintText: 'correo@ejemplo.com',
            keyboardType: TextInputType.emailAddress,
            enabled: enabled,
            errorText: fieldErrors['email'],
          ),
          const SizedBox(height: 16),
          const _PaymentFieldLabel(text: 'Información de tarjeta'),
          const SizedBox(height: 8),
          _PaymentField(
            controller: cardNumberController,
            hintText: '0000 0000 0000 0000',
            keyboardType: TextInputType.number,
            enabled: enabled,
            errorText: fieldErrors['cardNumber'],
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
                  enabled: enabled,
                  errorText: fieldErrors['expiry'],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(5),
                    _ExpiryInputFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PaymentField(
                  controller: cvcController,
                  hintText: 'CVC',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  enabled: enabled,
                  errorText: fieldErrors['cvc'],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
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
            enabled: enabled,
            errorText: fieldErrors['cardholder'],
          ),
          const SizedBox(height: 16),
          const _PaymentFieldLabel(text: 'País'),
          const SizedBox(height: 8),
          _PaymentDropdown(
            value: country,
            items: countries,
            onChanged: enabled ? onCountryChanged : null,
            errorText: fieldErrors['country'],
          ),
        ],
      ),
    );
  }
}

class _ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
  final VoidCallback? onTap;

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

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.red.shade700,
        fontSize: 12,
        fontWeight: FontWeight.w500,
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
    this.enabled = true,
    this.errorText,
  });

  final String? label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

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
          enabled: enabled,
          decoration: _paymentInputDecoration(hintText, hasError),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          _FieldErrorText(errorText!),
        ],
      ],
    );
  }
}

class _PaymentDropdown extends StatelessWidget {
  const _PaymentDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
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
          decoration: _paymentInputDecoration(value, hasError),
          icon: const Icon(Icons.keyboard_arrow_down),
          style: const TextStyle(color: Colors.black87, fontSize: 15),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          _FieldErrorText(errorText!),
        ],
      ],
    );
  }
}

InputDecoration _paymentInputDecoration(String hintText, bool hasError) {
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
      borderSide: BorderSide(
        color: hasError ? Colors.red.shade300 : Colors.grey.shade400,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hasError ? Colors.red.shade300 : Colors.grey.shade400,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hasError ? Colors.red.shade400 : AuthColors.primary,
        width: 1.5,
      ),
    ),
  );
}

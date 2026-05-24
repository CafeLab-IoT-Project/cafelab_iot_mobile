import 'package:cafelab_iot_mobile/features/auth/presentation/confirm_payment_onboarding_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/confirm_payment_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/subscription_plans.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/plan_display_labels.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_api_error_banner.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/plan_card.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_onboarding_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:flutter/material.dart';

/// Pantalla de selección de plan. Filtra planes según [userRole].
class SelectPlansPage extends StatefulWidget {
  const SelectPlansPage({
    super.key,
    required this.userRole,
    this.flowMode = PlanFlowMode.initialOnboarding,
  });

  final AuthUserRole userRole;
  final PlanFlowMode flowMode;

  bool get _isChangePlan => flowMode == PlanFlowMode.changePlan;

  bool get _isSessionFlow =>
      flowMode == PlanFlowMode.pendingPaymentResume ||
      flowMode == PlanFlowMode.changePlan;

  @override
  State<SelectPlansPage> createState() => _SelectPlansPageState();
}

class _SelectPlansPageState extends State<SelectPlansPage> {
  final _onboardingService = ProfileOnboardingService();
  bool _isAssigningPlan = false;
  String _apiError = '';

  Future<void> _onPlanSelected(SubscriptionPlan plan) async {
    if (widget._isChangePlan) {
      setState(() {
        _isAssigningPlan = true;
        _apiError = '';
      });

      try {
        final profile = await _onboardingService.fetchCurrentProfile();
        if (!mounted) return;

        if (PlanDisplayLabels.typeFromApi(profile.plan) == plan.type) {
          setState(() {
            _apiError =
                'El plan "${plan.title}" es tu plan actual. Elige otro para continuar.';
          });
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConfirmPaymentSessionPage(
              selectedPlan: plan,
              userRole: widget.userRole,
              flowMode: PlanFlowMode.changePlan,
            ),
          ),
        );
      } on ProfileApiException catch (e) {
        if (!mounted) return;
        setState(() {
          _apiError = e.displayMessage;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _apiError = 'No se pudo verificar tu plan actual.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isAssigningPlan = false;
          });
        }
      }
      return;
    }

    setState(() {
      _isAssigningPlan = true;
      _apiError = '';
    });

    try {
      final profile = await _onboardingService.fetchCurrentProfile();
      await _onboardingService.assignSelectedPlan(
        profile: profile,
        plan: plan.apiPlanValue,
      );

      if (!mounted) return;

      if (widget.userRole == AuthUserRole.barista &&
          plan.type == SubscriptionPlanType.full) {
        if (widget.flowMode == PlanFlowMode.initialOnboarding) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const EditProfilePage(
                userRole: AuthUserRole.barista,
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const EditProfileSessionPage(),
            ),
          );
        }
        return;
      }

      final paymentPage = widget._isSessionFlow
          ? ConfirmPaymentSessionPage(
              selectedPlan: plan,
              userRole: widget.userRole,
              flowMode: PlanFlowMode.pendingPaymentResume,
            )
          : ConfirmPaymentOnboardingPage(
              selectedPlan: plan,
              userRole: widget.userRole,
            );

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => paymentPage),
      );
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'No se pudo guardar el plan seleccionado.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAssigningPlan = false;
        });
      }
    }
  }

  void _goBack() {
    switch (widget.flowMode) {
      case PlanFlowMode.initialOnboarding:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => EditProfilePage(userRole: widget.userRole),
          ),
        );
      case PlanFlowMode.pendingPaymentResume:
      case PlanFlowMode.changePlan:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const EditProfileSessionPage(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visiblePlans = SubscriptionPlans.forRole(widget.userRole);

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
                          label: 'Volver a Editar Perfil',
                          onPressed: _isAssigningPlan ? null : _goBack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _PlansTitleCard(),
                      if (_apiError.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        AuthApiErrorBanner(message: _apiError),
                      ],
                      if (_isAssigningPlan)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(),
                        ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: visiblePlans.length,
                          itemBuilder: (context, index) {
                            final plan = visiblePlans[index];
                            return PlanCard(
                              plan: plan,
                              onStartPlan: _isAssigningPlan
                                  ? () {}
                                  : () => _onPlanSelected(plan),
                            );
                          },
                        ),
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

class _PlansTitleCard extends StatelessWidget {
  const _PlansTitleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Planes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Elija el plan que desee usar en la aplicación.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.75),
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

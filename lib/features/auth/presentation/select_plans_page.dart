import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/confirm_payment_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/subscription_plans.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/plan_card.dart';
import 'package:flutter/material.dart';

/// Pantalla de selección de plan. Filtra planes según [userRole].
class SelectPlansPage extends StatelessWidget {
  const SelectPlansPage({
    super.key,
    required this.userRole,
  });

  final AuthUserRole userRole;

  @override
  Widget build(BuildContext context) {
    final visiblePlans = SubscriptionPlans.forRole(userRole);

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
                        child: const _BackToProfileButton(),
                      ),
                      const SizedBox(height: 12),
                      _PlansTitleCard(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: visiblePlans.length,
                          itemBuilder: (context, index) {
                            final plan = visiblePlans[index];
                            return PlanCard(
                              plan: plan,
                              onStartPlan: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ConfirmPaymentPage(
                                      selectedPlan: plan,
                                    ),
                                  ),
                                );
                              },
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

class _BackToProfileButton extends StatelessWidget {
  const _BackToProfileButton();

  @override
  Widget build(BuildContext context) {
    return AuthPillButton(
      label: 'Volver a Editar Perfil',
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

class _PlansTitleCard extends StatelessWidget {
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

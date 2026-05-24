enum PlanFlowMode {
  /// Primer registro: al elegir plan se persiste en backend con hasPlan false.
  initialOnboarding,

  /// Usuario con sesión que aún no confirmó el pago del plan.
  pendingPaymentResume,

  /// Cambio de plan desde editar perfil con sesión.
  changePlan,
}

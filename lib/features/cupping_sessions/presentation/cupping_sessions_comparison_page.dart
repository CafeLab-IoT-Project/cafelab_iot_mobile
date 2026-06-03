import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/sensory_scores.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/sensory_hexagon_chart.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:flutter/material.dart';

class CuppingSessionsComparisonPage extends StatefulWidget {
  const CuppingSessionsComparisonPage({
    super.key,
    required this.sessions,
    required this.planType,
    this.initialLeft,
    this.initialRight,
  });

  final List<CuppingSession> sessions;
  final SubscriptionPlanType planType;
  final CuppingSession? initialLeft;
  final CuppingSession? initialRight;

  @override
  State<CuppingSessionsComparisonPage> createState() =>
      _CuppingSessionsComparisonPageState();
}

class _CuppingSessionsComparisonPageState
    extends State<CuppingSessionsComparisonPage> {
  late int _leftId;
  late int _rightId;

  List<CuppingSession> get _sortedSessions {
    final sessions = [...widget.sessions]
      ..sort((left, right) => left.name.toLowerCase().compareTo(right.name.toLowerCase()));
    return sessions;
  }

  CuppingSession get _leftSession =>
      _sortedSessions.firstWhere((item) => item.id == _leftId);
  CuppingSession get _rightSession =>
      _sortedSessions.firstWhere((item) => item.id == _rightId);

  @override
  void initState() {
    super.initState();
    final sessions = _sortedSessions;
    final left = widget.initialLeft ?? sessions.first;
    final fallbackRight = sessions.firstWhere(
      (item) => item.id != left.id,
      orElse: () => sessions.last,
    );
    final right = widget.initialRight == null || widget.initialRight!.id == left.id
        ? fallbackRight
        : widget.initialRight!;

    _leftId = left.id;
    _rightId = right.id;
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sortedSessions;
    if (sessions.length < 2) {
      return AuthenticatedScaffold(
        onFeatures: _goBack,
        body: ColoredBox(
          color: AuthColors.profileScreenBackground,
          child: const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: EmptyStateCard(
                title: 'No hay suficientes sesiones',
                message: 'Necesitas al menos dos sesiones para compararlas.',
              ),
            ),
          ),
        ),
      );
    }

    final leftScores = SensoryScores.fromResultsJson(_leftSession.resultsJson);
    final rightScores = SensoryScores.fromResultsJson(_rightSession.resultsJson);

    return AuthenticatedScaffold(
      onFeatures: _goBack,
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inicio > Sesiones de cata > Comparar sesiones',
                  style: const TextStyle(
                    color: Color(0xFF4E5342),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    style: secondaryPillButtonStyle(),
                    onPressed: _goBack,
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Comparar dos sesiones',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF314131),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;
                    final selectors = [
                      _SessionSelector(
                        label: 'Sesión A',
                        value: _leftId,
                        sessions: sessions,
                        onChanged: (value) {
                          if (value == null || value == _rightId) return;
                          setState(() => _leftId = value);
                        },
                      ),
                      _SessionSelector(
                        label: 'Sesión B',
                        value: _rightId,
                        sessions: sessions,
                        onChanged: (value) {
                          if (value == null || value == _leftId) return;
                          setState(() => _rightId = value);
                        },
                      ),
                    ];

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: selectors[0]),
                          const SizedBox(width: 14),
                          Expanded(child: selectors[1]),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        selectors[0],
                        const SizedBox(height: 12),
                        selectors[1],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hexágono sensorial (comparación visual)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E4234),
                  ),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;
                    final charts = [
                      _ComparisonChartCard(
                        title: _leftSession.name,
                        scores: leftScores,
                        fillColor: const Color(0x667B8F8B),
                        strokeColor: const Color(0xFF4D6058),
                      ),
                      _ComparisonChartCard(
                        title: _rightSession.name,
                        scores: rightScores,
                        fillColor: const Color(0x66D1B086),
                        strokeColor: const Color(0xFF9A6840),
                      ),
                    ];

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: charts[0]),
                          const SizedBox(width: 20),
                          Expanded(child: charts[1]),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        charts[0],
                        const SizedBox(height: 16),
                        charts[1],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _ComparisonTable(
                  leftTitle: 'Sesión A',
                  rightTitle: 'Sesión B',
                  leftScores: leftScores,
                  rightScores: rightScores,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionSelector extends StatelessWidget {
  const _SessionSelector({
    required this.label,
    required this.value,
    required this.sessions,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<CuppingSession> sessions;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF66675F),
            ),
          ),
        ),
        DropdownButtonFormField<int>(
          initialValue: value,
          decoration: cuppingInputDecoration(hintText: label),
          items: sessions
              .map(
                (session) => DropdownMenuItem<int>(
                  value: session.id,
                  child: Text(
                    buildSessionOptionLabel(session),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}

class _ComparisonChartCard extends StatelessWidget {
  const _ComparisonChartCard({
    required this.title,
    required this.scores,
    required this.fillColor,
    required this.strokeColor,
  });

  final String title;
  final SensoryScores scores;
  final Color fillColor;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return CuppingSectionCard(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3E4234),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 280,
            child: SensoryHexagonChart(
              scores: scores,
              fillColor: fillColor,
              strokeColor: strokeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.leftTitle,
    required this.rightTitle,
    required this.leftScores,
    required this.rightScores,
  });

  final String leftTitle;
  final String rightTitle;
  final SensoryScores leftScores;
  final SensoryScores rightScores;

  @override
  Widget build(BuildContext context) {
    final rows = <_AttributeRow>[
      _AttributeRow('Aroma', leftScores.aroma, rightScores.aroma),
      _AttributeRow('Cuerpo', leftScores.cuerpo, rightScores.cuerpo),
      _AttributeRow('Acidez', leftScores.acidez, rightScores.acidez),
      _AttributeRow('Dulzor', leftScores.dulzor, rightScores.dulzor),
      _AttributeRow('Amargor', leftScores.amargor, rightScores.amargor),
      _AttributeRow('Postgusto', leftScores.postgusto, rightScores.postgusto),
    ];

    return CuppingSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: const BoxDecoration(
              color: AuthColors.header,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Atributo',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    leftTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    rightTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map(
            (row) => Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFD8D4CD)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        color: Color(0xFF3E4234),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.left.toStringAsFixed(0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.right.toStringAsFixed(0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeRow {
  const _AttributeRow(this.label, this.left, this.right);

  final String label;
  final double left;
  final double right;
}

import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/cost_management_controller.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/widgets/cost_record_annul_dialog.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/widgets/cost_record_detail_dialog.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/new_calculation/new_calculation_wizard.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/widgets/cost_record_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _CostManagementMode { list, wizard }

class CostManagementPage extends StatefulWidget {
  const CostManagementPage({
    super.key,
    required this.planType,
  });

  final SubscriptionPlanType planType;

  @override
  State<CostManagementPage> createState() => _CostManagementPageState();
}

class _CostManagementPageState extends State<CostManagementPage> {
  final _controller = CostManagementController();
  final _searchController = TextEditingController();
  _CostManagementMode _mode = _CostManagementMode.list;

  @override
  void initState() {
    super.initState();
    _controller.loadRecords();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDetail(ProductionCostRecord record) async {
    await showDialog<void>(
      context: context,
      builder: (_) => CostRecordDetailDialog(record: record),
    );
  }

  Future<void> _openAnnul(ProductionCostRecord record) async {
    if (record.isAnnulled) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => CostRecordAnnulDialog(record: record),
    );
    if (reason == null || !mounted) return;

    final ok = await _controller.annulRecord(record.id, reason);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro anulado correctamente.')),
      );
    }
  }

  void _onNewCalculation() {
    setState(() => _mode = _CostManagementMode.wizard);
  }

  void _backToList() {
    setState(() => _mode = _CostManagementMode.list);
    _controller.loadRecords();
  }

  void _goToDashboard() {
    Navigator.of(context).pop();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const EditProfileSessionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      onFeatures: _goToDashboard,
      onProfile: _openProfile,
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              if (_mode == _CostManagementMode.wizard) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _Breadcrumb(
                        onHome: _goToDashboard,
                        onBackToList: _backToList,
                        showNewCalculation: true,
                      ),
                    ),
                    Expanded(
                      child: NewCalculationWizard(
                        listController: _controller,
                        onBackToList: _backToList,
                        onGoHome: _goToDashboard,
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Breadcrumb(onHome: _goToDashboard),
                    const SizedBox(height: 16),
                    if (_controller.errorMessage != null)
                      _ErrorBanner(message: _controller.errorMessage!),
                    _SearchAndActionRow(
                      searchController: _searchController,
                      onSearchChanged: _controller.updateSearchQuery,
                      onNewCalculation: _onNewCalculation,
                    ),
                    const SizedBox(height: 12),
                    if (_controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      _CostRecordsTable(
                        records: _controller.filteredRecords,
                        onView: _openDetail,
                        onAnnul: _openAnnul,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.onHome,
    this.onBackToList,
    this.showNewCalculation = false,
  });

  final VoidCallback onHome;
  final VoidCallback? onBackToList;
  final bool showNewCalculation;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        GestureDetector(
          onTap: onHome,
          child: const Text(
            'Inicio',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.black87,
            ),
          ),
        ),
        const Text('>', style: TextStyle(color: Colors.black54)),
        if (showNewCalculation && onBackToList != null)
          GestureDetector(
            onTap: onBackToList,
            child: const Text(
              'Gestión de Costos',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black87,
              ),
            ),
          )
        else
          const Text(
            'Gestión de Costos',
            style: TextStyle(color: Colors.black87),
          ),
        if (showNewCalculation) ...[
          const Text('>', style: TextStyle(color: Colors.black54)),
          const Text(
            'Nuevo Cálculo',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(color: Color(0xFFC62828), width: 4),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFC62828)),
      ),
    );
  }
}

class _SearchAndActionRow extends StatelessWidget {
  const _SearchAndActionRow({
    required this.searchController,
    required this.onSearchChanged,
    required this.onNewCalculation,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNewCalculation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        final searchField = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade400),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre de lote...',
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: Colors.grey.shade600),
                onPressed: () => onSearchChanged(searchController.text),
              ),
            ),
            onSubmitted: onSearchChanged,
          ),
        );

        final newButton = FilledButton(
          onPressed: onNewCalculation,
          style: FilledButton.styleFrom(
            backgroundColor: CostManagementColors.headerGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Nuevo cálculo'),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 320, child: searchField),
              const Spacer(),
              newButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            searchField,
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: newButton),
          ],
        );
      },
    );
  }
}

class _CostRecordsTable extends StatefulWidget {
  const _CostRecordsTable({
    required this.records,
    required this.onView,
    required this.onAnnul,
  });

  final List<ProductionCostRecord> records;
  final ValueChanged<ProductionCostRecord> onView;
  final ValueChanged<ProductionCostRecord> onAnnul;

  static const _minTableWidth = 640.0;

  @override
  State<_CostRecordsTable> createState() => _CostRecordsTableState();
}

class _CostRecordsTableState extends State<_CostRecordsTable> {
  final _horizontalScrollController = ScrollController();

  static final _dateFormat = DateFormat('M/d/yy, h:mm a');

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  DataTable _buildDataTable() {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        CostManagementColors.headerGreen,
      ),
      headingTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      dataTextStyle: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 14,
      ),
      columnSpacing: 20,
      horizontalMargin: 16,
      columns: const [
        DataColumn(label: Text('Fecha')),
        DataColumn(label: Text('Nombre de lote')),
        DataColumn(label: Text('Monto')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Acciones')),
      ],
      rows: widget.records.map((record) {
        final textColor = record.isAnnulled
            ? CostManagementColors.annulledRowText
            : const Color(0xFF333333);

        return DataRow(
          color: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.grey.shade100;
            }
            return null;
          }),
          cells: [
            DataCell(
              Text(
                record.createdAt != null
                    ? _dateFormat.format(record.createdAt!)
                    : '—',
                style: TextStyle(color: textColor),
              ),
            ),
            DataCell(
              Text(
                record.lotName,
                style: TextStyle(color: textColor),
              ),
            ),
            DataCell(
              Text(
                '${record.currencySymbol} ${record.totalCost.toStringAsFixed(2)}',
                style: TextStyle(color: textColor),
              ),
            ),
            DataCell(
              CostRecordStatusBadge(status: record.status),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    tooltip: 'Ver detalle',
                    onPressed: () => widget.onView(record),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: record.isAnnulled
                          ? Colors.grey
                          : CostManagementColors.deleteRed,
                    ),
                    tooltip: record.isAnnulled
                        ? 'Registro ya anulado'
                        : 'Anular',
                    onPressed:
                        record.isAnnulled ? null : () => widget.onAnnul(record),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: widget.records.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No hay registros de costos.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final viewportWidth = constraints.maxWidth;
                  final contentWidth = _CostRecordsTable._minTableWidth;
                  final isHorizontallyScrollable =
                      viewportWidth < contentWidth;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: isHorizontallyScrollable
                                ? contentWidth
                                : viewportWidth,
                          ),
                          child: _buildDataTable(),
                        ),
                      ),
                      if (isHorizontallyScrollable)
                        _HorizontalScrollGuideBar(
                          scrollController: _horizontalScrollController,
                          viewportWidth: viewportWidth,
                          contentWidth: contentWidth,
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

/// Barra de guía sincronizada con el desplazamiento horizontal de la tabla.
class _HorizontalScrollGuideBar extends StatelessWidget {
  const _HorizontalScrollGuideBar({
    required this.scrollController,
    required this.viewportWidth,
    required this.contentWidth,
  });

  final ScrollController scrollController;
  final double viewportWidth;
  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scrollController,
      builder: (context, _) {
        // No leer position.maxScrollExtent: puede lanzar antes de tener dimensiones.
        final maxExtent =
            (contentWidth - viewportWidth).clamp(0.0, double.infinity);
        final offset = scrollController.hasClients
            ? scrollController.offset.clamp(0.0, maxExtent)
            : 0.0;

        final trackWidth = viewportWidth - 24;
        final thumbFraction =
            (viewportWidth / contentWidth).clamp(0.2, 1.0);
        final thumbWidth = trackWidth * thumbFraction;
        final travel = (trackWidth - thumbWidth).clamp(0.0, double.infinity);
        final thumbOffset =
            maxExtent > 0 ? (offset / maxExtent) * travel : 0.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: SizedBox(
            height: 6,
            width: trackWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: thumbOffset,
                  width: thumbWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

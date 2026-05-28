import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/grind_calibration_controller.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/widgets/calibration_detail_dialog.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/widgets/calibration_form_view.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:flutter/material.dart';

enum _GrindCalibrationMode { list, create, edit }

class GrindCalibrationPage extends StatefulWidget {
  const GrindCalibrationPage({super.key, required this.planType});

  final SubscriptionPlanType planType;

  @override
  State<GrindCalibrationPage> createState() => _GrindCalibrationPageState();
}

class _GrindCalibrationPageState extends State<GrindCalibrationPage> {
  final _controller = GrindCalibrationController();
  final _searchController = TextEditingController();

  _GrindCalibrationMode _mode = _GrindCalibrationMode.list;
  GrindCalibration? _editingCalibration;

  @override
  void initState() {
    super.initState();
    _controller.loadCalibrations();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _goToDashboard() => Navigator.of(context).pop();

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditProfileSessionPage()),
    );
  }

  void _backToList() {
    setState(() {
      _mode = _GrindCalibrationMode.list;
      _editingCalibration = null;
    });
    _controller.loadCalibrations();
  }

  void _openCreate() {
    setState(() {
      _mode = _GrindCalibrationMode.create;
      _editingCalibration = null;
    });
  }

  Future<void> _openEdit(GrindCalibration calibration) async {
    setState(() {
      _mode = _GrindCalibrationMode.edit;
      _editingCalibration = calibration;
    });
  }

  Future<void> _openDetail(GrindCalibration calibration) async {
    await showDialog<void>(
      context: context,
      builder: (_) => CalibrationDetailDialog(calibration: calibration),
    );
  }

  Future<void> _handleSubmit(
    CreateGrindCalibrationRequest? create,
    UpdateGrindCalibrationRequest? update,
  ) async {
    if (create != null) {
      final saved = await _controller.create(create);
      if (!mounted) return;
      if (saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calibración registrada correctamente.')),
        );
        _backToList();
      }
      return;
    }

    if (update != null && _editingCalibration != null) {
      final saved = await _controller.update(_editingCalibration!.id, update);
      if (!mounted) return;
      if (saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calibración actualizada correctamente.')),
        );
        _backToList();
      }
    }
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
              if (_mode != _GrindCalibrationMode.list) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _Breadcrumb(
                        onHome: _goToDashboard,
                        onBackToList: _backToList,
                        formTitle: _mode == _GrindCalibrationMode.create
                            ? 'Registrar'
                            : 'Editar',
                      ),
                    ),
                    if (_controller.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _ErrorBanner(message: _controller.errorMessage!),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: CalibrationFormView(
                          isEdit: _mode == _GrindCalibrationMode.edit,
                          initial: _editingCalibration,
                          isSubmitting: _controller.isLoading,
                          onSubmit: _handleSubmit,
                          onCancel: _backToList,
                        ),
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
                    _SearchAndRegisterRow(
                      searchController: _searchController,
                      onSearchChanged: _controller.updateSearchQuery,
                      onRegister: _openCreate,
                    ),
                    const SizedBox(height: 12),
                    if (_controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      _CalibrationsTable(
                        items: _controller.filteredItems,
                        onView: _openDetail,
                        onEdit: _openEdit,
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
    this.formTitle,
  });

  final VoidCallback onHome;
  final VoidCallback? onBackToList;
  final String? formTitle;

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
        if (formTitle != null && onBackToList != null)
          GestureDetector(
            onTap: onBackToList,
            child: const Text(
              'Calibración de molienda',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black87,
              ),
            ),
          )
        else
          const Text(
            'Calibración de molienda',
            style: TextStyle(color: Colors.black87),
          ),
        if (formTitle != null) ...[
          const Text('>', style: TextStyle(color: Colors.black54)),
          Text(formTitle!, style: const TextStyle(color: Colors.black87)),
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
      child: Text(message, style: const TextStyle(color: Color(0xFFC62828))),
    );
  }
}

class _SearchAndRegisterRow extends StatelessWidget {
  const _SearchAndRegisterRow({
    required this.searchController,
    required this.onSearchChanged,
    required this.onRegister,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRegister;

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
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar calibración...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            ),
          ),
        );

        final registerButton = FilledButton(
          onPressed: onRegister,
          style: FilledButton.styleFrom(
            backgroundColor: CostManagementColors.headerGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Registrar'),
        );

        if (isWide) {
          return Row(
            children: [
              SizedBox(width: 320, child: searchField),
              const Spacer(),
              registerButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            searchField,
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: registerButton),
          ],
        );
      },
    );
  }
}

class _CalibrationsTable extends StatefulWidget {
  const _CalibrationsTable({
    required this.items,
    required this.onView,
    required this.onEdit,
  });

  final List<GrindCalibration> items;
  final ValueChanged<GrindCalibration> onView;
  final ValueChanged<GrindCalibration> onEdit;

  static const _minTableWidth = 600.0;

  @override
  State<_CalibrationsTable> createState() => _CalibrationsTableState();
}

class _CalibrationsTableState extends State<_CalibrationsTable> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: widget.items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No hay calibraciones registradas.')),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final viewportWidth = constraints.maxWidth;
                final isScrollable =
                    viewportWidth < _CalibrationsTable._minTableWidth;

                return Column(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: isScrollable
                              ? _CalibrationsTable._minTableWidth
                              : viewportWidth,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            CostManagementColors.headerGreen,
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Método')),
                            DataColumn(label: Text('Equipo')),
                            DataColumn(label: Text('Apertura')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: widget.items.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item.name)),
                                DataCell(Text(item.method)),
                                DataCell(Text(item.equipment)),
                                DataCell(Text(item.aperture.toString())),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 20),
                                        tooltip: 'Editar',
                                        onPressed: () => widget.onEdit(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.search, size: 20),
                                        tooltip: 'Ver detalle',
                                        onPressed: () => widget.onView(item),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    if (isScrollable)
                      _HorizontalScrollGuideBar(
                        scrollController: _scrollController,
                        viewportWidth: viewportWidth,
                        contentWidth: _CalibrationsTable._minTableWidth,
                      ),
                  ],
                );
              },
            ),
    );
  }
}

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
        final thumbOffset = maxExtent > 0 ? (offset / maxExtent) * travel : 0.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: SizedBox(
            height: 6,
            width: trackWidth,
            child: Stack(
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

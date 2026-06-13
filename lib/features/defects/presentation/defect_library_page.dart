import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/defect_model.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/defect_library_controller.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/widgets/defect_detail_dialog.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/widgets/defect_form_view.dart';
import 'package:flutter/material.dart';

enum _DefectLibraryMode { list, create }

class DefectLibraryPage extends StatefulWidget {
  const DefectLibraryPage({super.key, required this.planType});

  final SubscriptionPlanType planType;

  @override
  State<DefectLibraryPage> createState() => _DefectLibraryPageState();
}

class _DefectLibraryPageState extends State<DefectLibraryPage> {
  final _controller = DefectLibraryController();
  final _coffeeSearchController = TextEditingController();
  final _defectSearchController = TextEditingController();

  _DefectLibraryMode _mode = _DefectLibraryMode.list;

  @override
  void initState() {
    super.initState();
    _controller.loadDefects();
  }

  @override
  void dispose() {
    _controller.dispose();
    _coffeeSearchController.dispose();
    _defectSearchController.dispose();
    super.dispose();
  }

  void _goToDashboard() => Navigator.of(context).pop();

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditProfileSessionPage()),
    );
  }

  void _backToList() {
    setState(() => _mode = _DefectLibraryMode.list);
    _controller.loadDefects();
  }

  void _openCreate() {
    setState(() => _mode = _DefectLibraryMode.create);
  }

  Future<void> _openDetail(DefectModel defect) async {
    await showDialog<void>(
      context: context,
      builder: (_) => DefectDetailDialog(defect: defect),
    );
  }

  Future<void> _handleSubmit(CreateDefectRequest request) async {
    final saved = await _controller.create(request);
    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Defecto registrado correctamente.')),
      );
      _backToList();
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
              if (_mode != _DefectLibraryMode.list) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _Breadcrumb(
                        onHome: _goToDashboard,
                        onBackToList: _backToList,
                        formTitle: 'Agregar',
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
                        child: DefectFormView(
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
                    _SearchAndAddRow(
                      coffeeSearchController: _coffeeSearchController,
                      defectSearchController: _defectSearchController,
                      onCoffeeSearchChanged: _controller.updateCoffeeSearch,
                      onDefectSearchChanged: _controller.updateDefectSearch,
                      onAdd: _openCreate,
                    ),
                    const SizedBox(height: 12),
                    if (_controller.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      _DefectsTable(
                        items: _controller.filteredItems,
                        onView: _openDetail,
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
              'Biblioteca de defectos',
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black87,
              ),
            ),
          )
        else
          const Text(
            'Biblioteca de defectos',
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

class _SearchAndAddRow extends StatelessWidget {
  const _SearchAndAddRow({
    required this.coffeeSearchController,
    required this.defectSearchController,
    required this.onCoffeeSearchChanged,
    required this.onDefectSearchChanged,
    required this.onAdd,
  });

  final TextEditingController coffeeSearchController;
  final TextEditingController defectSearchController;
  final ValueChanged<String> onCoffeeSearchChanged;
  final ValueChanged<String> onDefectSearchChanged;
  final VoidCallback onAdd;

  Widget _searchField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: Icon(Icons.search, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        final coffeeField = _searchField(
          controller: coffeeSearchController,
          hint: 'Buscar por café...',
          onChanged: onCoffeeSearchChanged,
        );
        final defectField = _searchField(
          controller: defectSearchController,
          hint: 'Buscar por defecto...',
          onChanged: onDefectSearchChanged,
        );
        final addButton = FilledButton(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: CostManagementColors.headerGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Agregar'),
        );

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: coffeeField),
                  const SizedBox(width: 12),
                  Expanded(child: defectField),
                  const SizedBox(width: 12),
                  addButton,
                ],
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            coffeeField,
            const SizedBox(height: 12),
            defectField,
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: addButton),
          ],
        );
      },
    );
  }
}

class _DefectsTable extends StatefulWidget {
  const _DefectsTable({
    required this.items,
    required this.onView,
  });

  final List<DefectModel> items;
  final ValueChanged<DefectModel> onView;

  static const _minTableWidth = 560.0;

  @override
  State<_DefectsTable> createState() => _DefectsTableState();
}

class _DefectsTableState extends State<_DefectsTable> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
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
              child: Center(child: Text('No hay defectos registrados.')),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final viewportWidth = constraints.maxWidth;
                final isScrollable =
                    viewportWidth < _DefectsTable._minTableWidth;

                return Column(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: isScrollable
                              ? _DefectsTable._minTableWidth
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
                            DataColumn(label: Text('Peso')),
                            DataColumn(label: Text('Café')),
                            DataColumn(label: Text('Defecto')),
                            DataColumn(label: Text('Porcentaje')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: widget.items.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(_formatWeight(item.defectWeight)),
                                ),
                                DataCell(Text(item.coffeeDisplayName)),
                                DataCell(Text(item.name)),
                                DataCell(Text('${item.percentage}%')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.search, size: 20),
                                    tooltip: 'Ver detalle',
                                    onPressed: () => widget.onView(item),
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
                        contentWidth: _DefectsTable._minTableWidth,
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

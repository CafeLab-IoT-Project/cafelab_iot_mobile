import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/preparation/data/preparation_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/create_ingredient_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/create_portfolio_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/create_recipe_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/update_ingredient_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/update_portfolio_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/update_recipe_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class PreparationTestPage extends StatefulWidget {
  const PreparationTestPage({super.key});

  @override
  State<PreparationTestPage> createState() => _PreparationTestPageState();
}

class _PreparationTestPageState extends State<PreparationTestPage> {
  final _repo = PreparationRepositoryImpl();
  final _tokenStorage = TokenStorageService();

  final _portfolioIdCtrl = TextEditingController();
  final _portfolioNameCtrl = TextEditingController();

  final _recipeIdCtrl = TextEditingController();
  final _recipeNameCtrl = TextEditingController();
  final _recipeImageUrlCtrl = TextEditingController();
  final _recipeExtractionMethodCtrl = TextEditingController();
  final _recipeExtractionCategoryCtrl = TextEditingController();
  final _recipeRatioCtrl = TextEditingController();
  final _recipeCuppingSessionIdCtrl = TextEditingController();
  final _recipePortfolioIdCtrl = TextEditingController();
  final _recipePreparationTimeCtrl = TextEditingController();
  final _recipeStepsCtrl = TextEditingController();
  final _recipeTipsCtrl = TextEditingController();
  final _recipeCuppingCtrl = TextEditingController();
  final _recipeGrindSizeCtrl = TextEditingController();

  final _ingredientRecipeIdCtrl = TextEditingController();
  final _ingredientIdCtrl = TextEditingController();
  final _ingredientNameCtrl = TextEditingController();
  final _ingredientAmountCtrl = TextEditingController();
  final _ingredientUnitCtrl = TextEditingController();

  bool _loading = false;
  String _status = 'Idle';
  String _result = 'Sin llamadas todavía.';

  @override
  void dispose() {
    _portfolioIdCtrl.dispose();
    _portfolioNameCtrl.dispose();
    _recipeIdCtrl.dispose();
    _recipeNameCtrl.dispose();
    _recipeImageUrlCtrl.dispose();
    _recipeExtractionMethodCtrl.dispose();
    _recipeExtractionCategoryCtrl.dispose();
    _recipeRatioCtrl.dispose();
    _recipeCuppingSessionIdCtrl.dispose();
    _recipePortfolioIdCtrl.dispose();
    _recipePreparationTimeCtrl.dispose();
    _recipeStepsCtrl.dispose();
    _recipeTipsCtrl.dispose();
    _recipeCuppingCtrl.dispose();
    _recipeGrindSizeCtrl.dispose();
    _ingredientRecipeIdCtrl.dispose();
    _ingredientIdCtrl.dispose();
    _ingredientNameCtrl.dispose();
    _ingredientAmountCtrl.dispose();
    _ingredientUnitCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureTokenOrShowError() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _showError('No hay token guardado. Haz Sign In primero para usar Preparation.');
      return false;
    }
    return true;
  }

  int? _parseInt(TextEditingController ctrl) => int.tryParse(ctrl.text.trim());
  double? _parseDouble(TextEditingController ctrl) => double.tryParse(ctrl.text.trim());

  Future<void> _createPortfolio() async {
    if (!await _ensureTokenOrShowError()) return;
    final name = _portfolioNameCtrl.text.trim();
    if (name.isEmpty) return _showError('Portfolio name es obligatorio.');
    await _run(
      label: 'CREATE_PORTFOLIO',
      action: () async {
        final data = await _repo.createPortfolio(CreatePortfolioRequest(name: name));
        _setResult('Portafolio creado', _pretty(_portfolioMap(data)));
      },
    );
  }

  Future<void> _listPortfolios() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LIST_PORTFOLIOS',
      action: () async {
        final items = await _repo.listPortfolios();
        _setResult('Portafolios: ${items.length}', _pretty(items.map(_portfolioMap).toList()));
      },
    );
  }

  Future<void> _getPortfolioById() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = _parseInt(_portfolioIdCtrl);
    if (id == null) return _showError('Portfolio ID debe ser numérico.');
    await _run(
      label: 'GET_PORTFOLIO_BY_ID',
      action: () async {
        final data = await _repo.getPortfolioById(id);
        _setResult('Portafolio encontrado', _pretty(_portfolioMap(data)));
      },
    );
  }

  Future<void> _updatePortfolio() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = _parseInt(_portfolioIdCtrl);
    final name = _portfolioNameCtrl.text.trim();
    if (id == null) return _showError('Portfolio ID debe ser numérico.');
    if (name.isEmpty) return _showError('Portfolio name es obligatorio.');
    await _run(
      label: 'UPDATE_PORTFOLIO',
      action: () async {
        final data = await _repo.updatePortfolio(id, UpdatePortfolioRequest(name: name));
        _setResult('Portafolio actualizado', _pretty(_portfolioMap(data)));
      },
    );
  }

  Future<void> _deletePortfolio() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = _parseInt(_portfolioIdCtrl);
    if (id == null) return _showError('Portfolio ID debe ser numérico.');
    await _run(
      label: 'DELETE_PORTFOLIO',
      action: () async {
        final msg = await _repo.deletePortfolio(id);
        _setResult('Portafolio eliminado', _pretty({'message': msg.message}));
      },
    );
  }

  Future<void> _createRecipe() async {
    if (!await _ensureTokenOrShowError()) return;
    final cuppingId = _parseInt(_recipeCuppingSessionIdCtrl);
    final portfolioId = _parseInt(_recipePortfolioIdCtrl);
    final prepTime = _parseInt(_recipePreparationTimeCtrl);
    if (_recipeNameCtrl.text.trim().isEmpty ||
        _recipeImageUrlCtrl.text.trim().isEmpty ||
        _recipeExtractionMethodCtrl.text.trim().isEmpty ||
        _recipeExtractionCategoryCtrl.text.trim().isEmpty ||
        _recipeRatioCtrl.text.trim().isEmpty ||
        _recipeStepsCtrl.text.trim().isEmpty) {
      return _showError('Completa todos los campos obligatorios de Recipe.');
    }
    if (cuppingId == null || portfolioId == null || prepTime == null) {
      return _showError('cuppingSessionId, portfolioId y preparationTime deben ser numéricos.');
    }
    await _run(
      label: 'CREATE_RECIPE',
      action: () async {
        final data = await _repo.createRecipe(
          CreateRecipeRequest(
            name: _recipeNameCtrl.text.trim(),
            imageUrl: _recipeImageUrlCtrl.text.trim(),
            extractionMethod: _recipeExtractionMethodCtrl.text.trim(),
            extractionCategory: _recipeExtractionCategoryCtrl.text.trim(),
            ratio: _recipeRatioCtrl.text.trim(),
            cuppingSessionId: cuppingId,
            portfolioId: portfolioId,
            preparationTime: prepTime,
            steps: _recipeStepsCtrl.text.trim(),
            tips: _nullIfEmpty(_recipeTipsCtrl.text),
            cupping: _nullIfEmpty(_recipeCuppingCtrl.text),
            grindSize: _nullIfEmpty(_recipeGrindSizeCtrl.text),
          ),
        );
        _setResult('Receta creada', _pretty(_recipeMap(data)));
      },
    );
  }

  Future<void> _listRecipes() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LIST_RECIPES',
      action: () async {
        final items = await _repo.listRecipes();
        _setResult('Recetas: ${items.length}', _pretty(items.map(_recipeMap).toList()));
      },
    );
  }

  Future<void> _getRecipeById() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = _parseInt(_recipeIdCtrl);
    if (id == null) return _showError('Recipe ID debe ser numérico.');
    await _run(
      label: 'GET_RECIPE_BY_ID',
      action: () async {
        final data = await _repo.getRecipeById(id);
        _setResult('Receta encontrada', _pretty(_recipeMap(data)));
      },
    );
  }

  Future<void> _updateRecipe() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = _parseInt(_recipeIdCtrl);
    final cuppingId = _parseInt(_recipeCuppingSessionIdCtrl);
    final portfolioId = _parseInt(_recipePortfolioIdCtrl);
    final prepTime = _parseInt(_recipePreparationTimeCtrl);
    if (id == null || cuppingId == null || portfolioId == null || prepTime == null) {
      return _showError(
        'recipeId, cuppingSessionId, portfolioId y preparationTime deben ser numéricos.',
      );
    }
    if (_recipeNameCtrl.text.trim().isEmpty ||
        _recipeImageUrlCtrl.text.trim().isEmpty ||
        _recipeExtractionMethodCtrl.text.trim().isEmpty ||
        _recipeExtractionCategoryCtrl.text.trim().isEmpty ||
        _recipeRatioCtrl.text.trim().isEmpty ||
        _recipeStepsCtrl.text.trim().isEmpty) {
      return _showError('Completa todos los campos obligatorios de Recipe.');
    }
    await _run(
      label: 'UPDATE_RECIPE',
      action: () async {
        final data = await _repo.updateRecipe(
          id,
          UpdateRecipeRequest(
            name: _recipeNameCtrl.text.trim(),
            imageUrl: _recipeImageUrlCtrl.text.trim(),
            extractionMethod: _recipeExtractionMethodCtrl.text.trim(),
            extractionCategory: _recipeExtractionCategoryCtrl.text.trim(),
            ratio: _recipeRatioCtrl.text.trim(),
            cuppingSessionId: cuppingId,
            portfolioId: portfolioId,
            preparationTime: prepTime,
            steps: _recipeStepsCtrl.text.trim(),
            tips: _nullIfEmpty(_recipeTipsCtrl.text),
            cupping: _nullIfEmpty(_recipeCuppingCtrl.text),
            grindSize: _nullIfEmpty(_recipeGrindSizeCtrl.text),
          ),
        );
        _setResult('Receta actualizada', _pretty(_recipeMap(data)));
      },
    );
  }

  Future<void> _deleteRecipe() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = _parseInt(_recipeIdCtrl);
    if (id == null) return _showError('Recipe ID debe ser numérico.');
    await _run(
      label: 'DELETE_RECIPE',
      action: () async {
        final msg = await _repo.deleteRecipe(id);
        _setResult('Receta eliminada', _pretty({'message': msg.message}));
      },
    );
  }

  Future<void> _createIngredient() async {
    if (!await _ensureTokenOrShowError()) return;
    final recipeId = _parseInt(_ingredientRecipeIdCtrl);
    final amount = _parseDouble(_ingredientAmountCtrl);
    if (recipeId == null || amount == null) {
      return _showError('recipeId y amount deben ser numéricos.');
    }
    if (_ingredientNameCtrl.text.trim().isEmpty || _ingredientUnitCtrl.text.trim().isEmpty) {
      return _showError('name y unit de Ingredient son obligatorios.');
    }
    await _run(
      label: 'CREATE_INGREDIENT',
      action: () async {
        final data = await _repo.createIngredient(
          recipeId,
          CreateIngredientRequest(
            recipeId: recipeId,
            name: _ingredientNameCtrl.text.trim(),
            amount: amount,
            unit: _ingredientUnitCtrl.text.trim(),
          ),
        );
        _setResult('Ingrediente creado', _pretty(_ingredientMap(data)));
      },
    );
  }

  Future<void> _listIngredients() async {
    if (!await _ensureTokenOrShowError()) return;
    final recipeId = _parseInt(_ingredientRecipeIdCtrl);
    if (recipeId == null) return _showError('recipeId debe ser numérico.');
    await _run(
      label: 'LIST_INGREDIENTS',
      action: () async {
        final items = await _repo.listIngredients(recipeId);
        _setResult('Ingredientes: ${items.length}', _pretty(items.map(_ingredientMap).toList()));
      },
    );
  }

  Future<void> _updateIngredient() async {
    if (!await _ensureTokenOrShowError()) return;
    final recipeId = _parseInt(_ingredientRecipeIdCtrl);
    final ingredientId = _parseInt(_ingredientIdCtrl);
    final amount = _parseDouble(_ingredientAmountCtrl);
    if (recipeId == null || ingredientId == null || amount == null) {
      return _showError('recipeId, ingredientId y amount deben ser numéricos.');
    }
    if (_ingredientNameCtrl.text.trim().isEmpty || _ingredientUnitCtrl.text.trim().isEmpty) {
      return _showError('name y unit de Ingredient son obligatorios.');
    }
    await _run(
      label: 'UPDATE_INGREDIENT',
      action: () async {
        final data = await _repo.updateIngredient(
          recipeId,
          ingredientId,
          UpdateIngredientRequest(
            name: _ingredientNameCtrl.text.trim(),
            amount: amount,
            unit: _ingredientUnitCtrl.text.trim(),
          ),
        );
        _setResult('Ingrediente actualizado', _pretty(_ingredientMap(data)));
      },
    );
  }

  Future<void> _deleteIngredient() async {
    if (!await _ensureTokenOrShowError()) return;
    final recipeId = _parseInt(_ingredientRecipeIdCtrl);
    final ingredientId = _parseInt(_ingredientIdCtrl);
    if (recipeId == null || ingredientId == null) {
      return _showError('recipeId e ingredientId deben ser numéricos.');
    }
    await _run(
      label: 'DELETE_INGREDIENT',
      action: () async {
        final msg = await _repo.deleteIngredient(recipeId, ingredientId);
        _setResult('Ingrediente eliminado', _pretty({'message': msg.message}));
      },
    );
  }

  Future<void> _run({
    required String label,
    required Future<void> Function() action,
  }) async {
    setState(() {
      _loading = true;
      _status = '$label - loading...';
    });
    try {
      await action();
    } on ProductionApiException catch (e) {
      _showError(e.toString());
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setResult(String status, String result) {
    setState(() {
      _status = status;
      _result = result;
    });
  }

  void _showError(String message) {
    setState(() {
      _status = 'Error';
      _result = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _pretty(Object obj) => const JsonEncoder.withIndent('  ').convert(obj);

  String? _nullIfEmpty(String raw) {
    final v = raw.trim();
    return v.isEmpty ? null : v;
  }

  Map<String, dynamic> _portfolioMap(dynamic p) => {
        'id': p.id,
        'userId': p.userId,
        'name': p.name,
        'createdAt': p.createdAt,
      };

  Map<String, dynamic> _ingredientMap(dynamic i) => {
        'id': i.id,
        'recipeId': i.recipeId,
        'name': i.name,
        'amount': i.amount,
        'unit': i.unit,
      };

  Map<String, dynamic> _recipeMap(dynamic r) => {
        'id': r.id,
        'userId': r.userId,
        'name': r.name,
        'imageUrl': r.imageUrl,
        'extractionMethod': r.extractionMethod,
        'extractionCategory': r.extractionCategory,
        'ratio': r.ratio,
        'cuppingSessionId': r.cuppingSessionId,
        'portfolioId': r.portfolioId,
        'preparationTime': r.preparationTime,
        'steps': r.steps,
        'tips': r.tips,
        'cupping': r.cupping,
        'grindSize': r.grindSize,
        'createdAt': r.createdAt,
        'ingredients': r.ingredients.map(_ingredientMap).toList(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preparation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Portfolios', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _portfolioNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Portfolio name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _portfolioIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Portfolio ID',
                  border: OutlineInputBorder(),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(onPressed: _loading ? null : _createPortfolio, child: const Text('Create')),
                  ElevatedButton(onPressed: _loading ? null : _listPortfolios, child: const Text('List')),
                  OutlinedButton(onPressed: _loading ? null : _getPortfolioById, child: const Text('Get by ID')),
                  OutlinedButton(onPressed: _loading ? null : _updatePortfolio, child: const Text('Update')),
                  OutlinedButton(onPressed: _loading ? null : _deletePortfolio, child: const Text('Delete')),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _recipeIdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Recipe ID', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeNameCtrl, decoration: const InputDecoration(labelText: 'name *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeImageUrlCtrl, decoration: const InputDecoration(labelText: 'imageUrl *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeExtractionMethodCtrl, decoration: const InputDecoration(labelText: 'extractionMethod *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeExtractionCategoryCtrl, decoration: const InputDecoration(labelText: 'extractionCategory *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeRatioCtrl, decoration: const InputDecoration(labelText: 'ratio *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeCuppingSessionIdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'cuppingSessionId *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipePortfolioIdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'portfolioId *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipePreparationTimeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'preparationTime *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeStepsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'steps *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeTipsCtrl, decoration: const InputDecoration(labelText: 'tips (opcional)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeCuppingCtrl, decoration: const InputDecoration(labelText: 'cupping (opcional)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _recipeGrindSizeCtrl, decoration: const InputDecoration(labelText: 'grindSize (opcional)', border: OutlineInputBorder())),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(onPressed: _loading ? null : _createRecipe, child: const Text('Create')),
                  ElevatedButton(onPressed: _loading ? null : _listRecipes, child: const Text('List')),
                  OutlinedButton(onPressed: _loading ? null : _getRecipeById, child: const Text('Get by ID')),
                  OutlinedButton(onPressed: _loading ? null : _updateRecipe, child: const Text('Update')),
                  OutlinedButton(onPressed: _loading ? null : _deleteRecipe, child: const Text('Delete')),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Ingredients (recipe nested)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _ingredientRecipeIdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'recipeId *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _ingredientIdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ingredientId (update/delete)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _ingredientNameCtrl, decoration: const InputDecoration(labelText: 'name *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _ingredientAmountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'amount *', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: _ingredientUnitCtrl, decoration: const InputDecoration(labelText: 'unit *', border: OutlineInputBorder())),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(onPressed: _loading ? null : _createIngredient, child: const Text('Create')),
                  ElevatedButton(onPressed: _loading ? null : _listIngredients, child: const Text('List')),
                  OutlinedButton(onPressed: _loading ? null : _updateIngredient, child: const Text('Update')),
                  OutlinedButton(onPressed: _loading ? null : _deleteIngredient, child: const Text('Delete')),
                ],
              ),
              const SizedBox(height: 14),
              Text('Status: $_status'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(_result),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

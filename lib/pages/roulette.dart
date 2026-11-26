import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/pages/recipe/detail.dart';
import 'package:cook_roulette/recipe/repositories.dart';
import 'package:cook_roulette/recipe/services.dart';
import 'package:cook_roulette/theme/app_theme.dart';

class RoulettePage extends StatefulWidget {
  final RecipeService recipeService;
  final List<RecipeDto> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const RoulettePage({
    super.key,
    required this.recipeService,
    required this.recipes,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  final StreamController<int> _selectedController =
      StreamController<int>.broadcast();
  final Random _random = Random();

  bool _isSpinning = false;
  RandomRecipeDto? _pendingRecipe;
  RandomRecipeDto? _selectedRecipe;
  String? _spinError;

  @override
  void dispose() {
    _selectedController.close();
    super.dispose();
  }

  void _showRecipeModal(RandomRecipeDto recipe) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => RandomRecipeModal(
        recipe: recipe,
        onViewDetails: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailPage(
                recipeService: widget.recipeService,
                recipe: recipe,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _spin(int itemCount) async {
    if (_isSpinning || itemCount == 0) return;

    setState(() {
      _isSpinning = true;
      _spinError = null;
      _pendingRecipe = null;
    });

    try {
      final recipe = await widget.recipeService.getRandomRecipe();
      if (!mounted) return;

      _pendingRecipe = recipe;
      final nextIndex = _random.nextInt(itemCount);
      _selectedController.add(nextIndex);
    } on RecipeRepositoryException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSpinning = false;
        _spinError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSpinning = false;
        _spinError = 'Unable to pick a random recipe. Please try again.';
      });
    }
  }

  Future<void> _openRecipeDetails(RandomRecipeDto recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetailPage(recipeService: widget.recipeService, recipe: recipe),
      ),
    );

    if (!mounted) return;

    final existingIndex = widget.recipes.indexWhere(
      (item) => item.id == recipe.id,
    );
    if (existingIndex != -1) {
      widget.recipes[existingIndex].isFavorite = recipe.isFavorite;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.recipes.isEmpty) {
      return const Center(
        child: Text(
          'No recipes available for the roulette.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final recipesToDisplay = widget.recipes.take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            'What to cook today?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Spin the wheel to pick a recipe!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320,
            child: FortuneWheel(
              selected: _selectedController.stream,
              animateFirst: false,
              onAnimationEnd: () {
                final recipe = _pendingRecipe;
                setState(() {
                  _isSpinning = false;
                  _pendingRecipe = null;
                });

                if (recipe != null) {
                  _showRecipeModal(recipe);
                }
              },
              indicators: const [
                FortuneIndicator(
                  alignment: Alignment.topCenter,
                  child: TriangleIndicator(color: AppColors.accent),
                ),
              ],
              items: [
                for (int i = 0; i < recipesToDisplay.length; i++)
                  FortuneItem(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24, right: 12),
                      child: Text(
                        recipesToDisplay[i].name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: AppColors
                          .rouletteSlices[i % AppColors.rouletteSlices.length],
                      borderColor: AppColors.surface,
                      borderWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isSpinning
                ? null
                : () => _spin(recipesToDisplay.length),
            icon: const Icon(Icons.casino),
            label: Text(_isSpinning ? 'Spinning...' : 'Spin Roulette'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_spinError != null) ...[
            const SizedBox(height: 16),
            Text(
              _spinError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.accent),
            ),
          ],
          if (_selectedRecipe != null) ...[
            const SizedBox(height: 24),
            _SelectedRecipeCard(
              recipe: _selectedRecipe!,
              onTap: () => _openRecipeDetails(_selectedRecipe!),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedRecipeCard extends StatelessWidget {
  final RandomRecipeDto recipe;
  final VoidCallback onTap;

  const _SelectedRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cuisine = recipe.cuisine.trim().isEmpty ? 'General' : recipe.cuisine;

    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe.image,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 76,
                    height: 76,
                    color: AppColors.primaryContainer,
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        if (recipe.isFavorite)
                          const Icon(
                            Icons.favorite,
                            size: 18,
                            color: AppColors.accent,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cuisine · ${recipe.difficulty}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${recipe.totalTimeMinutes} min · ${recipe.servings} servings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class RandomRecipeModal extends StatelessWidget {
  final RandomRecipeDto recipe;
  final VoidCallback onViewDetails;

  const RandomRecipeModal({
    super.key,
    required this.recipe,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final cuisine = recipe.cuisine.trim().isEmpty ? 'General' : recipe.cuisine;
    final rating = recipe.rating.toStringAsFixed(1);

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Today's Pick",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              height: 180,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.network(
                recipe.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              recipe.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$cuisine · $rating / 5',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _ModalInfoTile(
                    value: '${recipe.totalTimeMinutes} min',
                    label: 'total time',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModalInfoTile(
                    value: '${recipe.servings}',
                    label: 'servings',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModalInfoTile(
                    value: recipe.difficulty,
                    label: 'difficulty',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Prepare: ${recipe.prepTimeMinutes} min · Cooking: ${recipe.cookTimeMinutes} min',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalInfoTile extends StatelessWidget {
  final String value;
  final String label;

  const _ModalInfoTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

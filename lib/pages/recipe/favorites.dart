import 'package:cook_roulette/components/cuisine_section.dart';
import 'package:cook_roulette/pages/recipe/detail.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/recipe/services.dart';
import 'package:cook_roulette/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final RecipeService recipeService;
  final List<RecipeDto> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const FavoritesPage({
    super.key,
    required this.recipeService,
    required this.recipes,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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

    final favoriteRecipes =
        widget.recipes.where((recipe) => recipe.isFavorite).toList();

    if (favoriteRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite recipes yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    final sections = widget.recipeService
        .groupByCuisine(favoriteRecipes)
        .entries
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final entry = sections[index];
        return CuisineSection(
          cuisine: entry.key,
          recipes: entry.value,
          onRecipeTap: (recipe) async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPage(
                  recipeService: widget.recipeService,
                  recipe: recipe,
                ),
              ),
            );

            if (mounted) {
              setState(() {});
            }
          },
        );
      },
    );
  }
}

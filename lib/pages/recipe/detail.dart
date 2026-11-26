import 'package:flutter/material.dart';
import 'package:cook_roulette/theme/app_theme.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/recipe/repositories.dart';
import 'package:cook_roulette/recipe/services.dart';

class DetailPage extends StatefulWidget {
  final RecipeService recipeService;
  final RecipeDto recipe;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const DetailPage({
    super.key,
    required this.recipeService,
    required this.recipe,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  static const Color _cardBg = AppColors.surface;
  static const Color _imageAreaBg = AppColors.surfaceVariant;
  static const Color _lightGreenBg = AppColors.primaryContainer;
  static const Color _darkGreen = AppColors.primary;
  static const Color _mutedGreenText = AppColors.textSecondary;

  RecipeDetailDto? _details;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await widget.recipeService.getRecipeDetails(
        widget.recipe.id,
      );
      if (!mounted) return;
      setState(() {
        _details = details;
      });
    } on RecipeRepositoryException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildSubtitle() {
    final cuisine = widget.recipe.cuisine.trim().isEmpty
        ? 'General'
        : widget.recipe.cuisine;
    final rating = widget.recipe.rating.toStringAsFixed(1).replaceAll('.', ',');

    if (_details == null) {
      return '$cuisine · $rating / 5';
    }
    return '$cuisine · ${_details!.difficulty} · $rating / 5';
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Recipe Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 220,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: _imageAreaBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.network(
                  recipe.image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 56,
                      color: _darkGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                recipe.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _buildSubtitle(),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: _mutedGreenText),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _QuickInfoCard(
                        value: '${recipe.totalTimeMinutes} min',
                        label: 'total time',
                        backgroundColor: _lightGreenBg,
                        valueColor: _darkGreen,
                        labelColor: _mutedGreenText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickInfoCard(
                        value: _details != null
                            ? '${_details!.servings}'
                            : '--',
                        label: 'servings',
                        backgroundColor: _lightGreenBg,
                        valueColor: _darkGreen,
                        labelColor: _mutedGreenText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickInfoCard(
                        icon: widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor: widget.isFavorite
                            ? AppColors.accent
                            : _darkGreen,
                        backgroundColor: _lightGreenBg,
                        valueColor: _darkGreen,
                        labelColor: _mutedGreenText,
                        onTap: widget.onToggleFavorite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildDynamicDetails(context),
              const SizedBox(height: 20),
              Text(
                'Prepare: ${recipe.prepTimeMinutes} min / Cooking: ${recipe.cookTimeMinutes} min',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: _mutedGreenText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicDetails(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: _darkGreen)),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _mutedGreenText),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final details = _details;
    if (details == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: _darkGreen),
        ),
        const SizedBox(height: 8),
        ...details.ingredients.map(
          (ingredient) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7, right: 8),
                  child: Icon(Icons.circle, size: 6, color: _darkGreen),
                ),
                Expanded(
                  child: Text(
                    ingredient,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.3, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Preparation Method',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: _darkGreen),
        ),
        const SizedBox(height: 10),
        ...details.instructions.asMap().entries.map((entry) {
          final stepNumber = entry.key + 1;
          final instruction = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _darkGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      instruction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: const Color(0xFF2B3530),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final String? value;
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final Color backgroundColor;
  final Color valueColor;
  final Color labelColor;
  final VoidCallback? onTap;

  const _QuickInfoCard({
    this.value,
    this.icon,
    this.iconColor,
    this.label = '',
    required this.backgroundColor,
    required this.valueColor,
    required this.labelColor,
    this.onTap,
  }) : assert(value != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: 24, color: iconColor ?? valueColor)
              else
                Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: labelColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

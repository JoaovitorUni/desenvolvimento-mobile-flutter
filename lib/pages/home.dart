import 'package:cook_roulette/pages/recipe/detail.dart';
import 'package:cook_roulette/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cook_roulette/components/cuisine_section.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/recipe/services.dart';

class HomePage extends StatefulWidget {
  final RecipeService recipeService;
  final List<RecipeDto> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const HomePage({
    super.key,
    required this.recipeService,
    required this.recipes,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  String? _searchWarning;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchQuery = null;
        _searchWarning = 'Please enter a recipe name to search';
      });
    } else {
      setState(() {
        _searchQuery = query;
        _searchWarning = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.recipeService
        .groupByCuisine(widget.recipes)
        .entries
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) {
                        if (_searchWarning != null) {
                          setState(() {
                            _searchWarning = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _searchWarning != null
                                ? AppColors.error
                                : AppColors.border,
                            width: _searchWarning != null ? 1.5 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _searchWarning != null
                                ? AppColors.error
                                : AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                    if (_searchWarning != null &&
                        _searchWarning!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          _searchWarning!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.border.withValues(alpha: 0.4),
        ),
        if (_searchQuery != null && _searchQuery!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Results for "$_searchQuery"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        Expanded(
          child: ListView.builder(
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
          ),
        ),
      ],
    );
  }
}

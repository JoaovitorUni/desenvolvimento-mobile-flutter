import 'package:cook_roulette/pages/recipe/detail.dart';
import 'package:cook_roulette/recipe/repositories.dart';
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
  String? _searchError;
  bool _isSearching = false;
  List<RecipeDto>? _searchResults;

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
        _searchResults = null;
        _searchError = null;
        _searchWarning = 'Please enter a recipe name to search';
      });
    } else {
      _performSearch(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = null;
      _searchResults = null;
      _searchWarning = null;
      _searchError = null;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchWarning = null;
      _searchQuery = query;
    });

    try {
      final results = await widget.recipeService.searchRecipes(query);

      for (final result in results) {
        final matchIndex = widget.recipes.indexWhere((r) => r.id == result.id);
        if (matchIndex != -1) {
          result.isFavorite = widget.recipes[matchIndex].isFavorite;
        }
      }

      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } on RecipeRepositoryException catch (e) {
      if (!mounted) return;
      setState(() {
        _searchError = e.message;
      });
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        _searchWarning = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchError = 'An unexpected error occurred while searching.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        setState(() {
                          if (_searchWarning != null) {
                            _searchWarning = null;
                          }
                        });
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
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
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
        if (_searchQuery != null &&
            _searchQuery!.isNotEmpty &&
            !_isSearching &&
            _searchError == null)
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
          child: _buildBody(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _searchError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (_searchQuery != null) {
                    _performSearch(_searchQuery!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.isLoading && _searchResults == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (widget.errorMessage != null && _searchResults == null) {
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

    final recipesToDisplay = _searchResults ?? widget.recipes;

    if (_searchResults != null && _searchResults!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No recipes found matching "$_searchQuery"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    final sections = widget.recipeService
        .groupByCuisine(recipesToDisplay)
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

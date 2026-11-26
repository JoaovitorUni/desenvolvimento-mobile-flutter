import 'package:cook_roulette/pages/recipe/detail.dart';
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
  @override
  Widget build(BuildContext context) {
    final sections = widget.recipeService
        .groupByCuisine(widget.recipes)
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

import 'package:cook_roulette/pages/home.dart';
import 'package:cook_roulette/pages/roulette.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:flutter/material.dart';

class AppPagesStack extends StatelessWidget {
  final int currentIndex;
  final List<RecipeDto> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const AppPagesStack({
    super.key,
    required this.currentIndex,
    required this.recipes,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentIndex,
      children: [
        HomePage(
          recipes: recipes,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRetry: onRetry,
        ),
        RoulettePage(
          recipes: recipes,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRetry: onRetry,
        ),
      ],
    );
  }
}

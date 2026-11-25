import 'package:flutter/material.dart';
import 'package:cook_roulette/recipe/dtos.dart';

class RoulettePage extends StatefulWidget {
  final List<RecipeDto> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const RoulettePage({
    super.key,
    required this.recipes,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Roulette"));
  }
}

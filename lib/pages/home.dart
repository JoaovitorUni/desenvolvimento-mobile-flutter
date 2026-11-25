import 'package:flutter/material.dart';
import 'package:cook_roulette/recipe/dtos.dart';

class HomePage extends StatefulWidget {
  final List<RecipeDto> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const HomePage({
    super.key,
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
    return const Center(child: Text("Hello World!"));
  }
}

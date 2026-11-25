import 'package:flutter/material.dart';
import 'package:cook_roulette/components/app_pages_stack.dart';
import 'package:cook_roulette/components/app_navigation_bar.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/recipe/repositories.dart';
import 'package:cook_roulette/recipe/services.dart';

void main() {
  runApp(const MaterialApp(title: 'Cook Roulette', home: Main()));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentPage = 0;

  final RecipeService _recipeService = RecipeService();

  List<RecipeDto> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await _recipeService.getRecipes();
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cook Roulette')),
      body: AppPagesStack(
        currentIndex: _currentPage,
        recipes: _recipes,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadRecipes,
      ),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: _currentPage,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
      ),
    );
  }
}

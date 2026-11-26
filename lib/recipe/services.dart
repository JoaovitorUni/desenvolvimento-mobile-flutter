import 'dart:math';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/recipe/repositories.dart';

class RecipeService {
  final RecipeRepository _repository;
  final Random _random;

  RecipeService({RecipeRepository? repository, Random? random})
      : _repository = repository ?? RecipeRepository(),
        _random = random ?? Random();

  Future<List<RecipeDto>> getRecipes() {
    return _repository.fetchAll();
  }

  Future<RecipeDetailDto> getRecipeDetails(int id) {
    return _repository.fetchById(id);
  }

  Future<RandomRecipeDto> getRandomRecipe() async {
    final randomId = _random.nextInt(50) + 1;
    final randomRecipe = await _repository.fetchRandomById(randomId);

    return randomRecipe;
  }

  Future<List<RecipeDto>> searchRecipes(String rawQuery) {
    final sanitizedQuery = rawQuery.trim();
    if (sanitizedQuery.isEmpty) {
      throw ArgumentError('Please enter a recipe name to search.');
    }
    return _repository.searchByName(sanitizedQuery);
  }

  Map<String, List<RecipeDto>> groupByCuisine(List<RecipeDto> recipes) {
    final Map<String, List<RecipeDto>> grouped = {};

    for (final recipe in recipes) {
      final cuisine = recipe.cuisine.trim().isEmpty ? 'Other' : recipe.cuisine;
      grouped.putIfAbsent(cuisine, () => []).add(recipe);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Map.fromEntries(sortedEntries);
  }
}
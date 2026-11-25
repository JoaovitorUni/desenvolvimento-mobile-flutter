import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/recipe/repositories.dart';

class RecipeService {
  final RecipeRepository _repository;

  RecipeService({RecipeRepository? repository})
      : _repository = repository ?? RecipeRepository();

  Future<List<RecipeDto>> getRecipes() {
    return _repository.fetchAll();
  }

  Future<List<RecipeDto>> searchRecipes(String rawQuery) {
    final sanitizedQuery = rawQuery.trim();
    if (sanitizedQuery.isEmpty) {
      throw ArgumentError('Informe o nome de uma receita para pesquisar.');
    }
    return _repository.searchByName(sanitizedQuery);
  }
}
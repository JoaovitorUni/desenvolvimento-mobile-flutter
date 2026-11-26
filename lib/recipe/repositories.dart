import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cook_roulette/recipe/dtos.dart';

class RecipeRepositoryException implements Exception {
  final String message;
  const RecipeRepositoryException(this.message);

  @override
  String toString() => message;
}

class RecipeRepository {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<RecipeDto>> fetchAll() async {
    final uri = Uri.parse(_baseUrl);
    return _getRecipesFromUri(uri);
  }

  Future<List<RecipeDto>> searchByName(String query) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {'q': query},
    );
    return _getRecipesFromUri(uri);
  }

  Future<List<RecipeDto>> _getRecipesFromUri(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw RecipeRepositoryException(
          'Falha na comunicação com o servidor (Erro ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['recipes'] is! List) {
        throw const RecipeRepositoryException(
          'A resposta do servidor veio em um formato inesperado.',
        );
      }

      final rawRecipes = decoded['recipes'] as List<dynamic>;
      return rawRecipes
          .map((item) => RecipeDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const RecipeRepositoryException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on TimeoutException {
      throw const RecipeRepositoryException(
        'O servidor demorou muito para responder. Tente novamente.',
      );
    } on FormatException {
      throw const RecipeRepositoryException(
        'Não foi possível processar os dados recebidos da API.',
      );
    } on RecipeRepositoryException {
      rethrow;
    } catch (_) {
      throw const RecipeRepositoryException(
        'Ocorreu um erro inesperado ao buscar receitas.',
      );
    }
  }
}

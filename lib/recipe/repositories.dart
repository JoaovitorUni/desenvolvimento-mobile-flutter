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

  Future<RecipeDetailDto> fetchById(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw const RecipeRepositoryException('Recipe not found.');
      }

      if (response.statusCode != 200) {
        throw RecipeRepositoryException(
          'Unable to load recipe details (Error ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected API response.');
      }

      return RecipeDetailDto.fromJson(decoded);
    } on RecipeRepositoryException {
      rethrow;
    } on TimeoutException {
      throw const RecipeRepositoryException(
        'Request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const RecipeRepositoryException(
        'No internet connection. Please try again.',
      );
    } on http.ClientException {
      throw const RecipeRepositoryException(
        'Failed to communicate with the server. Please try again.',
      );
    } on FormatException {
      throw const RecipeRepositoryException(
        'Recipe data arrived in an invalid format.',
      );
    }
  }

  Future<RandomRecipeDto> fetchRandomById(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw const RecipeRepositoryException('Recipe not found.');
      }

      if (response.statusCode != 200) {
        throw RecipeRepositoryException(
          'Unable to load recipe details (Error ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected API response.');
      }

      return RandomRecipeDto.fromJson(decoded);
    } on RecipeRepositoryException {
      rethrow;
    } on TimeoutException {
      throw const RecipeRepositoryException(
        'Request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw const RecipeRepositoryException(
        'No internet connection. Please try again.',
      );
    } on http.ClientException {
      throw const RecipeRepositoryException(
        'Failed to communicate with the server. Please try again.',
      );
    } on FormatException {
      throw const RecipeRepositoryException(
        'Recipe data arrived in an invalid format.',
      );
    }
  }

  Future<List<RecipeDto>> searchByName(String query) async {
    final uri = Uri.parse('$_baseUrl/search')
        .replace(queryParameters: {'q': query});
    return _getRecipesFromUri(uri);
  }

  Future<List<RecipeDto>> _getRecipesFromUri(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw RecipeRepositoryException(
          'Failed to communicate with the server (Error ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['recipes'] is! List) {
        throw const RecipeRepositoryException(
          'The server response arrived in an unexpected format.',
        );
      }

      final rawRecipes = decoded['recipes'] as List<dynamic>;
      return rawRecipes
          .map((item) => RecipeDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const RecipeRepositoryException(
        'No internet connection. Check your network and try again.',
      );
    } on TimeoutException {
      throw const RecipeRepositoryException(
        'The server took too long to respond. Please try again.',
      );
    } on FormatException {
      throw const RecipeRepositoryException(
        'Unable to process data received from the API.',
      );
    } on RecipeRepositoryException {
      rethrow;
    } catch (_) {
      throw const RecipeRepositoryException(
        'An unexpected error occurred while fetching recipes.',
      );
    }
  }
}

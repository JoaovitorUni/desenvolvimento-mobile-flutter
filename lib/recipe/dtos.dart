class RecipeDto {
  final int id;
  final String name;
  final String image;
  final String cuisine;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final double rating;

  const RecipeDto({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.rating,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  factory RecipeDto.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int || json['name'] is! String) {
      throw const FormatException('Estrutura de receita incompatível.');
    }

    return RecipeDto(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image']?.toString() ?? '',
      cuisine: json['cuisine']?.toString() ?? '',
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RecipeDetailDto {
  final int servings;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;

  const RecipeDetailDto({
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
  });

  factory RecipeDetailDto.fromJson(Map<String, dynamic> json) {
    return RecipeDetailDto(
      servings: (json['servings'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? '-',
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      instructions: (json['instructions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

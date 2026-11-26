import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:cook_roulette/recipe/dtos.dart';
import 'package:cook_roulette/theme/app_theme.dart';

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
  final StreamController<int> _selectedController =
      StreamController<int>.broadcast();
  bool _isSpinning = false;

  @override
  void dispose() {
    _selectedController.close();
    super.dispose();
  }

  void _spin(int itemCount) {
    if (_isSpinning || itemCount == 0) return;

    final nextIndex = Random().nextInt(itemCount);
    setState(() {
      _isSpinning = true;
    });

    _selectedController.add(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.recipes.isEmpty) {
      return const Center(
        child: Text(
          'No recipes available for the roulette.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final recipesToDisplay = widget.recipes.take(8).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            'What to cook today?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Spin the wheel to pick a recipe!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 320,
            child: FortuneWheel(
              selected: _selectedController.stream,
              animateFirst: false,
              onAnimationEnd: () {
                setState(() {
                  _isSpinning = false;
                });
              },
              indicators: const [
                FortuneIndicator(
                  alignment: Alignment.topCenter,
                  child: TriangleIndicator(color: AppColors.accent),
                ),
              ],
              items: [
                for (int i = 0; i < recipesToDisplay.length; i++)
                  FortuneItem(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24, right: 12),
                      child: Text(
                        recipesToDisplay[i].name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: AppColors
                          .rouletteSlices[i % AppColors.rouletteSlices.length],
                      borderColor: AppColors.surface,
                      borderWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isSpinning
                ? null
                : () => _spin(recipesToDisplay.length),
            icon: const Icon(Icons.casino),
            label: Text(_isSpinning ? 'Spinning...' : 'Spin Roulette'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

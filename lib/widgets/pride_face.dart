import 'package:better_todo/data/models/todo_models.dart';
import 'package:better_todo/theme/app_colors.dart';
import 'package:flutter/material.dart';

final class PrideFace extends StatelessWidget {
  const PrideFace({required this.answer, this.size = 24, super.key});

  final PrideAnswer answer;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      switch (answer) {
        PrideAnswer.yes => Icons.sentiment_very_satisfied,
        PrideAnswer.middle => Icons.sentiment_neutral,
        PrideAnswer.no => Icons.sentiment_dissatisfied,
      },
      size: size,
      color: switch (answer) {
        PrideAnswer.yes => AppColors.moodPositive,
        PrideAnswer.middle => AppColors.yellow,
        PrideAnswer.no => AppColors.moodNegative,
      },
    );
  }
}

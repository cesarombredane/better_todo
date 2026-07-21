import 'package:better_todo/theme/app_colors.dart';
import 'package:flutter/material.dart';

final class AssigneeLabel extends StatelessWidget {
  const AssigneeLabel({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.person_outline,
          size: 15,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 72),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

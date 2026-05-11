import 'package:flutter/material.dart';
import '../../shared/styles/app_colors.dart';

class KnowledgePointsBadge extends StatelessWidget {
  final int points;

  const KnowledgePointsBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33F59E0B), Color(0x33EA580C)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.amber.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.amberLight, size: 16),
          const SizedBox(width: 6),
          Text(
            '$points',
            style: const TextStyle(
              color: AppColors.amberLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'KP',
            style: TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

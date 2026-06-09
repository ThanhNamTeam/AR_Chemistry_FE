import 'package:flutter/material.dart';
import '../../shared/styles/app_colors.dart';

class KnowledgePointsBadge extends StatelessWidget {
  final int points;
  final bool compact;

  const KnowledgePointsBadge({
    super.key,
    required this.points,
    this.compact = false,
  });

  String get _displayPoints {
    if (!compact) return '$points';
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
    if (points >= 10000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return '$points';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x33F59E0B), Color(0x33EA580C)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.amber.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.amberLight,
            size: compact ? 14 : 16,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            _displayPoints,
            style: TextStyle(
              color: AppColors.amberLight,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 14,
            ),
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            'KP',
            style: TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

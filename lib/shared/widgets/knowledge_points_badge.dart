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
    // KP giữ MỘT màu vàng định danh ở mọi theme (P2-7): không dùng token
    // amber vì theme Light ghi đè dải đó sang xanh. Vàng đậm trên nền sáng
    // (4,8:1), vàng tươi trên nền tối.
    final textColor =
        AppColors.isLight ? AppColors.kpGold : AppColors.kpGoldBright;
    final unitColor =
        AppColors.isLight ? AppColors.kpGold : const Color(0xFFFDE68A);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.isLight ? Colors.white : null,
        gradient: AppColors.isLight
            ? null
            : const LinearGradient(
                colors: [Color(0x33F59E0B), Color(0x33EA580C)],
              ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: AppColors.kpGoldBorder.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: textColor,
            size: compact ? 14 : 16,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            _displayPoints,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 14,
            ),
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            'KP',
            style: TextStyle(
              color: unitColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

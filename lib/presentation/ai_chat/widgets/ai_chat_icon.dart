import 'package:flutter/material.dart';

/// Shared AI chat avatar used by the floating button and chat header.
class AiChatIcon extends StatelessWidget {
  const AiChatIcon({
    super.key,
    required this.size,
  });

  static const assetPath = 'assets/images/ai_chat_fab_icon.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

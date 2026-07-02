import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_portal.dart';
import '../../ai_chat/providers/ai_fab_visibility.dart';
import '../../ai_chat/widgets/ai_floating_assistant.dart';
import '../../home/providers/app_state.dart';
import '../../home/providers/theme_provider.dart';

/// Nút AI nổi trên mọi màn hình cổng người dùng (đã đăng nhập).
class UserPortalAiOverlay extends StatelessWidget {
  const UserPortalAiOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<ThemeProvider>().activePortal;
    final loggedIn = context.watch<AppState>().isLoggedIn;
    final fabVisible = context.watch<AiFabVisibility>().visible;
    final showFab = portal == AppPortal.user && loggedIn && fabVisible;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        context.read<AiFabVisibility>().onScrollNotification(notification);
        return false;
      },
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          child,
          if (showFab) const AiFloatingAssistant(),
        ],
      ),
    );
  }
}

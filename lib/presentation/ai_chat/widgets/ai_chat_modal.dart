import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_navigator.dart';
import '../providers/ai_fab_visibility.dart';
import 'ai_chat_panel.dart';

class AiChatModal {
  AiChatModal._();

  /// Dùng [AppNavigator] vì nút nổi nằm ngoài cây Navigator của [MaterialApp.builder].
  static Future<void> show() {
    final navContext = AppNavigator.key.currentContext;
    if (navContext == null) return Future.value();

    final fabVisibility =
        Provider.of<AiFabVisibility>(navContext, listen: false);
    fabVisibility.hide();

    return showModalBottomSheet<void>(
      context: navContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => const _AiChatSheet(),
    ).whenComplete(fabVisibility.show);
  }
}

class _AiChatSheet extends StatelessWidget {
  const _AiChatSheet();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.9;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top * 0.15),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SizedBox(
          height: height,
          child: AiChatPanel(
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

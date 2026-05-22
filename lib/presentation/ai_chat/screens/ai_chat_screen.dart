import 'package:flutter/material.dart';

import '../widgets/ai_chat_panel.dart';

/// Màn full-screen (giữ route cũ); UI chính dùng modal từ nút nổi.
class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AiChatPanel(
      onClose: () => Navigator.of(context).pop(),
    );
  }
}

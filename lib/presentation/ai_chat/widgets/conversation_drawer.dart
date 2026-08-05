import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/ai_chat_models.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/chat_provider.dart';

class ConversationDrawer extends StatefulWidget {
  const ConversationDrawer({super.key});

  @override
  State<ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends State<ConversationDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final chat = context.read<ChatProvider>();
      if (chat.conversations.isEmpty && !chat.loadingConversations) {
        chat.loadConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Drawer(
      backgroundColor: AppColors.backgroundMid,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lịch sử chat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      chat.startNewConversation();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.add_comment_outlined,
                        color: AppColors.primary),
                    tooltip: 'Cuộc trò chuyện mới',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _NewChatButton(
                onTap: () {
                  chat.startNewConversation();
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _ConversationList(chat: chat)),
          ],
        ),
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Cuộc trò chuyện mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.chat});

  final ChatProvider chat;

  @override
  Widget build(BuildContext context) {
    if (chat.loadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chat.conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Chưa có cuộc trò chuyện.\nHãy hỏi AI một câu hóa học!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: chat.conversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = chat.conversations[index];
        final selected = chat.conversationId == item.id;
        return _ConversationTile(
          item: item,
          selected: selected,
          onTap: () async {
            await chat.openConversation(item.id);
            if (context.mounted) Navigator.pop(context);
          },
          onDelete: () => _confirmDelete(context, item),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ConversationSummary item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          l10n.deleteConversationTitle,
          // textPrimary theo theme — Colors.white tàng hình trên theme Light.
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
        ),
        content: Text(
          item.title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteAction,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<ChatProvider>().deleteConversation(item.id);
    }
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final ConversationSummary item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withOpacity(0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          Icons.chat_bubble_outline,
          color: selected ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

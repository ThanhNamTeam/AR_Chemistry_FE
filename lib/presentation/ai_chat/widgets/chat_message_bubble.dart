import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/ai_chat_models.dart';
import '../../../shared/styles/app_colors.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _avatar(Icons.science_outlined, AppColors.primary),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppColors.primaryGradient : null,
                    color: isUser ? null : AppColors.cardBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: AppColors.cardBorder.withValues(alpha: 0.6),
                          ),
                  ),
                  child: isUser
                      ? SelectableText(
                          message.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        )
                      : _AssistantMarkdown(content: message.content),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CopyButton(content: message.content),
                      if (message.reusedMemory) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: _memoryBadge(
                            context,
                            message.similarityScore,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar(Icons.person_outline, AppColors.accent),
        ],
      ),
    );
  }

  Widget _avatar(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _memoryBadge(BuildContext context, double? score) {
    final l10n = AppLocalizations.of(context);
    // Nhãn phải nói rõ đây là CACHE (câu hỏi tương tự từng gặp) chứ không phải
    // độ tin cậy — "(100%)" trần trụi dễ bị hiểu nhầm là "chắc chắn đúng 100%".
    final label = score != null
        ? l10n.aiMemoryBadge((score * 100).toStringAsFixed(0))
        : l10n.aiMemoryBadgeNoScore;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: AppColors.secondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.secondaryLight,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút sao chép câu trả lời AI — chọn-kéo thủ công trên màn điện thoại với
/// câu trả lời markdown dài rất khổ sở.
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: l10n.aiCopyAnswer,
      icon: Icon(Icons.copy, size: 15, color: AppColors.textSecondary),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: content));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.copiedToClipboard),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class _AssistantMarkdown extends StatelessWidget {
  const _AssistantMarkdown({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textPrimary;
    final mutedColor = AppColors.textSecondary;
    final borderColor = AppColors.cardBorder.withValues(alpha: 0.75);
    final codeBg = AppColors.backgroundDark.withValues(alpha: 0.72);
    final inlineCodeBg = AppColors.primary.withValues(alpha: 0.12);

    final baseTextStyle = TextStyle(
      fontSize: 15,
      height: 1.55,
      color: textColor,
      fontFamily: 'Inter',
    );

    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: baseTextStyle,
        strong: baseTextStyle.copyWith(fontWeight: FontWeight.w700),
        em: baseTextStyle.copyWith(fontStyle: FontStyle.italic),
        h1: baseTextStyle.copyWith(
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w800,
        ),
        h2: baseTextStyle.copyWith(
          fontSize: 21,
          height: 1.3,
          fontWeight: FontWeight.w800,
        ),
        h3: baseTextStyle.copyWith(
          fontSize: 18,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
        h4: baseTextStyle.copyWith(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
        h5: baseTextStyle.copyWith(
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
        h6: baseTextStyle.copyWith(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: mutedColor,
        ),
        blockquote: baseTextStyle.copyWith(color: mutedColor),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        code: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.secondaryLight,
          backgroundColor: inlineCodeBg,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        tableHead: baseTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        tableBody: baseTextStyle.copyWith(fontSize: 14),
        tableBorder: TableBorder.all(color: borderColor),
        tableColumnWidth: const IntrinsicColumnWidth(),
        tableCellsPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        tableCellsDecoration: BoxDecoration(
          color: AppColors.backgroundDark.withValues(alpha: 0.16),
        ),
        tableScrollbarThumbVisibility: true,
        listBullet: baseTextStyle,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }
}

class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.science_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.cardBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    final t = (_controller.value + i * 0.2) % 1.0;
                    final opacity = 0.35 + 0.65 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI đang trả lời...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

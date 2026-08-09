import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/feedback_api_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/admin_feedback_list_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/portal_scaffold.dart';
import 'my_feedback_detail_screen.dart';

class MyFeedbacksScreen extends StatefulWidget {
  const MyFeedbacksScreen({super.key});

  @override
  State<MyFeedbacksScreen> createState() => _MyFeedbacksScreenState();
}

class _MyFeedbacksScreenState extends State<MyFeedbacksScreen> {
  final _api = FeedbackApiService();

  bool _loading = true;
  List<AdminFeedbackListModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _loading = true);

    try {
      final result = await _api.getMyFeedbacks(page: 0, size: 20);

      if (!mounted) return;

      setState(() {
        _items = result.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotLoadFeedback('$e')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _statusColor(String status) => switch (status) {
    'OPEN' => AppColors.amber,
    'IN_PROGRESS' => AppColors.primary,
    'RESOLVED' => AppColors.success,
    'REJECTED' => AppColors.error,
    _ => AppColors.textSecondary,
  };

  Color _priorityColor(String priority) => switch (priority) {
    'LOW' => AppColors.textSecondary,
    'MEDIUM' => AppColors.secondary,
    'HIGH' => AppColors.amber,
    'URGENT' => AppColors.error,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PortalScaffold(
      title: l10n.myFeedbacks,
      showBack: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
        child: Text(
          l10n.myFeedbacksEmpty,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadFeedbacks,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final f = _items[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyFeedbackDetailScreen(
                        feedbackId: f.id,
                      ),
                    ),
                  );

                  if (mounted) unawaited(_loadFeedbacks());
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cardBorder.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Badge(
                            text: f.status,
                            color: _statusColor(f.status),
                          ),
                          const SizedBox(width: 8),
                          _Badge(
                            text: f.priority,
                            color: _priorityColor(f.priority),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        f.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.typeWithValue(f.type),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

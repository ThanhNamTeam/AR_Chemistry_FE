import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/admin_log_api.dart';
import '../../../core/config/env_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';

/// Tab xem log hệ thống từ bộ ELK ngay trong Admin Portal.
///
/// Log đọc qua backend proxy `/admin/logs` (ROLE_ADMIN) — Elasticsearch không
/// mở ra ngoài. Nút "Kibana" mở dashboard đầy đủ trên trình duyệt cho các
/// truy vấn sâu hơn.
class AdminLogsTab extends StatefulWidget {
  const AdminLogsTab({super.key});

  @override
  State<AdminLogsTab> createState() => _AdminLogsTabState();
}

class _AdminLogsTabState extends State<AdminLogsTab> {
  static const _levels = ['ALL', 'INFO', 'WARN', 'ERROR'];
  static const _windows = <(int, String)>[
    (60, '1 giờ'),
    (1440, '24 giờ'),
    (10080, '7 ngày'),
  ];

  final AdminLogApi _api = AdminLogApi();
  final _searchCtrl = TextEditingController();

  final List<AdminLogEntry> _items = [];
  int _total = 0;
  int _page = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  String _level = 'ALL';
  int _minutes = 1440;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({required bool refresh}) async {
    if (refresh) {
      setState(() {
        _loading = _items.isEmpty;
        _error = null;
        _page = 0;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final nextPage = refresh ? 0 : _page + 1;
      final result = await _api.getLogs(
        level: _level,
        q: _searchCtrl.text,
        minutes: _minutes,
        page: nextPage,
        size: 50,
      );
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _total = result.total;
        if (refresh) {
          _items
            ..clear()
            ..addAll(result.items);
        } else {
          _items.addAll(result.items);
        }
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _openKibana() async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(EnvConfig.kibanaUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotOpenKibana(EnvConfig.kibanaUrl)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _levelColor(String level) => switch (level) {
        'ERROR' => AppColors.error,
        'WARN' => AppColors.warning,
        'DEBUG' => AppColors.textSecondary,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.systemLogsTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openKibana,
                icon: const Icon(Icons.open_in_new, size: 15),
                label: const Text('Kibana'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onSubmitted: (_) => _load(refresh: true),
            textInputAction: TextInputAction.search,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: l10n.searchLogsHint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 13,
                fontFamily: 'Inter',
              ),
              prefixIcon:
                  Icon(Icons.search, size: 18, color: AppColors.primary),
              isDense: true,
              filled: true,
              fillColor: AppColors.cardSurfaceMuted,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: [
              ..._levels.map((lv) {
                final selected = _level == lv;
                final color =
                    lv == 'ALL' ? AppColors.primary : _levelColor(lv);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(lv == 'ALL' ? l10n.allLevels : lv),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _level = lv);
                      _load(refresh: true);
                    },
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : color,
                      fontFamily: 'Inter',
                    ),
                    selectedColor: color,
                    backgroundColor: color.withValues(alpha: 0.1),
                    side: BorderSide(color: color.withValues(alpha: 0.4)),
                    visualDensity: VisualDensity.compact,
                    showCheckmark: false,
                  ),
                );
              }),
              const SizedBox(width: 4),
              ..._windows.map(((int, String) w) {
                final selected = _minutes == w.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(w.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _minutes = w.$1);
                      _load(refresh: true);
                    },
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    selectedColor: AppColors.accent,
                    backgroundColor:
                        AppColors.textSecondary.withValues(alpha: 0.08),
                    side: BorderSide(
                        color:
                            AppColors.textSecondary.withValues(alpha: 0.3)),
                    visualDensity: VisualDensity.compact,
                    showCheckmark: false,
                  ),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Text(
            l10n.logCountLabel(_items.length, _total),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(child: _buildList(l10n)),
      ],
    );
  }

  Widget _buildList(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 44, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _load(refresh: true),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.tryAgainAction),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          l10n.noLogsFound,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: _items.length + (_items.length < _total ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return Center(
              child: _loadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: () => _load(refresh: false),
                      child: Text(l10n.loadMoreLogs),
                    ),
            );
          }
          return _LogTile(
            entry: _items[index],
            levelColor: _levelColor(_items[index].level),
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry, required this.levelColor});

  final AdminLogEntry entry;
  final Color levelColor;

  @override
  Widget build(BuildContext context) {
    final time = entry.timestamp == null
        ? '—'
        : DateFormat('dd/MM HH:mm:ss').format(entry.timestamp!.toLocal());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.cardBorder.withValues(alpha: 0.4)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          leading: Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.level,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: levelColor,
                fontFamily: 'Inter',
              ),
            ),
          ),
          title: Text(
            entry.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              height: 1.35,
            ),
          ),
          subtitle: Text(
            time,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          children: [
            _detail('Class', entry.className),
            _detail('Method', entry.methodName),
            _detail('Thời gian xử lý',
                entry.durationMs == null ? null : '${entry.durationMs} ms'),
            _detail('Correlation ID', entry.correlationId),
            _detail('Message đầy đủ', entry.message),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/admin_user_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/admin_user_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../auth/providers/role_session_provider.dart';

/// Tab quản lý người dùng cho admin.
///
/// Backend đã có sẵn toàn bộ endpoint (/admin/users) — tab này chỉ là UI:
/// - Danh sách phân trang + kéo làm mới + tìm kiếm (lọc client trên các trang
///   đã tải, vì API list chưa hỗ trợ tham số search).
/// - Chạm user → bottom sheet: đổi trạng thái, gán vai trò, đặt lại mật khẩu,
///   xoá mềm. Hành động nguy hiểm đều có xác nhận; nút khoá khi đang xử lý.
/// - Chặn admin tự thao tác trên chính tài khoản mình (tự khoá/tự hạ quyền).
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final AdminUserApi _api = AdminUserApi();
  final TextEditingController _searchCtrl = TextEditingController();

  final List<AdminUserModel> _users = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasNext = false;
  String? _error;
  int _page = 0;
  String _query = '';

  static const _statusOptions = ['ACTIVE', 'INACTIVE', 'BLOCKED'];
  static const _roleOptions = [
    'ROLE_STUDENT',
    'ROLE_TEACHER',
    'ROLE_STAFF',
    'ROLE_ADMIN',
  ];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pageData = await _api.getUsers(page: 0);
      if (!mounted) return;
      setState(() {
        _users
          ..clear()
          ..addAll(pageData.items);
        _hasNext = pageData.hasNext;
        _page = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasNext) return;
    setState(() => _loadingMore = true);
    try {
      final pageData = await _api.getUsers(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _users.addAll(pageData.items);
        _hasNext = pageData.hasNext;
        _page += 1;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      _toast(AppLocalizations.of(context).userMgmtLoadFailed, isError: true);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Thay user trong danh sách bằng bản mới sau khi BE cập nhật thành công.
  void _replace(AdminUserModel updated) {
    final i = _users.indexWhere((u) => u.cognitoSub == updated.cognitoSub);
    if (i >= 0) setState(() => _users[i] = updated);
  }

  bool _isSelf(AdminUserModel user) {
    final myEmail = context.read<RoleSessionProvider>().email;
    return myEmail != null &&
        myEmail.toLowerCase() == user.email.toLowerCase();
  }

  List<AdminUserModel> get _visible {
    if (_query.isEmpty) return _users;
    final q = _query.toLowerCase();
    return _users
        .where((u) =>
            u.email.toLowerCase().contains(q) ||
            (u.fullName ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            l10n.userMgmtTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: l10n.userMgmtSearchHint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 13,
              ),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              isDense: true,
              filled: true,
              fillColor: AppColors.cardSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.cardBorder.withValues(alpha: .5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.cardBorder.withValues(alpha: .5)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ErrorCard(
              message: l10n.userMgmtLoadFailed,
              retryLabel: l10n.userMgmtRetry,
              onRetry: _reload,
            )
          else if (_visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  l10n.userMgmtEmpty,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            )
          else ...[
            ..._visible.map((u) => _UserCard(
                  user: u,
                  isSelf: _isSelf(u),
                  onTap: () => _openDetail(u),
                )),
            if (_hasNext && _query.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: _loadingMore ? null : _loadMore,
                    child: _loadingMore
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.userMgmtLoadMore),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _openDetail(AdminUserModel user) async {
    final l10n = AppLocalizations.of(context);
    if (_isSelf(user)) {
      _toast(l10n.userMgmtSelfWarning, isError: true);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _UserDetailSheet(
        user: user,
        api: _api,
        statusOptions: _statusOptions,
        roleOptions: _roleOptions,
        onUpdated: (u) {
          _replace(u);
          _toast(AppLocalizations.of(context).userMgmtUpdated);
        },
        onDeleted: () {
          setState(
              () => _users.removeWhere((u) => u.cognitoSub == user.cognitoSub));
          _toast(AppLocalizations.of(context).userMgmtDeleted);
        },
        onError: (msg) => _toast(msg, isError: true),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isSelf,
    required this.onTap,
  });

  final AdminUserModel user;
  final bool isSelf;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (user.status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'BLOCKED':
      case 'DELETED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.cardBorder.withValues(alpha: .5)),
            ),
            child: Row(
              children: [
                _Avatar(user: user),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName + (isSelf ? ' (you)' : ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _Chip(
                            text: l10n.userStatusLabel(user.status),
                            color: _statusColor,
                          ),
                          ...user.roles.map(
                            (r) => _Chip(
                              text: l10n.roleLabel(r),
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet chi tiết + hành động. Mọi call đều khoá nút (busy) và trả
/// kết quả qua callback để tab cập nhật danh sách tại chỗ.
class _UserDetailSheet extends StatefulWidget {
  const _UserDetailSheet({
    required this.user,
    required this.api,
    required this.statusOptions,
    required this.roleOptions,
    required this.onUpdated,
    required this.onDeleted,
    required this.onError,
  });

  final AdminUserModel user;
  final AdminUserApi api;
  final List<String> statusOptions;
  final List<String> roleOptions;
  final ValueChanged<AdminUserModel> onUpdated;
  final VoidCallback onDeleted;
  final ValueChanged<String> onError;

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  late AdminUserModel _user = widget.user;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        widget.onError(AppLocalizations.of(context).userMgmtActionFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setStatus(String status) => _run(() async {
        final updated = await widget.api.updateStatus(_user.cognitoSub, status);
        if (!mounted) return;
        setState(() => _user = updated);
        widget.onUpdated(updated);
      });

  Future<void> _toggleRole(String role) => _run(() async {
        final roles = List<String>.from(_user.roles);
        roles.contains(role) ? roles.remove(role) : roles.add(role);
        // Không cho bỏ trống vai trò — BE yêu cầu ít nhất một.
        if (roles.isEmpty) return;
        final updated = await widget.api.assignRoles(_user.cognitoSub, roles);
        if (!mounted) return;
        setState(() => _user = updated);
        widget.onUpdated(updated);
      });

  Future<bool> _confirm(String message, {bool danger = false}) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        content: Text(
          message,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: danger
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(l10n.userMgmtResetPasswordConfirm)) return;
    await _run(() async {
      final message = await widget.api.resetPassword(_user.cognitoSub);
      if (!mounted) return;
      // Mật khẩu tạm chỉ hiện MỘT lần — dialog riêng để admin kịp copy.
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text(
            l10n.userMgmtResetPassword,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SelectableText(
            message,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(l10n.userMgmtDeleteConfirm, danger: true)) return;
    await _run(() async {
      await widget.api.softDelete(_user.cognitoSub);
      if (!mounted) return;
      widget.onDeleted();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(user: _user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      _user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel(l10n.userMgmtStatusLabel),
          Wrap(
            spacing: 8,
            children: widget.statusOptions.map((s) {
              final selected = _user.status == s;
              return ChoiceChip(
                label: Text(l10n.userStatusLabel(s)),
                selected: selected,
                onSelected:
                    _busy || selected ? null : (_) => _setStatus(s),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _SectionLabel(l10n.userMgmtRolesLabel),
          Wrap(
            spacing: 8,
            children: widget.roleOptions.map((r) {
              final selected = _user.roles.contains(r);
              return FilterChip(
                label: Text(l10n.roleLabel(r)),
                selected: selected,
                onSelected: _busy ? null : (_) => _toggleRole(r),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _resetPassword,
                  icon: const Icon(Icons.lock_reset, size: 18),
                  label: Text(l10n.userMgmtResetPassword),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: .6)),
                  ),
                  onPressed: _busy ? null : _delete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.userMgmtDelete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AdminUserModel user;

  @override
  Widget build(BuildContext context) {
    final url = user.avatarUrl;
    final hasImage =
        url != null && (url.startsWith('http://') || url.startsWith('https://'));
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary.withValues(alpha: .18),
      backgroundImage: hasImage ? NetworkImage(url) : null,
      child: hasImage
          ? null
          : Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.error.withValues(alpha: .4)),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off, color: AppColors.error, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

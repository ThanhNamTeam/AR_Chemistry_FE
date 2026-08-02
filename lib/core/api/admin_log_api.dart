import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../services/auth_token_service.dart';

/// Một dòng log đọc từ ELK qua backend proxy.
class AdminLogEntry {
  final DateTime? timestamp;
  final String level;
  final String message;
  final String? className;
  final String? methodName;
  final int? durationMs;
  final String? correlationId;

  const AdminLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.className,
    this.methodName,
    this.durationMs,
    this.correlationId,
  });

  factory AdminLogEntry.fromJson(Map<String, dynamic> json) {
    return AdminLogEntry(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
      level: (json['level'] as String? ?? 'INFO').toUpperCase(),
      message: json['message'] as String? ?? '(không có message)',
      className: json['className'] as String?,
      methodName: json['methodName'] as String?,
      durationMs: (json['durationMs'] as num?)?.toInt(),
      correlationId: json['correlationId'] as String?,
    );
  }
}

class AdminLogPage {
  final List<AdminLogEntry> items;
  final int total;

  const AdminLogPage({required this.items, required this.total});
}

class AdminLogApi {
  Future<AdminLogPage> getLogs({
    String? level,
    String? q,
    int minutes = 1440,
    int page = 0,
    int size = 50,
  }) async {
    final token = await AuthTokenService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot load logs');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.adminLogsUrl(
        level: level,
        q: q,
        minutes: minutes,
        page: page,
        size: size,
      )),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => AdminLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      return AdminLogPage(
        items: items,
        total: (data['total'] as num?)?.toInt() ?? items.length,
      );
    }

    throw Exception(
      'Load logs failed: ${response.statusCode} - ${response.body}',
    );
  }
}


import 'dart:convert';

import 'package:taskmaster_flutter/core/api_client.dart';

import '../../models/notifications/NotificationDto.dart';


class NotificationsApi {
  final ApiClient _client;

  NotificationsApi({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/v1/notifications/me
  Future<List<NotificationDto>> getMyNotifications() async {
    final res = await _client.get('api/v1/notifications/me');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

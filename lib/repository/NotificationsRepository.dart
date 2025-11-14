
import '../core/notifications/NotificationsApi.dart';
import '../models/notificattions/NotificationDto.dart';

class NotificationsRepository {
  final NotificationsApi _api;

  NotificationsRepository({NotificationsApi? api})
      : _api = api ?? NotificationsApi();

  Future<List<NotificationDto>> getMyNotifications() =>
      _api.getMyNotifications();
}

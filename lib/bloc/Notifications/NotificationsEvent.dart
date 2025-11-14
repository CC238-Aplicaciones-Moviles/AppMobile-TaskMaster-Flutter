// lib/features/notifications/bloc/notifications_event.dart
part of 'NotificationsBloc.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

/// Cargar las notificaciones del usuario actual (/notifications/me)
class NotificationsFetchRequested extends NotificationsEvent {
  const NotificationsFetchRequested();
}

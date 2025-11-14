part of 'NotificationsBloc.dart';

abstract class NotificationsState {
  const NotificationsState();
}

/// Para futuros estados de acción (snackbar, navegación, etc.)
abstract class NotificationsActionState extends NotificationsState {
  const NotificationsActionState();
}

/// Estado inicial
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// Cargando notificaciones
class NotificationsLoadInProgress extends NotificationsState {
  const NotificationsLoadInProgress();
}

/// Notificaciones cargadas correctamente
class NotificationsLoadSuccess extends NotificationsState {
  final List<NotificationDto> notifications;

  const NotificationsLoadSuccess({required this.notifications});
}

/// Error al cargar notificaciones
class NotificationsFailure extends NotificationsState {
  final String message;

  const NotificationsFailure({required this.message});
}

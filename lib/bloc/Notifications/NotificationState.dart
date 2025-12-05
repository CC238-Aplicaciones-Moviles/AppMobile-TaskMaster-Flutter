part of 'NotificationBloc.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationDto> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

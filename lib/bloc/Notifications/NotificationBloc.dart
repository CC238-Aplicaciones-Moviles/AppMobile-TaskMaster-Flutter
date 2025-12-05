import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notifications/NotificationDto.dart';
import '../../repository/NotificationsRepository.dart';

part 'NotificationEvent.dart';
part 'NotificationState.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationsRepository _repository;

  NotificationBloc({NotificationsRepository? repository})
      : _repository = repository ?? NotificationsRepository(),
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.getMyNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}

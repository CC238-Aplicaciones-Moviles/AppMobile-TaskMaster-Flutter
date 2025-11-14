import 'package:bloc/bloc.dart';

import '../../models/notificattions/NotificationDto.dart';
import '../../repository/NotificationsRepository.dart';


part 'NotificationsEvent.dart';
part 'NotificationsState.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc({NotificationsRepository? repository})
      : _repository = repository ?? NotificationsRepository(),
        super(NotificationsInitial()) {
    on<NotificationsFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
      NotificationsFetchRequested event,
      Emitter<NotificationsState> emit,
      ) async {
    emit(NotificationsLoadInProgress());
    try {
      final notifications = await _repository.getMyNotifications();
      emit(NotificationsLoadSuccess(notifications: notifications));
    } catch (e) {
      emit(NotificationsFailure(message: e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/notification/notification_event.dart';
import 'package:map/bloc/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationState()) {

    on<NotificationInitEvent>((event, emit) async {
      await _init(emit);
    });
    add(NotificationInitEvent());
  }

  Future<void> _init(Emitter<NotificationState> emit) async {}
}

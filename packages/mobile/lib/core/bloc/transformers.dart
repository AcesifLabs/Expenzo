import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

EventTransformer<T> sequential<T>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

EventTransformer<T> restartable<T>() {
  StreamSubscription? subscription;

  return (events, mapper) {
    return events.transform(
      StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          subscription?.cancel();
          subscription = mapper(event).listen(
            (data) => sink.add(data),
            onError: (e, st) => sink.addError(e, st),
            onDone: () => subscription = null,
            cancelOnError: false,
          );
        },
        handleDone: (sink) {
          subscription?.cancel();
          sink.close();
        },
      ),
    );
  };
}

EventTransformer<T> droppable<T>() {
  return (events, mapper) {
    bool running = false;

    return events.transform(
      StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          if (!running) {
            running = true;
            mapper(event).listen(
              (data) => sink.add(data),
              onError: (e, st) => sink.addError(e, st),
              onDone: () => running = false,
              cancelOnError: false,
            );
          }
        },
      ),
    );
  };
}

EventTransformer<T> concurrent<T>() {
  return (events, mapper) {
    final controller = StreamController<T>();
    events.listen(
      (event) {
        mapper(event).listen(
          controller.add,
          onError: controller.addError,
          cancelOnError: false,
        );
      },
      onError: controller.addError,
      onDone: () {
        controller.close();
      },
    );

    return controller.stream;
  };
}

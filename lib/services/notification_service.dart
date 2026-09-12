import 'dart:async';

class NotificationService {
  final _controller = StreamController<NotificationAlert>.broadcast();

  Stream<NotificationAlert> get notificationStream => _controller.stream;

  void triggerMockNotification(String title, String body, {String type = 'info'}) {
    _controller.add(NotificationAlert(
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
    ));
  }

  void dispose() {
    _controller.close();
  }
}

class NotificationAlert {
  final String title;
  final String body;
  final String type; // 'info', 'warning', 'success', 'approaching'
  final DateTime timestamp;

  NotificationAlert({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
  });
}

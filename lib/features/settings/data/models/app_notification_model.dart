import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
  });

  factory AppNotificationModel.fromJson(Map<String, String> json) {
    return AppNotificationModel(
      id: json['id']!,
      title: json['title']!,
      body: json['body']!,
    );
  }
}

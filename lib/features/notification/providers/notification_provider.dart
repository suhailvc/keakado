import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/features/notification/domain/models/notification_model.dart';
import 'package:flutter_grocery/features/notification/domain/reposotories/notification_repo.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepo? notificationRepo;
  NotificationProvider({required this.notificationRepo});

  List<NotificationModel>? _notificationList = [];
  List<NotificationModel>? get notificationList => _notificationList != null
      ? _notificationList!.reversed.toList()
      : _notificationList;
  int _newNotificationCount = 0;
  int get newNotificationCount => _newNotificationCount;
  Future<void> getNotificationList({bool isUpdate = true}) async {
    _notificationList = null;

    if (isUpdate) {
      notifyListeners();
    }

    ApiResponseModel apiResponse =
        await notificationRepo!.getNotificationList();
    if (apiResponse.response?.statusCode == 200) {
      _notificationList = [];
      apiResponse.response!.data.forEach((notificationModel) =>
          _notificationList!
              .add(NotificationModel.fromJson(notificationModel)));
      int newCount = await _getNewNotificationCount(_notificationList!.length);
      _notificationList = _notificationList;
      _newNotificationCount = newCount; // Update local state for the icon
      await _saveNewNotificationCount(newCount);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<int> _getNewNotificationCount(int currentCount) async {
    final prefs = await SharedPreferences.getInstance();
    int previousCount = prefs.getInt('previous_notification_count') ?? 0;
    return currentCount > previousCount ? currentCount - previousCount : 0;
  }

  Future<void> _saveNewNotificationCount(int newCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('new_notification_count', newCount);
    await prefs.setInt(
        'previous_notification_count', _notificationList!.length);
  }

  Future<void> clearNewNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'new_notification_count', 0); // Reset new notification count
    _newNotificationCount = 0; // Update local state
    notifyListeners();
  }

  Future<int> getNewNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('new_notification_count') ?? 0;
  }
}

import 'dart:developer';

import 'package:get/get.dart';
import '../../model/notification_model.dart';
import '../../services/notidication_services.dart';

class NotificationController extends GetxController {
  // Reactive variables
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.getNotificationList();

      if (response.success && response.data != null) {
        notifications.assignAll(response.data!);
        log('Fetched ${notifications.length} notifications');
      } else {
        // errorMessage.value =
        //     response.message ?? 'Failed to fetch notifications';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create a test notification
  Future<void> createTestNotification({
    required List<String> recipients,
    required String title,
    required String body,
    String? courseId,
    String type = 'test',
    String status = 'sent',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.createTestNotification(
        recipients: recipients,
        title: title,
        body: body,
        courseId: courseId,
        type: type,
        status: status,
      );

      log('Notification service response: ${response.success}');
      log('Response message: ${response.message}');
      log('Response data: ${response.data}');

      if (response.success && response.data != null) {
        notifications.add(response.data!);
        await fetchUnreadCount(); // Update unread count
        // Get.snackbar('Success', 'Test notification created successfully');
        log('Test notification created successfully');
      } else {
        // errorMessage.value =
        //     response.message ?? 'Failed to create notification';
        // Get.snackbar('Error', errorMessage.value);
        log('Notification creation failed: ${response.message}');
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      // Get.snackbar('Error', errorMessage.value);
      log('Error creating notification: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.getNotificationById(
        notificationId,
      );

      if (response.success && response.data != null) {
        // Update the notification in the list if it exists
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = response.data!;
        } else {
          notifications.add(response.data!);
        }
        return response.data!;
      } else {
        // errorMessage.value = response.message ?? 'Failed to fetch notification';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error fetching notification by ID: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.deleteNotification(
        notificationId,
      );

      if (response.success && response.data == true) {
        notifications.removeWhere((n) => n.id == notificationId);
        await fetchUnreadCount(); // Update unread count
        Get.snackbar('Success', 'Notification deleted successfully');
      } else {
        // errorMessage.value =
        //     response.message ?? 'Failed to delete notification';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error deleting notification: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    try {
      errorMessage.value = '';

      final response = await NotificationService.getUnreadNotificationCount();

      if (response.success && response.data != null) {
        unreadCount.value = response.data!;
        log('Unread count: ${unreadCount.value}');
      } else {
        // errorMessage.value = response.message ?? 'Failed to fetch unread count';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error fetching unread count: $e');
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.markNotificationAsRead(
        notificationId,
      );

      if (response.success && response.data == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          await fetchUnreadCount(); // Update unread count
          Get.snackbar('Success', 'Notification marked as read');
        }
      } else {
        // errorMessage.value =
        //     response.message ?? 'Failed to mark notification as read';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error marking notification as read: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.markAllNotificationsAsRead();

      if (response.success && response.data == true) {
        notifications.assignAll(
          notifications
              .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
              .toList(),
        );
        await fetchUnreadCount(); // Update unread count
        Get.snackbar('Success', 'All notifications marked as read');
      } else {
        // errorMessage.value =
        //     response.message ?? 'Failed to mark all notifications as read';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error marking all notifications as read: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update notification status
  Future<void> updateNotificationStatus(
    String notificationId,
    NotificationStatus status,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await NotificationService.updateNotificationStatus(
        notificationId,
        status.toJsonString,
      );

      if (response.success && response.data == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
          Get.snackbar(
            'Success',
            'Notification status updated to ${status.toJsonString}',
          );
        }
      } else {
        // errorMessage.value =
        //     response.message ?? 'Failed to update notification status';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      // errorMessage.value = 'Unexpected error: $e';
      Get.snackbar('Error', errorMessage.value);
      log('Error updating notification status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}

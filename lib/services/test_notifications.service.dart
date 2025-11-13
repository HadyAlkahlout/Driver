import 'package:fuodz/models/new_order.dart';

import 'package:fuodz/services/pending_notifications.service.dart';

class TestNotificationsService {
  /// Factory method that reuse same instance automatically
  factory TestNotificationsService() =>
      Singleton.lazy(() => TestNotificationsService._());

  /// Private constructor
  TestNotificationsService._();

  // Create test notifications for development/testing
  void createTestNotifications() {
    print("DEBUG: Creating test notifications...");
    // Create a test regular order
    final testOrder = NewOrder(
      amount: "15.50",
      total: "18.75",
      dropoff: Dropoff(
        lat: 25.2854,
        long: 51.5310,
        address: "The Pearl-Qatar, Doha",
        distance: 5.2,
      ),
      pickup: Pickup(
        lat: 25.2760,
        long: 51.5200,
        address: "Souq Waqif, Doha",
        distance: 0.0,
      ),
      range: 10.0,
      earthDistance: 5.2,
      vendorId: 1,
      isParcel: false,
      packageType: "Standard",
      expiresAt:
          DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch ~/
          1000,
    );
    testOrder.id = 12345;

    // Add to pending notifications
    print("DEBUG: Adding test order to pending notifications...");
    PendingNotificationsService().addPendingOrder(testOrder);
    print("DEBUG: Test notifications created successfully!");
  }

  // Clear all test notifications
  void clearTestNotifications() {
    PendingNotificationsService().clearAllPending();
  }
}

// Singleton helper class
class Singleton {
  static final Map<Type, dynamic> _instances = <Type, dynamic>{};

  static T lazy<T>(T Function() func) {
    return _instances.putIfAbsent(T, () => func()) as T;
  }
}

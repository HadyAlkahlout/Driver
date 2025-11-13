import 'dart:async';
import 'package:fuodz/models/new_order.dart';

import 'package:rxdart/rxdart.dart';

class PendingNotificationsService {
  static final PendingNotificationsService _instance = PendingNotificationsService._internal();
  factory PendingNotificationsService() => _instance;
  PendingNotificationsService._internal();

  // Global set to track all processed order IDs across the entire app
  static final Set<int> _globalProcessedOrderIds = <int>{};
  
  // Track processed notifications to prevent duplicates
  final Set<String> _processedNotifications = <String>{};
  Timer? _cleanupProcessedTimer;

  // Stream controller for pending orders
  final BehaviorSubject<List<NewOrder>> _pendingOrdersStream =
      BehaviorSubject<List<NewOrder>>.seeded([]);

  // Getters for streams
  Stream<List<NewOrder>> get pendingOrdersStream => _pendingOrdersStream.stream;

  // Current pending notifications
  List<NewOrder> get pendingOrders => _pendingOrdersStream.value;

  // Check if notification was recently processed
  bool isNotificationProcessed(int? orderId) {
    if (orderId == null) return false;
    
    // Check global processed orders first
    if (_globalProcessedOrderIds.contains(orderId)) {
      return true;
    }
    
    // Check if order was processed in the last 5 minutes (instead of 30 seconds)
    final key = 'order_${orderId}_${DateTime.now().millisecondsSinceEpoch ~/ 300000}'; // 5-minute window
    return _processedNotifications.contains(key);
  }

  // Mark notification as processed
  void markNotificationProcessed(int? orderId) {
    if (orderId == null) return;
    
    // Add to global processed orders
    _globalProcessedOrderIds.add(orderId);
    
    // Use 5-minute window for better duplicate prevention
    final key = 'order_${orderId}_${DateTime.now().millisecondsSinceEpoch ~/ 300000}';
    _processedNotifications.add(key);
    print("DEBUG: Marked notification processed: $key (Global: ${_globalProcessedOrderIds.length} orders)");

    // Clean up old entries (older than 10 minutes)
    final currentWindow = DateTime.now().millisecondsSinceEpoch ~/ 300000;
    _processedNotifications.removeWhere((k) {
      final parts = k.split('_');
      if (parts.length >= 3) {
        final window = int.tryParse(parts[2]) ?? 0;
        return (currentWindow - window) > 2; // Remove entries older than 2 windows (10 minutes)
      }
      return true;
    });
    
    // Clean up global processed orders (older than 1 hour)
    if (_globalProcessedOrderIds.length > 100) { // Only clean up if we have many entries
      final oneHourAgo = DateTime.now().millisecondsSinceEpoch - 3600000;
      // For now, just clear all if we have too many (simple approach)
      if (_globalProcessedOrderIds.length > 200) {
        _globalProcessedOrderIds.clear();
        print("DEBUG: Cleared global processed order IDs due to high count");
      }
    }
  }

  // Add a new order notification
  void addPendingOrder(NewOrder order) {
    // Skip if order has no valid ID
    if (order.id == null) {
      print("DEBUG: Order has no ID, skipping");
      return;
    }

    // Check if this notification was recently processed
    if (isNotificationProcessed(order.id)) {
      print("DEBUG: Skipping duplicate notification for order ${order.id} - already processed recently");
      return;
    }

    final currentOrders = List<NewOrder>.from(pendingOrders);

    // Check if order already exists (avoid duplicates)
    final existingIndex = currentOrders.indexWhere((o) => o.id == order.id);
    if (existingIndex != -1) {
      print(
        "DEBUG: Order ${order.id} already exists in pending list, skipping duplicate",
      );
      return;
    }
    
    // Additional check: if we have any order with the same ID in the last 10 minutes, skip it
    final recentOrderExists = _processedNotifications.any((key) {
      if (key.startsWith('order_${order.id}_')) {
        return true;
      }
      return false;
    });
    
    if (recentOrderExists) {
      print("DEBUG: Order ${order.id} was processed recently, skipping duplicate notification");
      return;
    }
    
    // Additional check: if this order ID appears in any processed notification, skip it
    final anyOrderWithSameId = _processedNotifications.any((key) {
      final parts = key.split('_');
      if (parts.length >= 2) {
        final orderId = int.tryParse(parts[1]);
        return orderId == order.id;
      }
      return false;
    });
    
    if (anyOrderWithSameId) {
      print("DEBUG: Order ${order.id} ID found in processed notifications, skipping duplicate");
      return;
    }
    
    // Final check: if this order ID is in the global processed set, skip it
    if (_globalProcessedOrderIds.contains(order.id)) {
      print("DEBUG: Order ${order.id} found in global processed orders, skipping duplicate");
      return;
    }

    // Add new order
    currentOrders.add(order);
    print(
      "DEBUG: Added pending order ${order.id}, total: ${currentOrders.length}",
    );
    
    // Mark as processed to prevent duplicates
    markNotificationProcessed(order.id);

    _pendingOrdersStream.add(currentOrders);
  }

  // Remove an order notification (when accepted/rejected/expired)
  void removePendingOrder(int orderId) {
    final currentOrders = List<NewOrder>.from(pendingOrders);
    currentOrders.removeWhere((order) => order.id == orderId);
    _pendingOrdersStream.add(currentOrders);
  }

  // Clear all pending notifications
  void clearAllPending() {
    _pendingOrdersStream.add([]);
  }
  
  // Clear global processed orders (useful for testing or when switching drivers)
  void clearGlobalProcessedOrders() {
    _globalProcessedOrderIds.clear();
    print("DEBUG: Cleared global processed order IDs");
  }
  
  // Get count of global processed orders (for debugging)
  int get globalProcessedCount => _globalProcessedOrderIds.length;

  // Check if there are any pending notifications
  bool get hasPendingNotifications {
    return pendingOrders.isNotEmpty;
  }

  // Get total count of pending notifications
  int get pendingCount {
    return pendingOrders.length;
  }

  // Remove order by ID (when taken by another driver or accepted)
  void removeOrderById(int orderId) {
    print("DEBUG: Removing order $orderId from pending notifications service");

    // Remove from regular orders
    final currentOrders = List<NewOrder>.from(pendingOrders);
    final originalLength = currentOrders.length;
    currentOrders.removeWhere((order) => order.id == orderId);
    if (currentOrders.length < originalLength) {
      print("DEBUG: Removed regular order $orderId from pending list");
      _pendingOrdersStream.add(currentOrders);
    }
  }

  // Auto-remove expired notifications
  void removeExpiredNotifications() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Remove expired regular orders
    final currentOrders = List<NewOrder>.from(pendingOrders);
    currentOrders.removeWhere((order) => order.expiresAt < now);
    _pendingOrdersStream.add(currentOrders);
  }

  // Start periodic cleanup of expired notifications
  Timer? _cleanupTimer;

  void startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    // Reduced frequency: every 30 seconds instead of 5 seconds
    _cleanupTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      removeExpiredNotifications();
    });

    // Start cleanup of processed notifications tracking
    _cleanupProcessedTimer?.cancel();
    // Increased interval: every 5 minutes instead of 2 minutes
    _cleanupProcessedTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      final currentWindow = DateTime.now().millisecondsSinceEpoch ~/ 30000;
      final beforeCount = _processedNotifications.length;
      _processedNotifications.removeWhere((k) {
        final parts = k.split('_');
        if (parts.length >= 3) {
          final window = int.tryParse(parts[2]) ?? 0;
          return (currentWindow - window) >
              10; // Remove entries older than 5 minutes
        }
        return true;
      });
      if (beforeCount != _processedNotifications.length) {
        print(
          "DEBUG: Cleaned up ${beforeCount - _processedNotifications.length} old processed notifications",
        );
      }
    });
  }

  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _cleanupProcessedTimer?.cancel();
    _cleanupProcessedTimer = null;
  }

  // Clear processed notifications tracking
  void clearProcessedNotifications() {
    _processedNotifications.clear();
    print("DEBUG: Cleared all processed notifications tracking");
  }

  // Dispose resources
  void dispose() {
    stopPeriodicCleanup();
    _processedNotifications.clear();
    _pendingOrdersStream.close();
  }
}

// PendingSingleton helper class to avoid naming conflict
class PendingSingleton {
  static final Map<Type, dynamic> _instances = <Type, dynamic>{};

  static T lazy<T>(T Function() func) {
    return _instances.putIfAbsent(T, () => func()) as T;
  }
}

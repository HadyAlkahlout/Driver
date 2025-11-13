import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/services/http.service.dart';

class AutoAssignmentRequest extends HttpService {
  
  /// Get pending auto-assignments for the current driver
  Future<List<Map<String, dynamic>>> getPendingAssignments() async {
    try {
      final apiResult = await get(Api.driverPendingAssignments);
      final apiResponse = ApiResponse.fromResponse(apiResult);
      
      if (apiResponse.allGood) {
        final List<dynamic> pendingOrders = apiResponse.body["pending_orders"] ?? [];
        return pendingOrders.cast<Map<String, dynamic>>();
      } else {
        throw apiResponse.message ?? "Failed to get pending assignments";
      }
    } catch (error) {
      throw error.toString();
    }
  }

  /// Accept an auto-assignment
  Future<Order> acceptAssignment(int assignmentId, int orderId) async {
    try {
      final Map<String, dynamic> payload = {
        "assignment_id": assignmentId,
        "order_id": orderId,
      };

      final apiResult = await post(Api.driverAcceptAssignment, payload);
      final apiResponse = ApiResponse.fromResponse(apiResult);
      
      if (apiResponse.allGood) {
        return Order.fromJson(apiResponse.body["order"]);
      } else {
        throw apiResponse.message ?? "Failed to accept assignment";
      }
    } catch (error) {
      throw error.toString();
    }
  }

  /// Reject an auto-assignment
  Future<bool> rejectAssignment(int assignmentId) async {
    try {
      final Map<String, dynamic> payload = {
        "assignment_id": assignmentId,
      };

      final apiResult = await post(Api.driverRejectAssignment, payload);
      final apiResponse = ApiResponse.fromResponse(apiResult);
      
      if (apiResponse.allGood) {
        return true;
      } else {
        throw apiResponse.message ?? "Failed to reject assignment";
      }
    } catch (error) {
      throw error.toString();
    }
  }
}

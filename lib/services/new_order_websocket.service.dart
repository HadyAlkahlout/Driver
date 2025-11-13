import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/websocket.service.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';

class NewOrderWebsocketService {
  static final NewOrderWebsocketService _instance =
      NewOrderWebsocketService._internal();
  factory NewOrderWebsocketService() => _instance;

  NewOrderWebsocketService._internal();

  PrivateChannel? _eventChannel;
  Function(dynamic data)? _onDataReceived;
  String? _channelName;

  Future<void> connectToOrderChannel(
    Function(dynamic data) onDataReceived,
  ) async {
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    _channelName = "private-driver.new-order.$driverId";
    await WebsocketService().init();
    _onDataReceived = onDataReceived;
    _subscribeToChannel();

    final echo = WebsocketService().echoClient;
    if (echo == null) return;

    // Setup reconnect-related listeners
    echo.connector.onReconnecting((event) {
      print("WebSocket reconnecting...");
    });

    echo.connector.onDisconnect((event) {
      print("WebSocket disconnected.");
    });

    echo.connector.onError((error) {
      print("WebSocket error: $error");
    });

    // Workaround: try to re-subscribe after a short delay assuming reconnect success
    // You may tweak timing or hook this to an external ping/pong monitor if needed
    Future.delayed(Duration(seconds: 10), () {
      if (_channelName != null) {
        print("Re-subscribing to channel: $_channelName");
        _subscribeToChannel();
      }
    });
  }

  void _subscribeToChannel() {
    final echo = WebsocketService().echoClient;
    if (echo == null || _onDataReceived == null || _channelName == null) return;

    try {
      _eventChannel?.unsubscribe(); // Clean previous
    } catch (error) {
      print("Error unsubscribing from channel: $error");
    }
    _eventChannel = echo.private(_channelName!);
    _eventChannel?.subscribe();
    _eventChannel?.listen(".WebsocketDriverNewOrderEvent", (event) {
      print("Received OrderUpdated event: $event");
      _onDataReceived?.call(event);
    });
  }

  Future<void> disconnect() async {
    try {
      _eventChannel?.unsubscribe();
    } catch (error) {
      print("Error ==> $error");
    }
    _eventChannel = null;
    _onDataReceived = null;
  }
}

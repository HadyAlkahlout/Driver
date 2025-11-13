import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class SimpleVideoCallTestPage extends StatefulWidget {
  const SimpleVideoCallTestPage({Key? key}) : super(key: key);

  @override
  State<SimpleVideoCallTestPage> createState() =>
      _SimpleVideoCallTestPageState();
}

class _SimpleVideoCallTestPageState extends State<SimpleVideoCallTestPage> {
  bool _isInitialized = false;
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customerIdController.text = "4";
    _customerNameController.text = "Test Customer";
    _initializeZegoCloud();
  }

  Future<void> _initializeZegoCloud() async {
    try {
      // Initialize ZegoCloud directly without authentication
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 1452620307,
        appSign:
            '8dd923124e1558cd11775f0e41d66558442d6f6dd13c3b817d89d89d4bbecbd7d1c',
        userID: 'driver_3', // This should match the ID the customer is calling
        userName: 'Test Driver',
        plugins: [ZegoUIKitSignalingPlugin()],
        requireConfig: (ZegoCallInvitationData data) {
          final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
          config.topMenuBar.isVisible = true;
          config.bottomMenuBar.isVisible = true;
          return config;
        },
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
            print('Call ended: ${event.reason}');
            defaultAction.call();
          },
        ),
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
          onIncomingCallDeclineButtonPressed: () {
            print('Incoming call declined');
          },
          onIncomingCallAcceptButtonPressed: () {
            print('Incoming call accepted');
          },
          onOutgoingCallCancelButtonPressed: () {
            print('Outgoing call cancelled');
          },
        ),
      );

      setState(() {
        _isInitialized = true;
      });
      print('Driver ZegoCloud initialized successfully!');
    } catch (e) {
      print('Error initializing Driver ZegoCloud: $e');
    }
  }

  Future<void> _makeVideoCall() async {
    try {
      final customerId = _customerIdController.text;
      final customerName = _customerNameController.text;

      print('Driver making video call to: $customerName ($customerId)');

      await ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: true,
        invitees: [ZegoCallUser('customer_$customerId', customerName)],
        customData: 'Test video call from driver app',
      );

      print('Driver video call invitation sent!');
    } catch (e) {
      print('Error making driver video call: $e');
    }
  }

  Future<void> _makeVoiceCall() async {
    try {
      final customerId = _customerIdController.text;
      final customerName = _customerNameController.text;

      print('Driver making voice call to: $customerName ($customerId)');

      await ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: false,
        invitees: [ZegoCallUser('customer_$customerId', customerName)],
        customData: 'Test voice call from driver app',
      );

      print('Driver voice call invitation sent!');
    } catch (e) {
      print('Error making driver voice call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Video Call Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Driver ZegoCloud Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isInitialized ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isInitialized ? 'READY TO RECEIVE CALLS' : 'NOT READY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Customer Info (for outgoing calls)
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(
                labelText: 'Customer ID',
                border: OutlineInputBorder(),
                hintText: 'e.g., 4',
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Test Customer',
              ),
            ),

            SizedBox(height: 20),

            // Call Buttons
            ElevatedButton.icon(
              onPressed: _isInitialized ? _makeVideoCall : null,
              icon: Icon(Icons.videocam),
              label: Text('Call Customer (Video)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isInitialized ? _makeVoiceCall : null,
              icon: Icon(Icons.call),
              label: Text('Call Customer (Voice)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            SizedBox(height: 20),

            // Instructions
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Testing Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Make sure both Customer and Driver apps are running',
                    ),
                    Text('2. Customer app should call "driver_3"'),
                    Text('3. Driver app should show incoming call screen'),
                    Text('4. Accept call to see video/voice call interface'),
                    Text('5. Or use buttons above to call customer'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Important Note
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ IMPORTANT:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Driver ID must be "driver_3" to receive calls from customer',
                    ),
                    Text('• Customer ID must be "4" to match the test call'),
                    Text('• Both apps must be running ZegoCloud service'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    super.dispose();
  }
}

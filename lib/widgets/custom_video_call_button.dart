import 'package:flutter/material.dart';
import 'package:fuodz/services/custom_video_call.service.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/views/pages/video_call/outgoing_call_screen.dart';

class CustomVideoCallButton extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserPhoto;
  final VoidCallback? onPressed;

  const CustomVideoCallButton({
    Key? key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserPhoto,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (onPressed != null) {
          onPressed!();
        } else {
          try {
            // Show outgoing call screen first
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OutgoingCallScreen(
                  callId: 'call_${targetUserId}_${DateTime.now().millisecondsSinceEpoch}',
                  receiverName: targetUserName,
                  receiverPhoto: targetUserPhoto ?? '',
                  callType: 'video',
                  onCallEnded: () {
                    print('Call ended with $targetUserName');
                  },
                ),
              ),
            );

            // Initiate the actual call
            await CustomVideoCallService.makeVideoCall(
              receiverId: targetUserId,
              receiverName: targetUserName,
              receiverPhoto: targetUserPhoto,
              callType: 'video',
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to initiate video call: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      icon: Icon(Icons.videocam),
      label: Text('Video Call'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

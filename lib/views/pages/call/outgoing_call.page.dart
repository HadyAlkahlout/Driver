import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String callId;
  final String receiverName;
  final String receiverPhoto;
  final String callType;
  final VoidCallback onCallEnded;

  const OutgoingCallScreen({
    Key? key,
    required this.callId,
    required this.receiverName,
    required this.receiverPhoto,
    required this.callType,
    required this.onCallEnded,
  }) : super(key: key);

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  String _callStatus = 'Calling';

  @override
  void initState() {
    super.initState();
    debugPrint(
      '*** CUSTOM DEBUG: OutgoingCallScreen initialized for ${widget.receiverName}',
    );

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();

    // Simulate call status changes
    _updateCallStatus();
  }

  void _updateCallStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _callStatus = 'Connecting';
      });
    }

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _callStatus = 'Ringing';
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _endCall() {
    debugPrint('*** CUSTOM DEBUG: Call ended by driver');
    Navigator.of(context).pop();

    // Cancel the outgoing call through ZegoUIKit
    try {
      // ZegoUIKit will handle the call cancellation automatically
      debugPrint('*** CUSTOM DEBUG: Call cancelled by driver');
    } catch (e) {
      debugPrint('*** CUSTOM DEBUG: Error cancelling call: $e');
    }

    widget.onCallEnded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "${widget.callType == 'video' ? 'Video' : 'Voice'} Call"
                        .tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Calling Customer".tr(),
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Receiver avatar with pulse animation
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Avatar
                              widget.receiverPhoto.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(75),
                                    child: Image.network(
                                      widget.receiverPhoto,
                                      fit: BoxFit.cover,
                                      width: 150,
                                      height: 150,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _buildDefaultAvatar();
                                      },
                                    ),
                                  )
                                  : _buildDefaultAvatar(),

                              // Rotating ring for calling animation
                              AnimatedBuilder(
                                animation: _rotateAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotateAnimation.value * 2 * 3.14159,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Receiver name
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Call status
                  Text(
                    _callStatus.tr(),
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 50),

                  // Call controls
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom info
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (widget.callType == 'video')
                    Text(
                      "Video calling is using your camera and microphone".tr(),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    "Call ID: ${widget.callId.substring(0, 8)}...",
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor,
            AppColor.primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }
}

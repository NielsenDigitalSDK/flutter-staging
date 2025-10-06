import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'video_player_screen.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      // Only run on iOS
      WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
    } else {
      Timer (Duration(seconds: 3), () {
        _navigateToHome();
      });
    }
  }

  _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => VideoPlayerScreen()),
      );
    }
  }

  Future<void> initPlugin() async {
    // Get the current tracking authorization status.
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    // If the tracking authorization status is not determined, we show the dialog.
    if (status == TrackingStatus.notDetermined) {
      // A small delay to allow the UI to settle before showing the dialog.
      await Future.delayed(const Duration(milliseconds: 200));
      // Request tracking authorization. The code will pause here until the user
      // responds to the popup.
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    if (mounted) {
      _navigateToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure you have 'assets/logo.png' or replace with a valid asset
    return Scaffold(
      backgroundColor: Colors.white, // Or your app's splash screen background
      body: Center(
        child: Image.asset(
          'assets/logo.png', // Make sure this asset exists in your pubspec.yaml and assets folder
          width: 200,
          height: 200,
          errorBuilder:
              (context, error, stackTrace) => Icon(
                Icons.ondemand_video,
                size: 100,
              ), // Fallback if logo is missing
        ),
      ),
    );
  }
}

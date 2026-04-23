import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SmsPermissionGate extends StatefulWidget {
  final Widget child;

  const SmsPermissionGate({super.key, required this.child});

  @override
  State<SmsPermissionGate> createState() => _SmsPermissionGateState();
}

class _SmsPermissionGateState extends State<SmsPermissionGate> {
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.sms.status;
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);
    final status = await Permission.sms.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _isLoading = false;
      });
      if (!status.isGranted && status.isPermanentlyDenied) {
        // Show dialog asking to open settings
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'SMS permission is permanently denied. Please enable it in app settings to use the smart scanner.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasPermission) {
      return widget.child;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'SMS Access Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Expenzo needs access to your SMS to automatically track expenses from your bank and payment apps. '
              'Your messages never leave your device.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.check),
              label: const Text('Grant Access', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: _requestPermission,
            ),
          ],
        ),
      ),
    );
  }
}

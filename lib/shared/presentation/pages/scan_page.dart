import 'package:flutter/material.dart';
import '../../../features/message_templates/presentation/pages/contact_selector_page.dart';
import '../widgets/sms_permission_gate.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan SMS')),
      body: const SmsPermissionGate(child: ContactSelectorPage()),
    );
  }
}

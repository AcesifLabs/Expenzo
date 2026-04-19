import 'package:flutter/material.dart';
import '../../../features/email_parser/presentation/pages/email_scan_page.dart';
import '../../../features/message_templates/presentation/pages/contact_selector_page.dart';
import '../widgets/sms_permission_gate.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.sms), text: 'SMS'),
            Tab(icon: Icon(Icons.email), text: 'Email'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          SmsPermissionGate(child: ContactSelectorPage()),
          EmailScanPage(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/sync/sync_status.dart';

class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;
  final int? pendingCount;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (pendingCount != null && pendingCount! > 0) ...[
          const SizedBox(width: 4),
          Text('$pendingCount', style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done, size: 18, color: Colors.grey);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.success:
        return const Icon(Icons.cloud_done, size: 18, color: Colors.green);
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, size: 18, color: Colors.red);
    }
  }
}

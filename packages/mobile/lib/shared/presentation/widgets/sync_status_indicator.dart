import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import '../../services/sync/sync_status.dart';

class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;
  final int? pendingCount;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.pendingCount,
  });

  Widget _buildIcon() {
    switch (status) {
      case SyncStatus.idle:
        return Icon(PiconsRegular.cloud, size: 18, color: Colors.grey);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.success:
        return Icon(PiconsRegular.cloud, size: 18, color: Colors.green);
      case SyncStatus.error:
        return Icon(PiconsRegular.cloudSlash, size: 18, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localPendingCount = pendingCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (localPendingCount != null && localPendingCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '$localPendingCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

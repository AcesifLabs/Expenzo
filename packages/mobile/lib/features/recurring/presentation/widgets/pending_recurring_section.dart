import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';

class PendingRecurringSection extends StatefulWidget {
  const PendingRecurringSection({super.key});

  @override
  State<PendingRecurringSection> createState() =>
      _PendingRecurringSectionState();
}

class _PendingRecurringSectionState extends State<PendingRecurringSection> {
  final PendingRecurringDao _pendingDao = di.getIt<PendingRecurringDao>();

  void _processAll() {
    final recurringBloc = di.getIt<RecurringBloc>();
    recurringBloc.add(const ProcessRecurring());
  }

  Widget _buildCard(
    List<PendingRecurringData> pendingItems,
    DateFormat dateFormat,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildPendingList(pendingItems, dateFormat),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(PiconsRegular.clock, color: Colors.orange),
          const SizedBox(width: 8),
          const Text(
            'Pending Recurring',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(onPressed: _processAll, child: const Text('Process All')),
        ],
      ),
    );
  }

  Widget _buildPendingList(
    List<PendingRecurringData> pendingItems,
    DateFormat dateFormat,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingItems.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _buildPendingItem(pendingItems[index], dateFormat),
    );
  }

  Widget _buildPendingItem(PendingRecurringData item, DateFormat dateFormat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withAlpha(51),
        child: Icon(PiconsRegular.calendar, color: Colors.orange),
      ),
      title: Text(item.description),
      subtitle: Text(
        '\$${item.amount.toStringAsFixed(2)} - Due: ${dateFormat.format(item.dueDate)}',
      ),
      trailing: IconButton(
        icon: Icon(PiconsRegular.checkCircle),
        color: Colors.green,
        onPressed: () => unawaited(_removePending(item.id)),
      ),
    );
  }

  Future<void> _removePending(String id) async {
    await _pendingDao.removePending(id);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return StreamBuilder(
      stream: _pendingDao.watchPending(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final pendingData = snapshot.data;
        if (pendingData == null || pendingData.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildCard(pendingData, dateFormat);
      },
    );
  }
}

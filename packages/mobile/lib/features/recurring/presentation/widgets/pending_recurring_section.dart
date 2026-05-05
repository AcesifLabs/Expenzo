import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return StreamBuilder(
      stream: _pendingDao.watchPending(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final pendingItems = snapshot.data!;
        final recurringBloc = di.getIt<RecurringBloc>();

        return Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.clock(PhosphorIconsStyle.regular),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pending Recurring',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        recurringBloc.add(const ProcessRecurring());
                      },
                      child: const Text('Process All'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingItems.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = pendingItems[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withAlpha(51),
                      child: Icon(
                        PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(item.description),
                    subtitle: Text(
                      '\$${item.amount.toStringAsFixed(2)} - Due: ${dateFormat.format(item.dueDate)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
                      ),
                      color: Colors.green,
                      onPressed: () async {
                        await _pendingDao.removePending(item.id);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

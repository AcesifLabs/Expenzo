import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../parsing_rules/presentation/widgets/confidence_badge.dart';
import '../bloc/email_scanner_bloc.dart';
import '../bloc/email_scanner_event.dart';
import '../bloc/email_scanner_state.dart';

class EmailScanPage extends StatelessWidget {
  const EmailScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Emails')),
      body: BlocBuilder<EmailScannerBloc, EmailScannerState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is EmailScannerScanComplete) ...[
                  _buildLastScanInfo(state),
                  const SizedBox(height: 16),
                  _buildResultsSummary(context, state),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    onPressed: () {
                      context.read<EmailScannerBloc>().add(
                        const StartEmailScan(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: Text('View ${state.results.length} Results'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<EmailScannerBloc>(),
                            child: const EmailScanResultsPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ] else if (state is EmailScannerScanning) ...[
                  _buildScanningIndicator(state),
                ] else if (state is EmailScannerError) ...[
                  _buildError(context, state),
                ] else ...[
                  _buildInitialState(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLastScanInfo(EmailScannerScanComplete state) {
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' h:mm a');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Last scan: ${dateFormat.format(state.lastScanTimestamp)}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSummary(
    BuildContext context,
    EmailScannerScanComplete state,
  ) {
    final highConfidence = state.results
        .where((r) => r.isHighConfidence())
        .length;
    final mediumConfidence = state.results
        .where((r) => r.isMediumConfidence())
        .length;
    final lowConfidence = state.results
        .where((r) => r.isLowConfidence())
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${state.results.length} new expenses found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildConfidenceChip('High', highConfidence, Colors.green),
                const SizedBox(width: 8),
                _buildConfidenceChip('Medium', mediumConfidence, Colors.orange),
                const SizedBox(width: 8),
                _buildConfidenceChip('Low', lowConfidence, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }

  Widget _buildScanningIndicator(EmailScannerScanning state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Scanning Emails...'),
            if (state.totalEmails > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: state.progress),
              const SizedBox(height: 4),
              Text('${state.processedEmails}/${state.totalEmails} emails'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, EmailScannerError state) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Scan Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<EmailScannerBloc>().add(const StartEmailScan());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No email scan performed yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to scan your emails\nand automatically create expenses.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Scan Emails'),
              onPressed: () {
                context.read<EmailScannerBloc>().add(const StartEmailScan());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmailScanResultsPage extends StatefulWidget {
  const EmailScanResultsPage({super.key});

  @override
  State<EmailScanResultsPage> createState() => _EmailScanResultsPageState();
}

class _EmailScanResultsPageState extends State<EmailScanResultsPage> {
  Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Scan Results'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIds = {};
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: BlocBuilder<EmailScannerBloc, EmailScannerState>(
        buildWhen: (previous, current) =>
            current is EmailScannerInitial ||
            current is EmailScannerScanning ||
            current is EmailScannerScanComplete ||
            current is EmailScannerError,
        builder: (context, state) {
          if (state is EmailScannerScanComplete) {
            if (state.results.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      'No new expenses found',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final transaction = state.results[index];
                return _buildEmailResultCard(context, transaction);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: _selectedIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Creating ${_selectedIds.length} expenses...',
                      ),
                    ),
                  );
                },
                child: Text('Create ${_selectedIds.length} Selected'),
              ),
            )
          : null,
    );
  }

  Widget _buildEmailResultCard(BuildContext context, dynamic transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '৳');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_selectedIds.contains(transaction.sourceId)) {
              _selectedIds.remove(transaction.sourceId);
            } else {
              _selectedIds.add(transaction.sourceId);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: _selectedIds.contains(transaction.sourceId),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds.add(transaction.sourceId);
                    } else {
                      _selectedIds.remove(transaction.sourceId);
                    }
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          transaction.amount != null
                              ? currencyFormat.format(transaction.amount)
                              : 'N/A',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: transaction.amount != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.rawMessage.length > 50
                          ? '${transaction.rawMessage.substring(0, 50)}...'
                          : transaction.rawMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    ConfidenceBadge(
                      confidenceScore: transaction.confidenceScore,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

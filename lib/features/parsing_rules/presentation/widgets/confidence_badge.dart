import 'package:flutter/material.dart';
import '../../domain/entities/parsed_transaction.dart';

class ConfidenceBadge extends StatelessWidget {
  final double confidenceScore;

  const ConfidenceBadge({super.key, required this.confidenceScore});

  Color _getColor() {
    if (confidenceScore >= 0.9) {
      return Colors.green;
    } else if (confidenceScore >= 0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getLabel() {
    if (confidenceScore >= 0.9) {
      return 'High';
    } else if (confidenceScore >= 0.7) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final percentage = (confidenceScore * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confidenceScore >= 0.9
                ? Icons.check_circle
                : confidenceScore >= 0.7
                ? Icons.warning
                : Icons.error,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage% ${_getLabel()}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ParsedResultPreview extends StatelessWidget {
  final ParsedTransaction? parsed;

  const ParsedResultPreview({super.key, this.parsed});

  @override
  Widget build(BuildContext context) {
    if (parsed == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Enter a sample message to test'),
        ),
      );
    }

    if (parsed!.parseFailed) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Parse Failed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (parsed!.parseError != null) ...[
                const SizedBox(height: 4),
                Text(parsed!.parseError!),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Result Preview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ConfidenceBadge(confidenceScore: parsed!.confidenceScore),
              ],
            ),
            const Divider(),
            _buildField('Amount', parsed!.amount?.toString() ?? 'Not found'),
            _buildField('Date', parsed!.date?.toString() ?? 'Not found'),
            _buildField('Description', parsed!.description ?? 'Not found'),
            if (parsed!.matchedRuleId != null)
              _buildField('Matched Rule', parsed!.matchedRuleId!),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value.contains('Not found') ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

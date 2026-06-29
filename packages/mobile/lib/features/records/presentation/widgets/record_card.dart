import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import '../../domain/entities/record.dart';
import 'source_badge.dart';

/// Interactive record card with tap/delete actions for the records list.
///
/// Unlike [ReadOnlyRecordTile] which is a lightweight read-only tile for
/// dashboard summaries, this widget supports dismiss-to-delete, tap-to-edit,
/// and category icon display. Requires [categoryInfo] to be resolved by
/// the parent widget to avoid per-card BlocBuilder rebuilds.
class RecordCard extends StatelessWidget {
  final Record record;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final CategoryInfo? categoryInfo;

  static final _dateFormat = DateFormat('MMM dd, yyyy');

  const RecordCard({
    super.key,
    required this.record,
    required this.onTap,
    required this.onDelete,
    this.categoryInfo,
  });

  Widget _buildLeading(Color leadingBg, Color catColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: leadingBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(PiconsLight.receipt, size: 22, color: catColor),
      ),
    );
  }

  Widget _buildInfo(ColorScheme colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _dateFormat.format(record.date),
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount(bool isNegative, CategoryInfo catInfo, Object? _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${isNegative ? '-' : ''}\$${record.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNegative ? AppColors.expense : AppColors.success,
          ),
        ),
        const SizedBox(height: 4),
        SourceBadge(
          source: record.source,
          categoryName: catInfo.name,
          categoryIconName: catInfo.emoji,
          categoryColor: catInfo.color,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catInfo = categoryInfo ?? const CategoryInfo();
    final isNegative = record.amount < 0;
    final catColorHex = catInfo.color;
    final colors = Theme.of(context).colorScheme;

    final catColor = catColorHex != null
        ? ColorUtils.fromHex(catColorHex)
        : colors.primary;

    final leadingBg = catColorHex != null
        ? ColorUtils.fromHexWithAlpha(catColorHex)
        : catColor.withAlpha(25);

    return AppCard(
      onTap: onTap,
      dismissibleKey: Key('record_${record.id}'),
      onDismissed: onDelete,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildLeading(leadingBg, catColor),
          const SizedBox(width: 12),
          _buildInfo(colors),
          const SizedBox(width: 12),
          _buildAmount(isNegative, catInfo, catColor),
        ],
      ),
    );
  }
}

class CategoryInfo {
  final String? name;
  final String? emoji;
  final String? color;

  const CategoryInfo({this.name, this.emoji, this.color});
}

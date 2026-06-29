import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import '../../domain/entities/record.dart';
import 'source_badge.dart';

class RecordCard extends StatelessWidget {
  final Record record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static final _dateFormat = DateFormat('MMM dd, yyyy');

  const RecordCard({
    super.key,
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  _CategoryInfo _resolveCategory(CategoryState state) {
    if (state is! CategoryLoaded) return const _CategoryInfo();
    final matched = state.categories.where((c) => c.id == record.categoryId);
    if (matched.isEmpty) return const _CategoryInfo();

    return _CategoryInfo(
      name: matched.first.name,
      emoji: matched.first.emoji,
      color: matched.first.color,
    );
  }

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

  Widget _buildInfo() {
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount(bool isNegative, _CategoryInfo catInfo, Object? _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${isNegative ? '-' : ''}\$${record.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNegative
                ? const Color(0xFFFF3B30)
                : const Color(0xFF34C759),
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
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final catInfo = _resolveCategory(state);
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
              _buildInfo(),
              const SizedBox(width: 12),
              _buildAmount(isNegative, catInfo, catColor),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryInfo {
  final String? name;
  final String? emoji;
  final String? color;

  const _CategoryInfo({this.name, this.emoji, this.color});
}

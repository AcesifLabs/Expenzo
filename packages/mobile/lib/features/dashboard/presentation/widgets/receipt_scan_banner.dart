import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class ReceiptScanBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const ReceiptScanBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = t.dashboard.scanReceipt;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PiconsRegular.scan,
                size: AppSpacing.iconSm,
                color: palette.brand,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
                ),
              ),
              Icon(
                PiconsRegular.caretRight,
                size: 12,
                color: palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

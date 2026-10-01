import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_tooltip.dart';

/// Page chrome for long result sets — prev / next + page readout.
///
/// Presentation only: the host owns slicing. Prefer virtual scroll when the
/// full list is already in memory and cheap to paint.
class TuiPagination extends StatelessWidget {
  const TuiPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onPageChanged,
    this.totalItems,
    this.pageSize,
    this.dense = false,
  }) : assert(page >= 1),
       assert(pageCount >= 1);

  /// 1-based current page.
  final int page;

  /// Total number of pages (≥ 1).
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  /// Optional “42 items” caption.
  final int? totalItems;

  /// Optional page size for “showing 1–20 of 42”.
  final int? pageSize;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final canPrev = page > 1;
    final canNext = page < pageCount;
    final mono = TextStyle(
      fontFamily: TermulFonts.mono,
      fontSize: dense ? 11 : 12,
      color: p.muted,
      height: 1.2,
    );

    String caption;
    if (totalItems != null && pageSize != null && totalItems! > 0) {
      final start = (page - 1) * pageSize! + 1;
      final end = (page * pageSize!).clamp(0, totalItems!);
      caption = '$start–$end of $totalItems';
    } else if (totalItems != null) {
      caption = '$totalItems items · $page / $pageCount';
    } else {
      caption = '$page / $pageCount';
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 6 : 8,
      ),
      child: Row(
        children: [
          TuiIconButton(
            icon: '‹',
            tooltip: 'Previous page',
            size: dense ? 28 : 32,
            onPressed: canPrev ? () => onPageChanged(page - 1) : null,
          ),
          const SizedBox(width: 4),
          TuiIconButton(
            icon: '›',
            tooltip: 'Next page',
            size: dense ? 28 : 32,
            onPressed: canNext ? () => onPageChanged(page + 1) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(caption, style: mono)),
          if (pageCount > 1)
            Text(
              'PAGE',
              style: mono.copyWith(color: p.dim, letterSpacing: 0.4),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';

/// Pulsing placeholder block — sharp Termul chrome (no rounded shimmer pills).
class TuiSkeleton extends StatefulWidget {
  const TuiSkeleton({
    super.key,
    this.width,
    this.height = 12,
    this.expand = false,
  });

  final double? width;
  final double height;

  /// Stretch to parent width when [width] is null.
  final bool expand;

  @override
  State<TuiSkeleton> createState() => _TuiSkeletonState();
}

class _TuiSkeletonState extends State<TuiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final color = Color.lerp(p.border, p.surface, t)!;
        final box = Container(
          width: widget.expand ? double.infinity : widget.width ?? 120,
          height: widget.height,
          color: color,
        );
        return widget.expand && widget.width == null
            ? SizedBox(width: double.infinity, child: box)
            : box;
      },
    );
  }
}

/// One skeleton list row — leading square + two text bars.
class TuiSkeletonRow extends StatelessWidget {
  const TuiSkeletonRow({
    super.key,
    this.showLeading = true,
    this.dense = false,
  });

  final bool showLeading;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final vPad = dense ? 10.0 : 14.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, vPad, 16, vPad),
      child: Row(
        children: [
          if (showLeading) ...[
            const TuiSkeleton(width: 28, height: 28),
            const SizedBox(width: 12),
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TuiSkeleton(width: 160, height: 11),
                SizedBox(height: 8),
                TuiSkeleton(width: 220, height: 9),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stack of [TuiSkeletonRow]s for list loading states.
class TuiSkeletonList extends StatelessWidget {
  const TuiSkeletonList({
    super.key,
    this.count = 4,
    this.showLeading = true,
    this.dense = false,
  });

  final int count;
  final bool showLeading;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          TuiSkeletonRow(showLeading: showLeading, dense: dense),
          if (i < count - 1)
            Divider(height: 1, thickness: 1, color: p.border),
        ],
      ],
    );
  }
}

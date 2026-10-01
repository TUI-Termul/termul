import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termul_palette.dart';
import '../theme/termul_theme.dart';

/// One slot on the magic key's ring — label only; host maps to terminal bytes.
typedef TuiMagicKeyAction = ({String label});

/// Tap on the floating button emits this label (Enter / CR).
const tuiMagicEnterLabel = '⏎';

/// Full-circle vs corner quarter-arc picker.
enum TuiMagicKeyShape {
  /// Classic two-ring compass (8 primaries + sub-keys behind each).
  ring,

  /// Concentric quarter-arcs that park in a corner and hold many flat keys.
  quarter,
}

/// The ring, clockwise from north.
///
/// Arrows sit where the finger points; diagonals hold shell keys a soft
/// keyboard often lacks.
const List<TuiMagicKeyAction> tuiMagicKeys = [
  (label: '↑'),
  (label: 'ESC'),
  (label: '→'),
  (label: 'TAB'),
  (label: '↓'),
  (label: '^C'),
  (label: '←'),
  (label: '^D'),
];

/// Ring 2: keys behind each of ring 1's, keyed by label.
const Map<String, List<TuiMagicKeyAction>> tuiMagicSubKeys = {
  '↑': [(label: 'PGUP'), (label: 'HOME')],
  'ESC': [(label: 'ESC²')],
  '→': [(label: 'END'), (label: 'W→')],
  'TAB': [(label: '⇧TAB')],
  '↓': [(label: 'PGDN'), (label: 'END')],
  '^C': [(label: '^Z'), (label: '^\\')],
  '←': [(label: 'HOME'), (label: 'W←')],
  '^D': [(label: '^L'), (label: '^R')],
};

/// Flat key set for [TuiMagicKeyShape.quarter] — sshbox-style shell keys,
/// ordered for reading along each arc (inner → outer by layout weights).
const List<TuiMagicKeyAction> tuiMagicQuarterKeys = [
  (label: '↑'),
  (label: '←'),
  (label: '↓'),
  (label: '→'),
  (label: 'ESC'),
  (label: 'TAB'),
  (label: '^C'),
  (label: '^D'),
  (label: 'HOME'),
  (label: 'END'),
  (label: 'PGUP'),
  (label: 'PGDN'),
  (label: 'W←'),
  (label: 'W→'),
  (label: '⇧TAB'),
  (label: 'ESC²'),
  (label: '^Z'),
  (label: '^\\'),
  (label: '^L'),
  (label: '^R'),
];

/// Default dead zone before a drag aims at a petal.
const double tuiMagicDeadZone = 18;

double _angleBetween(double a, double b) {
  final d = (a - b).abs() % (2 * math.pi);
  return math.min(d, 2 * math.pi - d);
}

/// Widest run of directions where a petal stays inside [bounds].
({double start, double sweep}) tuiMagicFreeArc(
  Offset centre,
  Size bounds,
  double radius,
  double inset,
) {
  const steps = 360;
  bool fits(int i) {
    final a = 2 * math.pi * i / steps;
    final x = centre.dx + radius * math.sin(a);
    final y = centre.dy - radius * math.cos(a);
    return x >= inset &&
        x <= bounds.width - inset &&
        y >= inset &&
        y <= bounds.height - inset;
  }

  final ok = [for (var i = 0; i < steps; i++) fits(i)];
  if (!ok.contains(false)) return (start: 0, sweep: 2 * math.pi);
  if (!ok.contains(true)) return (start: 0, sweep: 0);

  final blocked = ok.indexOf(false);
  var bestStart = 0, bestLength = 0, runStart = 0, runLength = 0;
  for (var k = 1; k <= steps; k++) {
    final i = (blocked + k) % steps;
    if (!ok[i]) {
      runLength = 0;
      continue;
    }
    if (runLength == 0) runStart = i;
    runLength++;
    if (runLength > bestLength) {
      bestLength = runLength;
      bestStart = runStart;
    }
  }
  return (
    start: 2 * math.pi * bestStart / steps,
    sweep: 2 * math.pi * (bestLength - 1) / steps,
  );
}

/// Petal angles around [centre] inside [bounds] — full compass or edge fan.
({List<double> angles, double radius, double outer, double spread})
    tuiMagicRingLayout({
  required Offset centre,
  required Size bounds,
  int count = 8,
  double radius = 80,
  double outer = 135,
  double petal = 40,
  double gap = 6,
  double maxRadius = 280,
}) {
  final compass = [for (var i = 0; i < count; i++) 2 * math.pi * i / count];
  final inset = petal / 2 + 4;

  var r = outer;
  var arc = tuiMagicFreeArc(centre, bounds, r, inset);
  for (var round = 0; round < 4; round++) {
    if (arc.sweep <= 0 || arc.sweep >= 2 * math.pi) break;
    final needed = (petal + gap) * (2 * count - 1) / arc.sweep;
    if (needed <= r || r >= maxRadius) break;
    r = math.min(needed, maxRadius);
    arc = tuiMagicFreeArc(centre, bounds, r, inset);
  }
  final inner = r - (outer - radius);

  if (arc.sweep <= 0 || arc.sweep >= 2 * math.pi) {
    return (angles: compass, radius: inner, outer: r, spread: math.pi / count);
  }

  final spacing = arc.sweep / (count - 0.5);
  final slots = [for (var j = 0; j < count; j++) arc.start + spacing * j];
  final tolerance = spacing / 2;
  bool onArc(double a) {
    final along = (a - arc.start) % (2 * math.pi);
    return along <= arc.sweep + tolerance || along >= 2 * math.pi - tolerance;
  }

  final weight = [
    for (final a in compass)
      !onArc(a)
          ? 1.0
          : (a % (math.pi / 2)).abs() < 1e-9
              ? 400.0
              : 100.0,
  ];
  final slotOf = _closestAssignment(slots, compass, weight);
  return (
    angles: [for (final j in slotOf) slots[j] % (2 * math.pi)],
    radius: inner,
    outer: r,
    spread: spacing / 2,
  );
}

List<int> _closestAssignment(
  List<double> slots,
  List<double> compass,
  List<double> weight,
) {
  final n = slots.length;
  final best = List<int>.filled(n, 0);
  final current = List<int>.filled(n, 0);
  final used = List<bool>.filled(n, false);
  var bestCost = double.infinity;

  void place(int key, double cost) {
    if (cost >= bestCost) return;
    if (key == n) {
      bestCost = cost;
      best.setAll(0, current);
      return;
    }
    for (var j = 0; j < n; j++) {
      if (used[j]) continue;
      used[j] = true;
      current[key] = j;
      place(
        key + 1,
        cost + weight[key] * _angleBetween(slots[j], compass[key]),
      );
      used[j] = false;
    }
  }

  place(0, 0);
  return best;
}

/// Which petal a drag from the button centre points at, or null in the gap /
/// dead zone.
int? tuiMagicPetalFor(
  Offset offset,
  List<double> angles, {
  double deadZone = tuiMagicDeadZone,
}) {
  if (offset.distance < deadZone) return null;
  final pointing = math.atan2(offset.dx, -offset.dy);

  var nearest = 0;
  var nearestGap = double.infinity;
  for (var i = 0; i < angles.length; i++) {
    final gap = _angleBetween(pointing, angles[i]);
    if (gap < nearestGap) {
      nearestGap = gap;
      nearest = i;
    }
  }

  final sorted = [...angles]..sort();
  var spacing = 2 * math.pi - sorted.last + sorted.first;
  for (var i = 1; i < sorted.length; i++) {
    spacing = math.min(spacing, sorted[i] - sorted[i - 1]);
  }
  return nearestGap <= spacing / 2 + 1e-6 ? nearest : null;
}

// ── Quarter-circle multi-tier layout ──────────────────────────────────────

/// One petal in a quarter-arc layout.
typedef TuiMagicQuarterSlot = ({double angle, double radius, int tier});

/// How many keys each concentric tier should hold for [total] keys across
/// [tiers] arcs. Outer tiers get more slots (longer arc length).
List<int> tuiMagicTierCounts(int total, int tiers) {
  final n = math.max(1, tiers);
  if (total <= 0) return List<int>.filled(n, 0);
  if (total <= n) {
    return [for (var i = 0; i < n; i++) i < total ? 1 : 0];
  }

  final weights = [for (var i = 1; i <= n; i++) i];
  final sum = weights.reduce((a, b) => a + b);
  final counts = [
    for (final w in weights) math.max(1, (total * w / sum).floor()),
  ];
  var assigned = counts.reduce((a, b) => a + b);
  var tip = n - 1;
  while (assigned < total) {
    counts[tip]++;
    assigned++;
    tip = (tip - 1 + n) % n;
  }
  while (assigned > total) {
    var trimmed = false;
    for (var j = n - 1; j >= 0; j--) {
      if (counts[j] > 1) {
        counts[j]--;
        assigned--;
        trimmed = true;
        break;
      }
    }
    if (!trimmed) break;
  }
  return counts;
}

/// Quarter (π/2) opening into free screen space from [centre].
({double start, double sweep}) tuiMagicQuarterArc(
  Offset centre,
  Size bounds,
) {
  final right = centre.dx >= bounds.width / 2;
  final bottom = centre.dy >= bounds.height / 2;
  // Clockwise from north: 0 N, π/2 E, π S, 3π/2 W.
  if (right && bottom) return (start: 3 * math.pi / 2, sweep: math.pi / 2); // W→N
  if (!right && bottom) return (start: 0, sweep: math.pi / 2); // N→E
  if (!right && !bottom) return (start: math.pi / 2, sweep: math.pi / 2); // E→S
  return (start: math.pi, sweep: math.pi / 2); // S→W
}

double _radiusForChord(int count, double sweep, double petal, double gap) {
  if (count <= 1) return petal;
  final spacing = sweep / (count - 1);
  final sinHalf = math.sin(spacing / 2);
  if (sinHalf < 1e-6) return 400;
  return (petal + gap) / (2 * sinHalf);
}

/// Concentric quarter-arcs of petals. Responsive: grows radii / shrinks
/// petals so neighbours do not overlap and every petal stays on-screen.
({
  List<TuiMagicQuarterSlot> slots,
  double start,
  double sweep,
  List<double> radii,
  double petal,
  double outer,
}) tuiMagicQuarterLayout({
  required Offset centre,
  required Size bounds,
  required int count,
  int tiers = 3,
  double petal = 40,
  double gap = 8,
  double minRadius = 58,
  double maxRadius = 300,
}) {
  final arc = tuiMagicQuarterArc(centre, bounds);
  final tierN = math.max(1, tiers);
  final counts = tuiMagicTierCounts(count, tierN);
  final inset = petal / 2 + 4;

  var size = petal;
  List<double> radii = [];
  List<TuiMagicQuarterSlot> slots = [];

  for (var attempt = 0; attempt < 8; attempt++) {
    radii = [];
    var r = minRadius;
    for (var t = 0; t < tierN; t++) {
      final need = _radiusForChord(counts[t], arc.sweep, size, gap);
      if (t == 0) {
        r = math.max(minRadius, need);
      } else {
        r = math.max(radii[t - 1] + size + gap, need);
      }
      r = math.min(r, maxRadius);
      radii.add(r);
    }

    slots = [];
    var index = 0;
    for (var t = 0; t < tierN; t++) {
      final n = counts[t];
      if (n <= 0) continue;
      final spacing = n == 1 ? 0.0 : arc.sweep / (n - 1);
      for (var j = 0; j < n; j++) {
        if (index >= count) break;
        slots.add((
          angle: (arc.start + spacing * j) % (2 * math.pi),
          radius: radii[t],
          tier: t,
        ));
        index++;
      }
    }

    bool onScreen(TuiMagicQuarterSlot s) {
      final x = centre.dx + s.radius * math.sin(s.angle);
      final y = centre.dy - s.radius * math.cos(s.angle);
      return x >= inset &&
          x <= bounds.width - inset &&
          y >= inset &&
          y <= bounds.height - inset;
    }

    final ok = slots.every(onScreen);
    final withinCap = radii.isEmpty || radii.last <= maxRadius + 1e-6;
    if (ok && withinCap) break;
    size = math.max(28, size - 2);
  }

  return (
    slots: slots,
    start: arc.start,
    sweep: arc.sweep,
    radii: radii,
    petal: size,
    outer: radii.isEmpty ? minRadius : radii.last,
  );
}

/// Nearest quarter petal for a drag from the hub, or null in the dead zone /
/// outside the fan.
int? tuiMagicQuarterPetalFor(
  Offset offset,
  List<TuiMagicQuarterSlot> slots, {
  double start = 0,
  double sweep = math.pi / 2,
  double deadZone = tuiMagicDeadZone,
  double hitSlop = 28,
}) {
  if (slots.isEmpty || offset.distance < deadZone) return null;

  final pointing = math.atan2(offset.dx, -offset.dy);
  var along = (pointing - start) % (2 * math.pi);
  if (along < 0) along += 2 * math.pi;
  // Small tolerance past the fan edges.
  const pad = 0.2;
  if (along > sweep + pad && along < 2 * math.pi - pad) return null;

  var best = 0;
  var bestDist = double.infinity;
  for (var i = 0; i < slots.length; i++) {
    final at = Offset(
      slots[i].radius * math.sin(slots[i].angle),
      -slots[i].radius * math.cos(slots[i].angle),
    );
    final d = (offset - at).distance;
    if (d < bestDist) {
      bestDist = d;
      best = i;
    }
  }
  // Prefer a nearby petal; still snap to nearest when deep into the fan.
  if (bestDist <= hitSlop) return best;
  if (offset.distance >= slots[best].radius - hitSlop) return best;
  return null;
}

/// Floating Enter that opens a radial key picker on long-press; drag to park /
/// dock against a side. Touch-only affordance — omit on desktop.
///
/// [shape] selects full [TuiMagicKeyShape.ring] (two hierarchical rings) or
/// [TuiMagicKeyShape.quarter] (flat keys on [tiers] concentric quarter-arcs).
///
/// Place with [Positioned.fill] over the terminal; only the button hit-tests.
/// [onEmit] receives key labels (`⏎`, `↑`, `ESC`, `PGUP`, …) — host maps to
/// bytes. Optional [initialSpot] / [onSpotChanged] for persistence.
class TuiMagicKey extends StatefulWidget {
  const TuiMagicKey({
    super.key,
    required this.onEmit,
    this.initialSpot = const Offset(0.95, 0.92),
    this.initialDocked = false,
    this.onSpotChanged,
    this.keys = tuiMagicKeys,
    this.subKeys = tuiMagicSubKeys,
    this.quarterKeys = tuiMagicQuarterKeys,
    this.enterLabel = tuiMagicEnterLabel,
    this.shape = TuiMagicKeyShape.ring,
    this.tiers = 3,
  });

  final void Function(String label) onEmit;

  /// Fractional position in the movable room (0–1).
  final Offset initialSpot;
  final bool initialDocked;

  /// `(spot, docked)` whenever the button settles after a move/reveal.
  final void Function(Offset spot, bool docked)? onSpotChanged;

  /// Ring-1 keys when [shape] is [TuiMagicKeyShape.ring].
  final List<TuiMagicKeyAction> keys;
  final Map<String, List<TuiMagicKeyAction>> subKeys;

  /// Flat key list when [shape] is [TuiMagicKeyShape.quarter].
  final List<TuiMagicKeyAction> quarterKeys;

  final String enterLabel;

  /// Full compass rings, or a corner quarter with [tiers] concentric arcs.
  final TuiMagicKeyShape shape;

  /// Number of concentric arcs for [TuiMagicKeyShape.quarter] (1–6).
  final int tiers;

  @override
  State<TuiMagicKey> createState() => _TuiMagicKeyState();
}

class _TuiMagicKeyState extends State<TuiMagicKey> {
  static const _size = 52.0;
  static const _petal = 40.0;
  static const _throwSpeed = 700.0;
  static const _inset = 16.0;
  static const _glideTime = Duration(milliseconds: 220);
  static const _tuckedRingStep = 32.0;
  static const _tuckedRingSlack = 6.0;
  static const _idleAfter = Duration(seconds: 3);
  static const _idleOpacity = 0.55;
  static const _fadeTime = Duration(milliseconds: 1800);

  late Offset _spot = widget.initialSpot;
  late bool _docked = widget.initialDocked;

  bool get _onLeft => _spot.dx < 0.5;
  bool get _quarter => widget.shape == TuiMagicKeyShape.quarter;

  Duration _glide = Duration.zero;
  Offset _anchor = Offset.zero;
  Offset _grab = Offset.zero;

  int? _aim;
  int? _child;
  bool _idle = false;
  Timer? _idleClock;
  bool _picking = false;
  bool _moving = false;

  Offset _centre = Offset.zero;
  Size _bounds = Size.zero;

  late ({List<double> angles, double radius, double outer, double spread})
      _ring;

  late ({
    List<TuiMagicQuarterSlot> slots,
    double start,
    double sweep,
    List<double> radii,
    double petal,
    double outer,
  }) _quarterRing;

  double get _halfway => (_ring.radius + _ring.outer) / 2;

  double get _ringTwoFrom => !_docked
      ? _halfway
      : tuiMagicDeadZone +
          _tuckedRingStep -
          (_child != null ? _tuckedRingSlack : 0);

  int get _tierCount => widget.tiers.clamp(1, 6);

  @override
  void initState() {
    super.initState();
    _doze();
  }

  @override
  void dispose() {
    _idleClock?.cancel();
    super.dispose();
  }

  void _remember() => widget.onSpotChanged?.call(_spot, _docked);

  void _wake() {
    _idleClock?.cancel();
    if (_idle) setState(() => _idle = false);
  }

  void _doze() {
    _idleClock?.cancel();
    _idleClock = Timer(_idleAfter, () {
      if (!_picking && !_moving) setState(() => _idle = true);
    });
  }

  List<TuiMagicKeyAction> _subKeysOf(int index) =>
      widget.subKeys[widget.keys[index].label] ?? const [];

  List<double> _subAnglesOf(int index) => [
        for (var j = 0; j < _subKeysOf(index).length; j++)
          _ring.angles[index] + j * _ring.spread,
      ];

  void _aimAt(Offset drag) {
    if (_quarter) {
      final aim = tuiMagicQuarterPetalFor(
        drag,
        _quarterRing.slots,
        start: _quarterRing.start,
        sweep: _quarterRing.sweep,
        hitSlop: _quarterRing.petal * 0.85,
      );
      if (aim == _aim) return;
      if (aim != null) HapticFeedback.selectionClick();
      setState(() {
        _aim = aim;
        _child = null;
      });
      return;
    }

    var aim = tuiMagicPetalFor(drag, _ring.angles);
    int? child;
    if (aim != null && drag.distance >= _ringTwoFrom) {
      final pointing = math.atan2(drag.dx, -drag.dy);
      double off(double angle) => _angleBetween(pointing, angle);
      if (_docked && _child != null) {
        final held = _aim!;
        final own = _subAnglesOf(held).map(off).reduce(math.min);
        if (own <= off(_ring.angles[aim])) aim = held;
      }
      final parent = aim;
      var nearest = double.infinity;
      for (var i = 0; i < widget.keys.length; i++) {
        if (_docked && i != parent) continue;
        final angles = _subAnglesOf(i);
        for (var j = 0; j < angles.length; j++) {
          final gap = off(angles[j]);
          if (gap < nearest) {
            nearest = gap;
            aim = i;
            child = j;
          }
        }
      }
    }
    if (aim == _aim && child == _child) return;
    if (aim != null) HapticFeedback.selectionClick();
    setState(() {
      _aim = aim;
      _child = child;
    });
  }

  void _openRing(LongPressStartDetails _) {
    if (_quarter) {
      _quarterRing = tuiMagicQuarterLayout(
        centre: _centre,
        bounds: _bounds,
        count: widget.quarterKeys.length,
        tiers: _tierCount,
        petal: _petal,
      );
    } else {
      _ring = tuiMagicRingLayout(
        centre: _centre,
        bounds: _bounds,
        count: widget.keys.length,
        petal: _petal,
      );
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _picking = true;
      _aim = null;
      _child = null;
    });
  }

  void _releaseRing() {
    final aim = _aim, child = _child;
    _closeRing();
    if (_quarter) {
      if (aim != null && aim >= 0 && aim < widget.quarterKeys.length) {
        widget.onEmit(widget.quarterKeys[aim].label);
      }
      return;
    }
    if (child != null) {
      widget.onEmit(_subKeysOf(aim!)[child].label);
    } else if (aim != null) {
      widget.onEmit(widget.keys[aim].label);
    }
  }

  void _closeRing() {
    if (!_picking && _aim == null) return;
    setState(() {
      _picking = false;
      _aim = null;
      _child = null;
    });
  }

  void _startMoving(DragStartDetails details) {
    _anchor = _spot;
    _grab = details.globalPosition;
    setState(() {
      _moving = true;
      _docked = false;
      _glide = Duration.zero;
      _picking = false;
      _aim = null;
    });
  }

  void _keepMoving(DragUpdateDetails details, Size room) {
    final moved = details.globalPosition - _grab;
    setState(() {
      _spot = Offset(
        (_anchor.dx + moved.dx / room.width).clamp(0.0, 1.0),
        (_anchor.dy + moved.dy / room.height).clamp(0.0, 1.0),
      );
    });
  }

  void _stopMoving([Velocity velocity = Velocity.zero]) {
    if (!_moving) return;
    final v = velocity.pixelsPerSecond;
    final thrown = v.dx.abs() > _throwSpeed && v.dx.abs() > v.dy.abs();
    final againstSide = _spot.dx <= 0 || _spot.dx >= 1;
    setState(() {
      _moving = false;
      if (thrown || againstSide) {
        _docked = true;
        _glide = _glideTime;
        if (thrown) _spot = Offset(v.dx > 0 ? 1 : 0, _spot.dy);
      }
    });
    _remember();
  }

  void _reveal(Size room) {
    final inset = (_inset / room.width).clamp(0.0, 1.0);
    setState(() {
      _docked = false;
      _glide = _glideTime;
      _spot = Offset(_onLeft ? inset : 1 - inset, _spot.dy);
    });
    _remember();
  }

  static Offset _out(Offset from, double angle, double distance) =>
      from + Offset(math.sin(angle), -math.cos(angle)) * distance;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final room = Size(
          math.max(1, constraints.maxWidth - _size),
          math.max(1, constraints.maxHeight - _size),
        );
        final origin = Offset(
          _docked
              ? (_onLeft ? 0 : constraints.maxWidth) - _size / 2
              : _spot.dx * room.width,
          _spot.dy * room.height,
        );
        _centre = origin + const Offset(_size / 2, _size / 2);
        _bounds = constraints.biggest;

        return Stack(
          children: [
            if (_picking)
              if (_quarter)
                ..._quarterPetals(p)
              else ...[
                _band(2 * _ring.outer - _halfway, p.selection),
                _band(_halfway, p.surface.withValues(alpha: 0.85)),
                for (var i = 0; i < widget.keys.length; i++) ...[
                  _petalAt(
                    _out(_centre, _ring.angles[i], _ring.radius),
                    widget.keys[i].label,
                    aimed: i == _aim && _child == null,
                  ),
                  for (final (j, angle) in _subAnglesOf(i).indexed)
                    _petalAt(
                      _out(_centre, angle, _ring.outer),
                      _subKeysOf(i)[j].label,
                      aimed: i == _aim && j == _child,
                    ),
                ],
              ],
            AnimatedPositioned(
              key: const ValueKey('tui-magic-key-button'),
              duration: _glide,
              curve: Curves.easeOutCubic,
              left: origin.dx,
              top: origin.dy,
              width: _size,
              height: _size,
              child: Semantics(
                excludeSemantics: true,
                label: _docked ? 'Show Enter key' : 'Send Enter',
                button: true,
                child: GestureDetector(
                  onTap: _docked
                      ? () => _reveal(room)
                      : () => widget.onEmit(widget.enterLabel),
                  onLongPressStart: _openRing,
                  onLongPressMoveUpdate: (details) =>
                      _aimAt(details.offsetFromOrigin),
                  onLongPressEnd: (_) => _releaseRing(),
                  onLongPressCancel: _closeRing,
                  onPanStart: _startMoving,
                  onPanUpdate: (details) => _keepMoving(details, room),
                  onPanEnd: (details) => _stopMoving(details.velocity),
                  onPanCancel: _stopMoving,
                  child: Listener(
                    onPointerDown: (_) => _wake(),
                    onPointerUp: (_) => _doze(),
                    onPointerCancel: (_) => _doze(),
                    child: AnimatedOpacity(
                      opacity: _idle ? _idleOpacity : 1,
                      duration: _idle ? _fadeTime : Duration.zero,
                      curve: Curves.easeOut,
                      child: _Button(
                        picking: _picking,
                        moving: _moving,
                        tuckedLeft: _docked ? _onLeft : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _quarterPetals(TermulPalette p) {
    final outer = _quarterRing.outer + _quarterRing.petal / 2;
    final petals = <Widget>[
      _quarterBand(outer, p.selection),
      for (final r in _quarterRing.radii)
        _quarterBand(
          r + _quarterRing.petal / 2,
          p.surface.withValues(alpha: 0.35),
          strokeOnly: true,
        ),
    ];
    for (var i = 0; i < _quarterRing.slots.length; i++) {
      final slot = _quarterRing.slots[i];
      petals.add(
        _petalAt(
          _out(_centre, slot.angle, slot.radius),
          widget.quarterKeys[i].label,
          aimed: i == _aim,
          size: _quarterRing.petal,
        ),
      );
    }
    return petals;
  }

  Widget _band(double radius, Color color) => Positioned(
        left: _centre.dx - radius,
        top: _centre.dy - radius,
        width: 2 * radius,
        height: 2 * radius,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(
                color: TermulThemeData.of(context).palette.border,
              ),
            ),
          ),
        ),
      );

  Widget _quarterBand(
    double radius,
    Color color, {
    bool strokeOnly = false,
  }) {
    final size = radius * 2;
    return Positioned(
      left: _centre.dx - radius,
      top: _centre.dy - radius,
      width: size,
      height: size,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _QuarterArcPainter(
            start: _quarterRing.start,
            sweep: _quarterRing.sweep,
            color: strokeOnly ? color.withValues(alpha: 0) : color.withValues(alpha: 0.45),
            border: TermulThemeData.of(context).palette.border,
            strokeOnly: strokeOnly,
          ),
        ),
      ),
    );
  }

  Widget _petalAt(
    Offset at,
    String label, {
    required bool aimed,
    double size = _petal,
  }) {
    return Positioned(
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      width: size,
      height: size,
      child: IgnorePointer(
        child: _Petal(label: label, aimed: aimed),
      ),
    );
  }
}

class _QuarterArcPainter extends CustomPainter {
  _QuarterArcPainter({
    required this.start,
    required this.sweep,
    required this.color,
    required this.border,
    this.strokeOnly = false,
  });

  final double start;
  final double sweep;
  final Color color;
  final Color border;
  final bool strokeOnly;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Compass 0 = north clockwise → canvas 0 = east CCW. Negate sweep so the
    // painted wedge matches the petal angles.
    final canvasStart = start - math.pi / 2;
    final canvasSweep = -sweep;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    if (!strokeOnly) {
      final fill = Path()
        ..moveTo(centre.dx, centre.dy)
        ..arcTo(rect, canvasStart, canvasSweep, false)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawArc(
      rect,
      canvasStart,
      canvasSweep,
      false,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _QuarterArcPainter old) =>
      old.start != start ||
      old.sweep != sweep ||
      old.color != color ||
      old.border != border ||
      old.strokeOnly != strokeOnly;
}

class _Button extends StatelessWidget {
  const _Button({
    required this.picking,
    required this.moving,
    this.tuckedLeft,
  });

  final bool picking;
  final bool moving;
  final bool? tuckedLeft;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final tucked = tuckedLeft;

    final bg = moving
        ? p.deep
        : picking
            ? p.surface
            : p.accent;
    final fg = moving || !picking
        ? (p.isLight && !moving ? p.panel : p.bg)
        : p.text;

    final glyph = moving
        ? '✥'
        : tucked != null
            ? (tucked ? '›' : '‹')
            : picking
                ? '◎'
                : '⏎';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: p.border, width: moving ? 2 : 1),
      ),
      child: Align(
        alignment: tucked == null
            ? Alignment.center
            : Alignment(tucked ? 0.8 : -0.8, 0),
        child: Text(
          glyph,
          style: TextStyle(
            fontFamily: TermulFonts.mono,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _Petal extends StatelessWidget {
  const _Petal({required this.label, required this.aimed});

  final String label;
  final bool aimed;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: aimed ? p.accent : p.panel,
        shape: BoxShape.circle,
        border: Border.all(
          color: aimed ? p.accent : p.border,
          width: aimed ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: TermulFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: aimed
                ? (p.isLight ? p.panel : p.bg)
                : p.text,
          ),
        ),
      ),
    );
  }
}

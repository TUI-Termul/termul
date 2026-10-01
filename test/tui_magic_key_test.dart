import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termul/components/tui_magic_key.dart';
import 'package:termul/theme/termul_palette.dart';
import 'package:termul/theme/termul_theme.dart';

void main() {
  final compass = [for (var i = 0; i < 8; i++) 2 * math.pi * i / 8];

  group('tuiMagicPetalFor', () {
    test('ignores dead zone wobble', () {
      expect(tuiMagicPetalFor(const Offset(6, -6), compass), isNull);
    });

    test('reads compass points', () {
      expect(tuiMagicPetalFor(const Offset(0, -60), compass), 0);
      expect(tuiMagicPetalFor(const Offset(60, 0), compass), 2);
      expect(tuiMagicPetalFor(const Offset(0, 60), compass), 4);
      expect(tuiMagicPetalFor(const Offset(-60, 0), compass), 6);
    });

    test('reads diagonals', () {
      expect(tuiMagicPetalFor(const Offset(60, -60), compass), 1);
      expect(tuiMagicPetalFor(const Offset(60, 60), compass), 3);
      expect(tuiMagicPetalFor(const Offset(-60, 60), compass), 5);
      expect(tuiMagicPetalFor(const Offset(-60, -60), compass), 7);
    });
  });

  group('tuiMagicRingLayout', () {
    const screen = Size(800, 1200);

    test('compass when there is room all round', () {
      final ring = tuiMagicRingLayout(
        centre: const Offset(400, 600),
        bounds: screen,
      );
      for (var i = 0; i < 8; i++) {
        expect(ring.angles[i], closeTo(compass[i], 1e-9));
      }
      expect(ring.radius, 80);
    });

    test('fans away from the right edge', () {
      final centre = const Offset(770, 600);
      final ring = tuiMagicRingLayout(centre: centre, bounds: screen);
      expect(tuiMagicPetalFor(const Offset(60, 0), ring.angles), isNull);
      expect(tuiMagicPetalFor(const Offset(0, -60), ring.angles), 0);
    });
  });

  group('tuiMagicTierCounts', () {
    test('outer tiers hold more keys', () {
      expect(tuiMagicTierCounts(20, 3), [3, 6, 11]);
      expect(tuiMagicTierCounts(6, 3).reduce((a, b) => a + b), 6);
      expect(tuiMagicTierCounts(2, 3), [1, 1, 0]);
    });
  });

  group('tuiMagicQuarterLayout', () {
    const screen = Size(800, 1200);

    Offset petalCentre(Offset centre, double angle, double radius) => Offset(
          centre.dx + radius * math.sin(angle),
          centre.dy - radius * math.cos(angle),
        );

    test('opens a π/2 fan from the bottom-right corner', () {
      final layout = tuiMagicQuarterLayout(
        centre: const Offset(760, 1160),
        bounds: screen,
        count: 20,
        tiers: 3,
      );
      expect(layout.sweep, closeTo(math.pi / 2, 1e-9));
      expect(layout.slots, hasLength(20));
      expect(layout.radii, hasLength(3));
      expect(layout.radii[0], lessThan(layout.radii[1]));
      expect(layout.radii[1], lessThan(layout.radii[2]));
    });

    test('keeps every petal on screen without overlapping', () {
      final centre = const Offset(760, 1160);
      final layout = tuiMagicQuarterLayout(
        centre: centre,
        bounds: screen,
        count: tuiMagicQuarterKeys.length,
        tiers: 3,
      );
      final points = [
        for (final s in layout.slots) petalCentre(centre, s.angle, s.radius),
      ];
      for (final p in points) {
        expect(p.dx - layout.petal / 2, greaterThanOrEqualTo(-0.5));
        expect(p.dy - layout.petal / 2, greaterThanOrEqualTo(-0.5));
        expect(p.dx + layout.petal / 2, lessThanOrEqualTo(screen.width + 0.5));
        expect(p.dy + layout.petal / 2, lessThanOrEqualTo(screen.height + 0.5));
      }
      for (var i = 0; i < points.length; i++) {
        for (var j = i + 1; j < points.length; j++) {
          expect(
            (points[i] - points[j]).distance,
            greaterThanOrEqualTo(layout.petal - 1),
          );
        }
      }
    });

    test('honours the requested tier count', () {
      final layout = tuiMagicQuarterLayout(
        centre: const Offset(760, 1160),
        bounds: screen,
        count: 12,
        tiers: 2,
      );
      expect(layout.radii, hasLength(2));
      expect(layout.slots.map((s) => s.tier).toSet(), {0, 1});
    });

    test('aims at the nearest petal inside the fan', () {
      final layout = tuiMagicQuarterLayout(
        centre: const Offset(760, 1160),
        bounds: screen,
        count: 8,
        tiers: 2,
      );
      final slot = layout.slots.first;
      final drag = Offset(
        slot.radius * math.sin(slot.angle),
        -slot.radius * math.cos(slot.angle),
      );
      expect(
        tuiMagicQuarterPetalFor(
          drag,
          layout.slots,
          start: layout.start,
          sweep: layout.sweep,
        ),
        0,
      );
      expect(
        tuiMagicQuarterPetalFor(
          const Offset(6, -6),
          layout.slots,
          start: layout.start,
          sweep: layout.sweep,
        ),
        isNull,
      );
    });
  });

  test('default ring labels', () {
    expect(tuiMagicKeys.map((k) => k.label), [
      '↑',
      'ESC',
      '→',
      'TAB',
      '↓',
      '^C',
      '←',
      '^D',
    ]);
    expect(tuiMagicSubKeys['↑']!.first.label, 'PGUP');
  });

  test('quarter keys cover the sshbox set', () {
    expect(tuiMagicQuarterKeys.length, 20);
    expect(
      tuiMagicQuarterKeys.map((k) => k.label),
      containsAll(['↑', 'ESC', 'HOME', '^R']),
    );
  });

  testWidgets('tap emits enter label', (tester) async {
    String? emitted;
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.mocha),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: TuiMagicKey(
              initialSpot: const Offset(0.5, 0.5),
              onEmit: (l) => emitted = l,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('tui-magic-key-button')));
    await tester.pump();
    expect(emitted, tuiMagicEnterLabel);
  });

  testWidgets('long press opens ring petals', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.mocha),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: TuiMagicKey(
              initialSpot: const Offset(0.5, 0.5),
              onEmit: (_) {},
            ),
          ),
        ),
      ),
    );

    final center =
        tester.getCenter(find.byKey(const ValueKey('tui-magic-key-button')));
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('ESC'), findsOneWidget);
    expect(find.text('↑'), findsOneWidget);
    await gesture.up();
    await tester.pump();
  });

  testWidgets('quarter long press opens many flat keys', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TermulTheme.of(TermulPalette.mocha),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 700,
            child: TuiMagicKey(
              shape: TuiMagicKeyShape.quarter,
              tiers: 3,
              initialSpot: const Offset(0.92, 0.9),
              onEmit: (_) {},
            ),
          ),
        ),
      ),
    );

    final center =
        tester.getCenter(find.byKey(const ValueKey('tui-magic-key-button')));
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('ESC'), findsOneWidget);
    expect(find.text('PGUP'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('^R'), findsOneWidget);
    await gesture.up();
    await tester.pump();
  });
}

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../components/components.dart';
import '../state/termul_controller.dart';
import '../theme/termul_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final TermulController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pages;
  int _index = 0;

  static const _slides = [
    (
      title: 'Agents that\nlive here',
      body:
          'Termul is the runtime your coding agents live on. Real terminals stay open on your phone — walk away, they keep working.',
      label: '01  RUNTIME',
    ),
    (
      title: 'SSH to your\nmachines',
      body:
          'Attach to a laptop, desktop, or rented box over SSH. Spaces and agents sit alongside each other in one mobile shell.',
      label: '02  CONNECT',
    ),
    (
      title: 'Tabs, panes,\nprompts',
      body:
          'Open tabs for each session. Type chat or shell prompts at the bottom — the herd stays attached until you disconnect.',
      label: '03  WORK',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = PageController();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    _pages.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _goTo(_index + 1);
    } else {
      widget.controller.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final slide = _slides[_index];
    final last = _index == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Container(width: 10, height: 10, color: p.deep),
                  const SizedBox(width: 10),
                  Text(
                    'TERMUL',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: p.deep,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const Spacer(),
                  if (!last)
                    GestureDetector(
                      onTap: widget.controller.completeOnboarding,
                      child: Text(
                        'SKIP',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: p.dim,
                              letterSpacing: 0.4,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  },
                  scrollbars: false,
                ),
                child: PageView.builder(
                  controller: _pages,
                  itemCount: _slides.length,
                  allowImplicitScrolling: true,
                  physics: const PageScrollPhysics(
                    parent: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: p.accent,
                                  letterSpacing: 0.4,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.title,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(color: p.accent),
                          ),
                          const SizedBox(height: 24),
                          if (i == 1)
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                color: p.accent,
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _AsciiSessionAnim()),
                                    SizedBox(height: 12),
                                    Text(
                                      'ssh user@host\nport 22\nkeep-alive',
                                      style: TextStyle(
                                        fontFamily: TermulFonts.mono,
                                        color: Color(0xFFE8E6E0),
                                        fontSize: 13,
                                        height: 1.6,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (i == 2)
                            const Expanded(child: _ButterflyArt())
                          else if (i == 0)
                            Text(
                              s.body,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: p.text, height: 1.5),
                            )
                          else
                            const Spacer(),
                          if (i == 1) ...[
                            const SizedBox(height: 20),
                            Text(
                              s.body,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: p.muted, height: 1.5),
                            ),
                          ],
                          if (i == 0) const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (last) ...[
                    Text(
                      slide.body,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: p.muted,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        GestureDetector(
                          onTap: () => _goTo(i),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              width: i == _index ? 24 : 8,
                              height: 3,
                              margin: const EdgeInsets.only(right: 6),
                              color: i == _index ? p.accent : p.border,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${_index + 1} / ${_slides.length}',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: p.dim,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TuiButton(
                      label: last ? 'enter home' : 'continue',
                      prefix: last ? '▸' : '/',
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dot-art butterflies for the work slide.
class _ButterflyArt extends StatefulWidget {
  const _ButterflyArt();

  @override
  State<_ButterflyArt> createState() => _ButterflyArtState();
}

class _ButterflyArtState extends State<_ButterflyArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        return Transform.translate(
          offset: Offset(0, (t - 0.5) * 10),
          child: child,
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Image.asset(
            'assets/images/onboarding_butterflies.png',
            fit: BoxFit.contain,
            color: p.accent,
            colorBlendMode: BlendMode.srcIn,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

/// Looping terminal session scribbles inside the connect panel.
class _AsciiSessionAnim extends StatefulWidget {
  const _AsciiSessionAnim();

  @override
  State<_AsciiSessionAnim> createState() => _AsciiSessionAnimState();
}

class _AsciiSessionAnimState extends State<_AsciiSessionAnim> {
  static const _lines = <String>[
    r'$ ssh -p 22 user@box',
    'resolving host...',
    'handshake ok',
    'authenticated',
    'pty /dev/pts/3',
    'agent tty-1 attached',
  ];

  static const _spin = <String>['|', '/', '-', r'\'];

  int _visible = 1;
  int _spinIdx = 0;
  bool _cursorOn = true;
  Timer? _lineTimer;
  Timer? _spinTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _lineTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() {
        if (_visible < _lines.length) {
          _visible++;
        } else {
          _visible = 1;
        }
      });
    });
    _spinTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() => _spinIdx = (_spinIdx + 1) % _spin.length);
    });
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 480), (_) {
      if (!mounted) return;
      setState(() => _cursorOn = !_cursorOn);
    });
  }

  @override
  void dispose() {
    _lineTimer?.cancel();
    _spinTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFE8E6E0);
    final busy = _visible < _lines.length;
    final rows = <String>[
      for (var i = 0; i < _visible; i++)
        i == 0
            ? _lines[i]
            : (busy && i == _visible - 1)
                ? '> ${_lines[i]} ${_spin[_spinIdx]}'
                : '> ${_lines[i]}',
    ];
    if (!busy) {
      rows.add(_cursorOn ? '> _' : '>  ');
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        rows.join('\n'),
        style: const TextStyle(
          fontFamily: TermulFonts.mono,
          color: ink,
          fontSize: 12,
          height: 1.55,
          letterSpacing: 0.2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

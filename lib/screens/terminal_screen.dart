import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../components/components.dart';
import '../models/models.dart';
import '../state/termul_controller.dart';
import '../theme/termul_palette.dart';
import '../theme/termul_theme.dart';

/// How the user types into the session.
enum TerminalInputMode {
  /// Form + OS soft keyboard.
  chat,

  /// Cursor lives in the terminal pane + custom keyboard (laptop feel).
  tty,
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key, required this.controller});

  final TermulController controller;

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen>
    with SingleTickerProviderStateMixin {
  final _chat = TextEditingController();
  final _chatFocus = FocusNode();
  final _tty = TextEditingController();
  final _scroll = ScrollController();

  TerminalInputMode _mode = TerminalInputMode.tty;
  bool _promptFullscreen = false;
  bool _ttyKeyboardVisible = true;

  final List<String> _history = [];
  int _historyIndex = -1;

  late final AnimationController _caretBlink;

  TermulController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _tty.addListener(_onTtyChanged);
    _caretBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  void _onTtyChanged() {
    if (_mode == TerminalInputMode.tty) setState(() {});
  }

  @override
  void dispose() {
    _tty.removeListener(_onTtyChanged);
    _caretBlink.dispose();
    _chat.dispose();
    _chatFocus.dispose();
    _tty.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _setMode(TerminalInputMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _promptFullscreen = false;
      if (mode == TerminalInputMode.tty) {
        _chatFocus.unfocus();
        _ttyKeyboardVisible = true;
        // Seed caret at end of current tty buffer.
        _tty.selection = TextSelection.collapsed(offset: _tty.text.length);
      } else {
        _ttyKeyboardVisible = false;
      }
    });
    if (mode == TerminalInputMode.chat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _chatFocus.requestFocus();
      });
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _pushHistory(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    _history.insert(0, t);
    if (_history.length > 50) _history.removeLast();
    _historyIndex = -1;
  }

  void _submitChat(String value) {
    _pushHistory(value);
    c.submitPrompt(value);
    _chat.clear();
    if (_promptFullscreen) setState(() => _promptFullscreen = false);
    _chatFocus.requestFocus();
    _scrollToEnd();
  }

  void _submitTty() {
    final value = _tty.text;
    _pushHistory(value);
    c.submitPrompt(value);
    _tty.clear();
    _tty.selection = const TextSelection.collapsed(offset: 0);
    setState(() {});
    _scrollToEnd();
  }

  void _historyUp(TextEditingController target) {
    if (_history.isEmpty) return;
    final next = (_historyIndex + 1).clamp(0, _history.length - 1);
    _historyIndex = next;
    target.text = _history[_historyIndex];
    target.selection = TextSelection.collapsed(offset: target.text.length);
    setState(() {});
  }

  void _historyDown(TextEditingController target) {
    if (_historyIndex <= 0) {
      _historyIndex = -1;
      target.clear();
      setState(() {});
      return;
    }
    _historyIndex--;
    target.text = _history[_historyIndex];
    target.selection = TextSelection.collapsed(offset: target.text.length);
    setState(() {});
  }

  Future<void> _confirmCloseTab(int index) async {
    if (c.tabs.length <= 1) return;
    final title = c.tabs[index].title;
    final p = TermulThemeData.of(context).palette;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: p.text.withValues(alpha: 0.35),
      builder: (ctx) {
        return Dialog(
          backgroundColor: p.panel,
          shape: const RoundedRectangleBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CLOSE TAB',
                    style: Theme.of(ctx).textTheme.labelSmall!.copyWith(
                          color: p.accent,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Close $title?',
                    style: Theme.of(ctx).textTheme.headlineMedium!.copyWith(
                          color: p.text,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The pane will be removed from this session. This cannot be undone.',
                    style: Theme.of(ctx).textTheme.bodySmall!.copyWith(
                          color: p.muted,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TuiButton(
                        label: 'cancel',
                        variant: TuiButtonVariant.ghost,
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                      const Spacer(),
                      TuiButton(
                        label: 'close tab',
                        variant: TuiButtonVariant.danger,
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      c.closeTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = c.terminalPalette;
    final conn = c.activeConnection!;
    final tab = c.tabs[c.activeTabIndex];
    final fontSize = c.terminalFontSize;
    final fontFamily = c.terminalFontFamily;
    final isChat = _mode == TerminalInputMode.chat;

    return Scaffold(
      resizeToAvoidBottomInset: isChat,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TerminalHeader(
              title: conn.displayName,
              subtitle: conn.endpoint,
              onBack: c.goHome,
              onSettings: c.openSettings,
            ),
            _TabBar(
              tabs: c.tabs,
              index: c.activeTabIndex,
              onSelect: c.selectTab,
              onAdd: c.addTab,
              onClose: _confirmCloseTab,
            ),
            if (isChat && _promptFullscreen)
              Expanded(
                child: _FullscreenChat(
                  controller: _chat,
                  focusNode: _chatFocus,
                  onSubmit: _submitChat,
                  onCollapse: () => setState(() => _promptFullscreen = false),
                ),
              )
            else ...[
              Expanded(
                flex: 1,
                child: ColoredBox(
                  color: term.panel,
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    itemCount: tab.lines.length + (isChat ? 0 : 1),
                    itemBuilder: (context, i) {
                      if (!isChat && i == tab.lines.length) {
                        return GestureDetector(
                          onTap: () => setState(() => _ttyKeyboardVisible = true),
                          child: _LiveTtyLine(
                            text: _tty.text,
                            caretIndex: _tty.selection.isValid
                                ? _tty.selection.baseOffset
                                : _tty.text.length,
                            blink: _caretBlink,
                            palette: term,
                            fontSize: fontSize,
                            fontFamily: fontFamily,
                          ),
                        );
                      }
                      return _Line(
                        line: tab.lines[i],
                        palette: term,
                        fontSize: fontSize,
                        fontFamily: fontFamily,
                      );
                    },
                  ),
                ),
              ),
              if (isChat)
                _CompactChat(
                  mode: _mode,
                  onModeChanged: _setMode,
                  controller: _chat,
                  focusNode: _chatFocus,
                  onSubmit: _submitChat,
                  onExpand: () {
                    setState(() => _promptFullscreen = true);
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      _chatFocus.requestFocus();
                    });
                  },
                )
              else ...[
                Material(
                  color: TermulThemeData.of(context).palette.bg,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: TermulThemeData.of(context).palette.border,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _InputModeHeader(
                      mode: _mode,
                      onModeChanged: _setMode,
                      onToggleKeyboard: () => setState(
                        () => _ttyKeyboardVisible = !_ttyKeyboardVisible,
                      ),
                      keyboardVisible: _ttyKeyboardVisible,
                    ),
                  ),
                ),
              ],
            ],
            if (!isChat && _ttyKeyboardVisible && !_promptFullscreen)
              TuiTerminalKeyboard(
                controller: _tty,
                onEnter: _submitTty,
                onHide: () => setState(() => _ttyKeyboardVisible = false),
                onArrowUp: () => _historyUp(_tty),
                onArrowDown: () => _historyDown(_tty),
              ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}
class _InputModeHeader extends StatelessWidget {
  const _InputModeHeader({
    required this.mode,
    required this.onModeChanged,
    this.onExpand,
    this.onToggleKeyboard,
    this.keyboardVisible = false,
  });

  final TerminalInputMode mode;
  final ValueChanged<TerminalInputMode> onModeChanged;
  final VoidCallback? onExpand;
  final VoidCallback? onToggleKeyboard;
  final bool keyboardVisible;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.keyboard_alt_outlined,
          selected: mode == TerminalInputMode.tty,
          tooltip: 'Keyboard',
          onTap: () => onModeChanged(TerminalInputMode.tty),
        ),
        const SizedBox(width: 6),
        _HeaderIconButton(
          icon: Icons.chat_bubble_outline,
          selected: mode == TerminalInputMode.chat,
          tooltip: 'Chat',
          onTap: () => onModeChanged(TerminalInputMode.chat),
        ),
        const Spacer(),
        if (onToggleKeyboard != null)
          Tooltip(
            message: keyboardVisible ? 'Hide keyboard' : 'Show keyboard',
            child: GestureDetector(
              onTap: onToggleKeyboard,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: p.border),
                ),
                child: Text(
                  keyboardVisible ? 'HIDE' : 'SHOW KEYBOARD',
                  style: TextStyle(
                    fontFamily: TermulFonts.mono,
                    fontSize: 10,
                    letterSpacing: 0.4,
                    color: p.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        if (onExpand != null) ...[
          if (onToggleKeyboard != null) const SizedBox(width: 6),
          _HeaderIconButton(
            icon: Icons.open_in_full,
            selected: false,
            tooltip: 'Full screen',
            onTap: onExpand!,
          ),
        ],
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? p.accent : Colors.transparent,
            border: Border.all(color: selected ? p.accent : p.border),
          ),
          child: Icon(
            icon,
            size: 16,
            color: selected ? p.bg : p.accent,
          ),
        ),
      ),
    );
  }
}

class _LiveTtyLine extends StatelessWidget {
  const _LiveTtyLine({
    required this.text,
    required this.caretIndex,
    required this.blink,
    required this.palette,
    required this.fontSize,
    required this.fontFamily,
  });

  final String text;
  final int caretIndex;
  final Animation<double> blink;
  final TermulPalette palette;
  final double fontSize;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    final i = caretIndex.clamp(0, text.length);
    final before = text.substring(0, i);
    final after = text.substring(i);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: fontSize + 6,
            child: Text(
              '❯',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: palette.accent,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSize,
                  color: palette.text,
                  height: 1.45,
                ),
                children: [
                  TextSpan(text: before),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: FadeTransition(
                      opacity: blink,
                      child: Container(
                        width: fontSize * 0.55,
                        height: fontSize * 1.1,
                        color: palette.accent,
                      ),
                    ),
                  ),
                  TextSpan(text: after),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactChat extends StatelessWidget {
  const _CompactChat({
    required this.mode,
    required this.onModeChanged,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onExpand,
  });

  final TerminalInputMode mode;
  final ValueChanged<TerminalInputMode> onModeChanged;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmit;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    return Material(
      color: p.bg,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InputModeHeader(
              mode: mode,
              onModeChanged: onModeChanged,
              onExpand: onExpand,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TuiInput(
                    controller: controller,
                    focusNode: focusNode,
                    hint: 'ask agent or run a command…',
                    useCustomKeyboard: false,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: onSubmit,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Send',
                  child: GestureDetector(
                    onTap: () => onSubmit(controller.text),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      color: p.accent,
                      child: Icon(
                        Icons.send,
                        size: 18,
                        color: p.panel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenChat extends StatelessWidget {
  const _FullscreenChat({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onCollapse,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    return Material(
      color: p.bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'COMMAND · FULL SCREEN',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: p.accent,
                        letterSpacing: 0.4,
                      ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Collapse',
                  child: GestureDetector(
                    onTap: onCollapse,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: p.border),
                      ),
                      child: Icon(
                        Icons.close_fullscreen,
                        size: 16,
                        color: p.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.panel,
                  border: Border.all(color: p.border),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  cursorColor: p.accent,
                  style: TextStyle(
                    fontFamily: TermulFonts.mono,
                    fontSize: 14,
                    color: p.text,
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '❯ ask agent or run a command…',
                    hintStyle: TextStyle(
                      fontFamily: TermulFonts.mono,
                      fontSize: 14,
                      color: p.dim,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: 'Send',
                child: GestureDetector(
                  onTap: () => onSubmit(controller.text),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    color: p.accent,
                    child: Icon(
                      Icons.send,
                      size: 18,
                      color: p.panel,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  const _TerminalHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: p.bg,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Text(
              '←',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: p.accent,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: p.text,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'SSH · ${subtitle.toUpperCase()}',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: p.dim,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: p.accent,
            child: Text(
              'LIVE',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: p.bg,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSettings,
            child: Icon(Icons.settings_outlined, size: 18, color: p.accent),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tabs,
    required this.index,
    required this.onSelect,
    required this.onAdd,
    required this.onClose,
  });

  final List<TerminalTab> tabs;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<int> onClose;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final canClose = tabs.length > 1;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: p.sidebar,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, i) {
                final selected = i == index;
                return Container(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? p.panel : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: selected ? p.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => onSelect(i),
                        child: Text(
                          tabs[i].title,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: selected ? p.accent : p.muted,
                                    fontWeight: selected
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: canClose ? () => onClose(i) : null,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: canClose
                                ? (selected ? p.accent : p.dim)
                                : p.border,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: p.border)),
              ),
              child: Text(
                '+',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: p.accent,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.line,
    required this.palette,
    required this.fontSize,
    required this.fontFamily,
  });

  final TerminalLine line;
  final TermulPalette palette;
  final double fontSize;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    final color = switch (line.kind) {
      TerminalLineKind.system => palette.dim,
      TerminalLineKind.stderr => palette.red,
      TerminalLineKind.prompt => palette.text,
      TerminalLineKind.agent => palette.accent,
      TerminalLineKind.stdout => palette.text,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (line.prefix != null) ...[
            SizedBox(
              width: fontSize + 6,
              child: Text(
                line.prefix!,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: color,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              line.text.isEmpty ? ' ' : line.text,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                color: color,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

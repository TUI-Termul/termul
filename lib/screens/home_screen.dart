import 'package:flutter/material.dart';

import '../components/components.dart';
import '../models/models.dart';
import '../state/termul_controller.dart';
import '../theme/termul_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final TermulController controller;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final empty = controller.connections.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HomeHeader(
              onSettings: controller.openSettings,
            ),
            Expanded(
              child: empty
                  ? _EmptyState(onAdd: controller.openAddConnection)
                  : _ConnectionList(
                      connections: controller.connections,
                      connecting: controller.connecting,
                      onConnect: controller.connect,
                      onRemove: controller.removeConnection,
                    ),
            ),
            if (!empty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TuiButton(
                    label: 'add ssh connection',
                    prefix: '+',
                    onPressed: controller.connecting
                        ? null
                        : controller.openAddConnection,
                  ),
                ),
              ),
            if (controller.connecting)
              Container(
                color: p.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'CONNECTING…',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: p.bg,
                        letterSpacing: 0.6,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onSettings,
  });

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
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
          GestureDetector(
            onTap: onSettings,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: p.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No SSH\nyet',
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: p.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'Add a host to attach terminals and coding agents. You need IP, port, username, and password.',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: p.text,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            color: p.accent,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIRST CONNECTION',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: p.bg,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your agents live on the machine you SSH into — Termul just holds the panes open on mobile.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: p.bg,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: TuiButton(
              label: 'add ssh connection',
              prefix: '+',
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionList extends StatelessWidget {
  const _ConnectionList({
    required this.connections,
    required this.connecting,
    required this.onConnect,
    required this.onRemove,
  });

  final List<SshConnection> connections;
  final bool connecting;
  final Future<void> Function(SshConnection) onConnect;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      children: [
        Text(
          'Hosts',
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(color: p.accent, fontSize: 36),
        ),
        const SizedBox(height: 8),
        Text(
          '${connections.length} SSH connection${connections.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: p.dim,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: p.border),
        const SizedBox(height: 8),
        for (final c in connections) ...[
          _ConnectionRow(
            connection: c,
            enabled: !connecting,
            onTap: () => onConnect(c),
            onRemove: () => onRemove(c.id),
          ),
          Container(height: 1, color: p.border),
        ],
      ],
    );
  }
}

class _ConnectionRow extends StatefulWidget {
  const _ConnectionRow({
    required this.connection,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  final SshConnection connection;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends State<_ConnectionRow> {
  Future<void> _confirmRemove() async {
    if (!widget.enabled) return;
    final p = TermulThemeData.of(context).palette;
    final name = widget.connection.displayName;

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
                    'REMOVE HOST',
                    style: Theme.of(ctx).textTheme.labelSmall!.copyWith(
                          color: p.accent,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Remove $name?',
                    style: Theme.of(ctx).textTheme.headlineMedium!.copyWith(
                          color: p.text,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This connection will be deleted from the list. You can add it again later.',
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
                        label: 'remove',
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
      widget.onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final c = widget.connection;
    final last = c.lastConnectedAt;

    return InkWell(
      onTap: widget.enabled ? widget.onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    c.displayName,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: p.accent,
                          fontSize: 22,
                        ),
                  ),
                ),
                Text(
                  'CONNECT',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: widget.enabled ? p.accent : p.dim,
                        letterSpacing: 0.4,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              c.endpoint.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: p.dim,
                    letterSpacing: 0.4,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: last != null
                      ? Text(
                          'LAST · ${_fmt(last)}',
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: p.muted,
                                    letterSpacing: 0.3,
                                  ),
                        )
                      : const SizedBox.shrink(),
                ),
                GestureDetector(
                  onTap: widget.enabled ? _confirmRemove : null,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      'REMOVE',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: p.dim,
                            letterSpacing: 0.4,
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

  String _fmt(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

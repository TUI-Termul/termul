import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/components.dart';
import '../state/termul_controller.dart';
import '../theme/termul_theme.dart';

class AddConnectionScreen extends StatefulWidget {
  const AddConnectionScreen({super.key, required this.controller});

  final TermulController controller;

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  final _label = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '22');
  final _user = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    _host.dispose();
    _port.dispose();
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final host = _host.text.trim();
    final user = _user.text.trim();
    final port = int.tryParse(_port.text.trim()) ?? 0;
    final pass = _pass.text;

    if (host.isEmpty || user.isEmpty || pass.isEmpty || port <= 0) {
      setState(() => _error = 'Fill IP/host, port, username, and password.');
      return;
    }

    setState(() => _error = null);
    await widget.controller.addAndConnect(
      host: host,
      port: port,
      username: user,
      password: pass,
      label: _label.text,
    );

    if (widget.controller.connectError != null && mounted) {
      setState(() => _error = widget.controller.connectError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final busy = widget.controller.connecting;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: busy ? null : widget.controller.goHome,
                    child: Text(
                      '← BACK',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: p.dim,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'NEW SSH',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: p.accent,
                          letterSpacing: 0.4,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add\nhost',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(color: p.accent),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'IP or hostname, port, username, and password. Label is optional.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: p.muted,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 28),
                    TuiField(
                      label: 'label (optional)',
                      controller: _label,
                      hint: 'macbook · staging',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TuiField(
                      label: 'ip / host',
                      controller: _host,
                      hint: '192.168.1.10',
                      autofocus: true,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TuiField(
                      label: 'port',
                      controller: _port,
                      hint: '22',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TuiField(
                      label: 'username',
                      controller: _user,
                      hint: 'ubuntu',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),
                    TuiField(
                      label: 'password',
                      controller: _pass,
                      hint: '••••••••',
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => busy ? null : _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: p.deep,
                            ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TuiButton(
                        label: busy ? 'connecting…' : 'save & connect',
                        prefix: '▸',
                        onPressed: busy ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

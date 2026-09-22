import 'package:flutter/foundation.dart';

@immutable
class SshConnection {
  const SshConnection({
    required this.id,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.label,
    this.lastConnectedAt,
  });

  final String id;
  final String host;
  final int port;
  final String username;
  final String password;
  final String? label;
  final DateTime? lastConnectedAt;

  String get displayName => label?.trim().isNotEmpty == true
      ? label!.trim()
      : '$username@$host';

  String get endpoint => '$host:$port';

  SshConnection copyWith({
    String? label,
    DateTime? lastConnectedAt,
  }) {
    return SshConnection(
      id: id,
      host: host,
      port: port,
      username: username,
      password: password,
      label: label ?? this.label,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }
}

enum TerminalLineKind { system, stdout, stderr, prompt, agent }

@immutable
class TerminalLine {
  const TerminalLine({
    required this.text,
    this.kind = TerminalLineKind.stdout,
    this.prefix,
  });

  final String text;
  final TerminalLineKind kind;
  final String? prefix;
}

@immutable
class TerminalTab {
  const TerminalTab({
    required this.id,
    required this.title,
    required this.lines,
  });

  final String id;
  final String title;
  final List<TerminalLine> lines;

  TerminalTab copyWith({
    String? title,
    List<TerminalLine>? lines,
  }) {
    return TerminalTab(
      id: id,
      title: title ?? this.title,
      lines: lines ?? this.lines,
    );
  }
}

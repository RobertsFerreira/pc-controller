import 'dart:convert';

final class Message {
  final String module;
  final String action;
  final Map<String, dynamic> params;

  const Message({
    required this.module,
    required this.action,
    this.params = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'module': module,
      'payload': {'action': action, ...params},
    };
  }

  String toJson() => jsonEncode(toMap());
}

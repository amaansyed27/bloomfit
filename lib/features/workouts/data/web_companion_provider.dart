import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebCompanionSessionNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setSession(String? code) {
    state = code;
  }
}

final webCompanionSessionProvider = NotifierProvider<WebCompanionSessionNotifier, String?>(
  () => WebCompanionSessionNotifier(),
);

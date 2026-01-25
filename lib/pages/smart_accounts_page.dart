import 'package:flutter/material.dart';
import 'dart:js_interop';

@JS('window')
external JSObject get _window;
extension WindowExt on JSObject {
  external set passkeyCreateOptions(JSAny? value);
  external set passkeyGetOptions(JSAny? value);
}

void setCreateOptions(Map<String, dynamic> options) {
  _window.passkeyCreateOptions = options.jsify();
}

void setGetOptions(Map<String, dynamic> options) {
  _window.passkeyGetOptions = options.jsify();
}

@JS('passkeys.create')
external JSPromise _jsCreatePasskey();

@JS('passkeys.sign')
external JSPromise _jsSignWithPasskey();

Future<dynamic> createPasskey() async {
  return await _jsCreatePasskey().toDart;
}

Future<dynamic> signWithPasskey() async {
  return await _jsSignWithPasskey().toDart;
}

class SmartAccountsPage extends StatelessWidget {
  const SmartAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("WalletsPage");
  }
}
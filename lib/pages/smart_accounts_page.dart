import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:sports/providers/auth_provider.dart';

@JS('passkeys.create')
external JSPromise createPasskeyJs(
    String userId,
    String userEmail,
    );

@JS('passkeys.sign')
external JSPromise signWithPasskeyJs(
    JSAny publicKeyOptions, // lo definiremos bien cuando armemos el flujo de login
    );

Future<Map<String, dynamic>> createPasskeyDart({
  required String userId,
  required String userEmail,
}) async {
  final jsResult = await createPasskeyJs(userId, userEmail).toDart;
  // jsResult es un String JSON
  final jsonString = jsResult as String;

  // Convertimos el String JSON a Map
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

// placeholder para más adelante, cuando definamos el flujo de sign
Future<Map<String, dynamic>> signWithPasskeyDart(JSAny publicKeyOptions) async {
  final jsResult = await signWithPasskeyJs(publicKeyOptions).toDart;
  return jsonDecode(jsonEncode(jsResult)) as Map<String, dynamic>;
}

class SmartAccountsPage extends StatefulWidget {
  const SmartAccountsPage({super.key});

  @override
  State<SmartAccountsPage> createState() => _SmartAccountsPageState();
}

class _SmartAccountsPageState extends State<SmartAccountsPage> {
  String? passkeyJson;

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    Map<String, dynamic>? idTokenPayload = authProv.decodeIdToken();
    final userId = idTokenPayload['sub'];
    final userEmail = idTokenPayload['email'];
    return Column(children: [
      ElevatedButton(onPressed: () async {
          final passkey = await createPasskeyDart(userId: userId, userEmail: userEmail);
          passkeyJson = const JsonEncoder.withIndent('  ').convert(passkey);
          setState(() {});
        },
      child: Text("Crear Passkey"),
      ),
      passkeyJson != null ? Text(passkeyJson!) : Container(),
    ]);
  }
}
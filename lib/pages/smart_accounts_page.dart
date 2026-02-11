import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports/providers/smart_account_provider.dart';
import 'package:sports/providers/auth_provider.dart';

class SmartAccountsPage extends StatefulWidget {
  const SmartAccountsPage({super.key});

  @override
  State<SmartAccountsPage> createState() => _SmartAccountsPageState();
}

class _SmartAccountsPageState extends State<SmartAccountsPage> {
  bool userAcknowledged = false;

  @override
  Widget build(BuildContext context) {
    final smartAccountProvider = context.watch<SmartAccountProvider>();
    final authProvider = context.watch<AuthProvider>();

    final isLoading = smartAccountProvider.state == PasskeyFlowState.requestingChallenge ||
        smartAccountProvider.state == PasskeyFlowState.waitingForWebAuthn ||
        smartAccountProvider.state == PasskeyFlowState.verifying;

    final isCompleted = smartAccountProvider.state == PasskeyFlowState.completed;

    final userEmail = authProvider.userEmail;
    final userId = authProvider.userId;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "To participate safely, you need to create your Smart Account. "
                  "This account is protected by a passkey stored securely on your device.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            const Text(
              "Before you continue, please review the following:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // --- EXPANDABLE SECTIONS ---
            ExpansionTile(
              title: const Text("1. Hardware‑level security"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Your Smart Account is protected by your device’s passkey "
                        "(FaceID, fingerprint, or PIN). The private key never leaves "
                        "your device and cannot be copied or extracted.",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),

            ExpansionTile(
              title: const Text("2. No passwords or seed phrases"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "You don’t need to remember or store anything. "
                        "There are no passwords to leak and no seed phrases to lose.",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),

            ExpansionTile(
              title: const Text("3. Recoverable if you lose your device"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Your Smart Account does not depend on a single device. "
                        "You can register additional devices or use recovery methods "
                        "to regain access if your phone is lost or stolen.",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),

            ExpansionTile(
              title: const Text("4. You remain in full control"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Every action requires your biometric approval. "
                        "No one can move your funds without your explicit authorization.",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),

            ExpansionTile(
              title: const Text("5. Built on modern, audited technology"),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Smart Accounts use open standards (WebAuthn, ERC‑4337) "
                        "and audited smart contracts. This ensures reliability, "
                        "security, and long‑term compatibility.",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            // --- CHECKBOX ---
            Row(
              children: [
                Checkbox(
                  value: userAcknowledged,
                  onChanged: (value) {
                    setState(() => userAcknowledged = value ?? false);
                  },
                ),
                const Expanded(
                  child: Text(
                    "I have read and understand how my Smart Account works.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SMART ACCOUNT CREATED ---
            if (isCompleted) ...[
              const Text(
                "Your Smart Account is ready:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SelectableText(
                smartAccountProvider.smartAccountAddress ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            // --- CREATE BUTTON ---
            if (!isCompleted) ...[
              Center(
                child: ElevatedButton(
                  onPressed: (!userAcknowledged || isLoading)
                      ? null
                      : () async {
                    await smartAccountProvider.createSmartAccount(
                      userId: userId ?? "test123",
                      userEmail: userEmail ?? "test123@correo.com",
                    );
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text("Create Smart Account"),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // --- ERROR MESSAGE ---
            if (smartAccountProvider.state == PasskeyFlowState.error &&
                smartAccountProvider.errorMessage != null)
              Text(
                smartAccountProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
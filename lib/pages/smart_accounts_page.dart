import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sports/providers/smart_account_provider.dart';
import 'package:sports/providers/auth_provider.dart';

class SmartAccountsPage extends StatelessWidget {
  const SmartAccountsPage({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation text
          const Text("To challenge safely, you need to create your Smart Account. "
            "This account is associated with a passkey on your device, which guarantees "
            "maximum security without passwords or private keys.",
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 32),

          // If Smart Account is created, show it
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

          // If not created, show the button
          if (!isCompleted) ...[
            Center(
              child: ElevatedButton(
                onPressed: isLoading
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

          // Error message
          if (smartAccountProvider.state == PasskeyFlowState.error &&
              smartAccountProvider.errorMessage != null)
            Text(
              smartAccountProvider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
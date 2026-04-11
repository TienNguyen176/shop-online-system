import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Next4Shop",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              // GOOGLE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                    height: 24,
                  ),
                  label: const Text("Continue with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed:
                      auth.loading
                          ? null
                          : () async {
                            await auth.loginGoogle();

                            if (auth.accessToken != null && context.mounted) {
                              Navigator.pushReplacementNamed(context, "/home");
                            }
                            if (auth.error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.error!)),
                              );
                            }
                          },
                ),
              ),

              const SizedBox(height: 16),

              // FACEBOOK BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/124/124010.png',
                    height: 24,
                  ),
                  label: const Text("Continue with Facebook"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                  ),
                  onPressed:
                      auth.loading
                          ? null
                          : () async {
                            await auth.loginFacebook();

                            if (auth.accessToken != null && context.mounted) {
                              Navigator.pushReplacementNamed(context, "/home");
                            }
                            if (auth.error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.error!)),
                              );
                            }
                          },
                ),
              ),

              const SizedBox(height: 20),

              if (auth.loading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

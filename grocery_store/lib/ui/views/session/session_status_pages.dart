import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:provider/provider.dart';

class SessionLoadingPage extends StatelessWidget {
  const SessionLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class SessionErrorPage extends StatelessWidget {
  const SessionErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.cloud_off, size: 72),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage ?? 'Ocurrió un error inesperado.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.retry,
                child: const Text('Reintentar'),
              ),
              TextButton(
                onPressed: () => context.read<LoginProvider>().signOut(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

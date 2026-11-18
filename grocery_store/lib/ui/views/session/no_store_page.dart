import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:grocery_store/ui/views/session/archived_stores_page.dart';
import 'package:grocery_store/ui/views/session/join_store_page.dart';
import 'package:grocery_store/ui/views/session/store_form_page.dart';
import 'package:provider/provider.dart';

/// Shown when the user has no store to work in.
class NoStorePage extends StatelessWidget {
  const NoStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();
    final unavailable = controller.hasUnavailableStore;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                unavailable ? Icons.store_mall_directory_outlined : Icons.store,
                size: 96,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                unavailable
                    ? 'Tu tienda ya no está disponible'
                    : 'Aún no tienes una tienda',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                unavailable
                    ? 'La tienda a la que pertenecías fue archivada. '
                        'Abandónala para crear la tuya o unirte a otra.'
                    : 'Crea tu tienda para empezar a vender, o únete a una '
                        'con el código de invitación que te dio el dueño.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (unavailable)
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Abandonar tienda'),
                  onPressed: () => _leaveStore(context),
                )
              else ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_business),
                  label: const Text('Crear mi tienda'),
                  onPressed: controller.canCreateStore
                      ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const StoreFormPage(),
                          ))
                      : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.vpn_key_outlined),
                  label: const Text('Tengo un código de invitación'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const JoinStorePage()),
                  ),
                ),
              ],
              if (!unavailable && controller.archivedStores.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(
                      'Tiendas archivadas (${controller.archivedStores.length})'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ArchivedStoresPage()),
                  ),
                ),
              ],
              const SizedBox(height: 24),
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

  Future<void> _leaveStore(BuildContext context) async {
    final failure = await context.read<SessionController>().leaveStore();
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}

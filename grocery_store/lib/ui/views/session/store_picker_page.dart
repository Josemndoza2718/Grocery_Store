import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:grocery_store/ui/views/session/archived_stores_page.dart';
import 'package:grocery_store/ui/views/session/store_form_page.dart';
import 'package:provider/provider.dart';

/// Lets an owner choose which of their stores to work in.
class StorePickerPage extends StatelessWidget {
  const StorePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SessionController>();
    final stores = controller.ownedStores;
    final archivedCount = controller.archivedStores.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige una tienda'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<LoginProvider>().signOut(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: stores.length + (archivedCount > 0 ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == stores.length) {
            return Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.archive_outlined),
                label: Text('Tiendas archivadas ($archivedCount)'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ArchivedStoresPage()),
                ),
              ),
            );
          }
          final store = stores[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.store, size: 36),
              title: Text(store.name),
              subtitle: store.description.isEmpty
                  ? null
                  : Text(
                      store.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => controller.selectStore(store.id),
            ),
          );
        },
      ),
      floatingActionButton: controller.canCreateStore
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_business),
              label: const Text('Nueva tienda'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StoreFormPage()),
              ),
            )
          : null,
    );
  }
}

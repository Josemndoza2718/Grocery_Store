import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Archived stores of the owner, which can be restored.
class ArchivedStoresPage extends StatefulWidget {
  const ArchivedStoresPage({super.key});

  @override
  State<ArchivedStoresPage> createState() => _ArchivedStoresPageState();
}

class _ArchivedStoresPageState extends State<ArchivedStoresPage> {
  String? _restoringId;

  Future<void> _restore(Store store) async {
    setState(() => _restoringId = store.id);
    final messenger = ScaffoldMessenger.of(context);
    final failure =
        await context.read<SessionController>().restoreStore(store.id);
    // On success the app enters the restored store and this page is disposed.
    if (!mounted) return;
    setState(() => _restoringId = null);
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<SessionController>().archivedStores;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Tiendas archivadas')),
      body: stores.isEmpty
          ? const Center(child: Text('No tienes tiendas archivadas.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final store = stores[index];
                final restoring = _restoringId == store.id;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.archive_outlined, size: 32),
                    title: Text(store.name),
                    subtitle: Text(
                        'Archivada el ${dateFormat.format(store.updatedAt)}'),
                    trailing: restoring
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: _restoringId == null
                                ? () => _restore(store)
                                : null,
                            child: const Text('Restaurar'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}

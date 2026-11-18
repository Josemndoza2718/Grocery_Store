import 'package:flutter/material.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:provider/provider.dart';

/// Creates a new store, or edits [store] when provided (owner).
class StoreFormPage extends StatefulWidget {
  const StoreFormPage({super.key, this.store});

  final Store? store;

  @override
  State<StoreFormPage> createState() => _StoreFormPageState();
}

class _StoreFormPageState extends State<StoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.store?.name ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.store?.description ?? '');
  bool _saving = false;

  bool get _isEditing => widget.store != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final controller = context.read<SessionController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final failure = _isEditing
        ? await controller.updateStore(widget.store!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
          ))
        : await controller.createStore(
            name: _nameController.text,
            description: _descriptionController.text,
            // The device's current values become the store's initial
            // settings (from now on they live in the store).
            iva: double.tryParse(Prefs.getString(PrefKeys.iva) ?? '') ?? 0,
            exchangeRate: await Prefs.getMoneyConversion(),
          );

    // When a store is created the whole app switches to it and this page is
    // disposed, so only touch the UI if it is still mounted.
    if (!mounted) return;
    setState(() => _saving = false);

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    if (_isEditing) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tienda actualizada')),
      );
    }
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar tienda' : 'Nueva tienda'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la tienda',
                    hintText: 'Ej. Abasto Central',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa el nombre de la tienda'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 200,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Guardar cambios' : 'Crear tienda'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:provider/provider.dart';

/// Creates a new store, or — when [store] is given — is the store settings
/// screen (owner): name, description, IVA, exchange rate and archive.
class StoreFormPage extends StatefulWidget {
  const StoreFormPage({super.key, this.store});

  final Store? store;

  @override
  State<StoreFormPage> createState() => _StoreFormPageState();
}

class _StoreFormPageState extends State<StoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.store?.name ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.store?.description ?? '');
  final _ivaController = TextEditingController();
  final _rateController = TextEditingController();
  bool _saving = false;
  bool _archiving = false;

  bool get _isEditing => widget.store != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _ivaController.text = _format(widget.store!.iva);
      _rateController.text = _format(widget.store!.exchangeRate);
    } else {
      _loadDeviceDefaults();
    }
  }

  /// For a new store, propose the values this device used before.
  Future<void> _loadDeviceDefaults() async {
    final iva = double.tryParse(Prefs.getString(PrefKeys.iva) ?? '') ?? 0;
    final rate = await Prefs.getMoneyConversion();
    if (!mounted) return;
    _ivaController.text = _format(iva);
    _rateController.text = _format(rate);
  }

  static String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  /// Accepts "36,50" or "36.50".
  static double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ivaController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final controller = context.read<SessionController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final iva = _parse(_ivaController.text) ?? 0;
    final rate = _parse(_rateController.text) ?? 0;

    final failure = _isEditing
        ? await controller.updateStore(widget.store!.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            iva: iva,
            exchangeRate: rate,
          ))
        : await controller.createStore(
            name: _nameController.text,
            description: _descriptionController.text,
            iva: iva,
            exchangeRate: rate,
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

  Future<void> _confirmArchive() async {
    final name = widget.store!.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('¿Archivar "$name"?'),
        content: const Text(
          '• La tienda desaparecerá de tu lista.\n'
          '• Todos sus empleados serán desvinculados y las invitaciones '
          'pendientes se anularán.\n'
          '• Sus productos, clientes, carritos y ventas NO se borran.\n\n'
          'Podrás restaurarla cuando quieras desde "Tiendas archivadas".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archivar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _archiving = true);
    final messenger = ScaffoldMessenger.of(context);
    final failure =
        await context.read<SessionController>().archiveCurrentStore();
    // On success the app leaves this store and this page is disposed.
    if (!mounted) return;
    setState(() => _archiving = false);
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Configuración de la tienda' : 'Nueva tienda'),
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
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ivaController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: numberFormatters,
                        decoration: const InputDecoration(
                          labelText: 'IVA (%)',
                          prefixIcon: Icon(Icons.percent),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final iva = _parse(value ?? '');
                          if (iva == null || iva < 0 || iva > 100) {
                            return 'Entre 0 y 100';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: numberFormatters,
                        decoration: const InputDecoration(
                          labelText: 'Tasa (Bs/\$)',
                          prefixIcon: Icon(Icons.currency_exchange),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final rate = _parse(value ?? '');
                          if (rate == null || rate < 0) {
                            return 'Número válido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                if (_isEditing) ...[
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Zona de riesgo',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Archivar la tienda desvincula a sus empleados. Sus datos '
                    'se conservan y puedes restaurarla después.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _archiving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.archive_outlined),
                    label: const Text('Archivar tienda'),
                    onPressed: _archiving ? null : _confirmArchive,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

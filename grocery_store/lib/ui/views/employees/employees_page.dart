import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/domain/entities/employee.dart';
import 'package:grocery_store/domain/entities/invitation.dart';
import 'package:grocery_store/domain/entities/store.dart';
import 'package:grocery_store/ui/view_model/session/employees_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Owner screen: employees of the store and pending invitation codes.
class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeesViewModel>().start();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static String _shareText(Invitation invitation) =>
      'Te invito a trabajar en "${invitation.storeName}". '
      'Descarga la app, crea tu cuenta y en "Tengo un código de invitación" '
      'escribe el código ${invitation.displayCode} '
      '(válido por ${Invitation.validity.inHours} horas, un solo uso).';

  Future<void> _share(Invitation invitation) async {
    try {
      await SharePlus.instance.share(ShareParams(text: _shareText(invitation)));
    } catch (e) {
      _snack('No se pudo abrir el menú de compartir');
    }
  }

  Future<void> _createInvitation() async {
    final storeName = context.read<Store>().name;
    final vm = context.read<EmployeesViewModel>();
    final result = await vm.createInvitation(storeName);
    if (!mounted) return;
    if (result.failure != null) {
      _snack(result.failure!.message);
      return;
    }
    final invitation = result.invitation;
    if (invitation != null) _showCodeDialog(invitation);
  }

  void _showCodeDialog(Invitation invitation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Código de invitación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              invitation.displayCode,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Compártelo con tu empleado. Sirve una sola vez y caduca en '
              '${Invitation.validity.inHours} horas.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: invitation.displayCode));
              _snack('Código copiado');
            },
            child: const Text('Copiar'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _share(invitation);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(Employee employee) async {
    final name = employee.name.isNotEmpty ? employee.name : employee.email;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Desvincular empleado?'),
        content: Text(
          '$name perderá el acceso a la tienda de inmediato. Para volver '
          'necesitará una nueva invitación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Desvincular',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final failure =
        await context.read<EmployeesViewModel>().removeEmployee(employee.uid);
    _snack(failure?.message ?? '$name fue desvinculado');
  }

  Future<void> _revoke(Invitation invitation) async {
    final failure = await context
        .read<EmployeesViewModel>()
        .revokeInvitation(invitation.code);
    _snack(failure?.message ?? 'Invitación revocada');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeesViewModel>();
    final expiresFormat = DateFormat('dd/MM HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      floatingActionButton: FloatingActionButton.extended(
        icon: vm.isCreatingInvitation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add_alt_1),
        label: const Text('Invitar empleado'),
        onPressed: vm.isCreatingInvitation ? null : _createInvitation,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _SectionTitle('Empleados (${vm.employees.length})'),
                    if (vm.employees.isEmpty)
                      const _EmptyHint(
                        'Aún no tienes empleados. Pulsa "Invitar empleado" '
                        'y comparte el código.',
                      ),
                    for (final employee in vm.employees)
                      Card(
                        child: ListTile(
                          leading:
                              const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(employee.name.isNotEmpty
                              ? employee.name
                              : 'Sin nombre'),
                          subtitle: employee.email.isEmpty
                              ? null
                              : Text(employee.email),
                          trailing: IconButton(
                            tooltip: 'Desvincular',
                            icon: const Icon(Icons.person_remove,
                                color: Colors.redAccent),
                            onPressed: () => _confirmRemove(employee),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                        'Invitaciones pendientes (${vm.pendingInvitations.length})'),
                    if (vm.pendingInvitations.isEmpty)
                      const _EmptyHint('No hay invitaciones pendientes.'),
                    for (final invitation in vm.pendingInvitations)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.vpn_key_outlined),
                          title: Text(
                            invitation.displayCode,
                            style: const TextStyle(
                                letterSpacing: 2, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Caduca: ${expiresFormat.format(invitation.expiresAt)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Compartir',
                                icon: const Icon(Icons.share),
                                onPressed: () => _share(invitation),
                              ),
                              IconButton(
                                tooltip: 'Revocar',
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () => _revoke(invitation),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );
}

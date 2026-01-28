import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/resource/custom_dialgos.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/ui/widgets/general_textformfield.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final TextEditingController _ivaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // CUENTA Section
        _buildSectionHeader('CUENTA'),
        _buildSettingsTile(
          context,
          icon: Icons.person_outline,
          title: 'Información Personal',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Próximamente')));
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.lock_outline,
          title: 'Cambiar Contraseña',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Próximamente')));
          },
        ),

        const SizedBox(height: 24),

        // PREFERENCIAS Section
        _buildSectionHeader('PREFERENCIAS'),
        _buildSettingsTile(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notificaciones',
          onTap: () {
            /* Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              ); */
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.category_outlined,
          title: 'Categorias',
          onTap: () {
            /*  Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              ); */
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.percent_outlined,
          title: 'Definir Impuestos',
          onTap: () {
            CustomDialgos.showAlertDialog(
              context: context,
              title: 'Definir Impuestos',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GeneralTextformfield(
                    controller: _ivaController,
                    hintText: 'IVA',
                    keyboardType: const TextInputType.numberWithOptions(signed: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un valor';
                      }
                      return null;
                    },
                  )
                ],
              ),
              onConfirm: () {
                Prefs.setString(PrefKeys.iva, _ivaController.text).then((value) {
                  Navigator.pop(context);
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impuestos guardados')));
                  }
                });
              },
            );
          },
        ),

        const SizedBox(height: 24),

        // PRIVACIDAD Y SEGURIDAD Section
        _buildSectionHeader('PRIVACIDAD Y SEGURIDAD'),
        _buildSettingsTile(
          context,
          icon: Icons.storage_outlined,
          title: 'Gestionar Datos',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Próximamente')));
          },
        ),
        _buildSettingsTile(
          context,
          icon: Icons.link_outlined,
          title: 'Cuentas Vinculadas',
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Próximamente')));
          },
        ),

        const SizedBox(height: 32),

        // Action Buttons
        _buildActionButton(
          context,
          label: 'Cerrar Sesión',
          color: Colors.redAccent,
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          label: 'Eliminar Cuenta',
          color: Colors.red.shade700,
          onTap: () {
            _showDeleteAccountDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return _AnimatedSettingsTile(icon: icon, title: title, onTap: onTap);
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _AnimatedActionButton(label: label, color: color, onTap: onTap),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '¿Cerrar Sesión?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () async {
              Provider.of<LoginProvider>(context, listen: false).signOut();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '¿Eliminar Cuenta?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción es permanente y no se puede deshacer. Todos tus datos serán eliminados.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad próximamente'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated settings tile
class _AnimatedSettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AnimatedSettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_AnimatedSettingsTile> createState() => _AnimatedSettingsTileState();
}

class _AnimatedSettingsTileState extends State<_AnimatedSettingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.lightgrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green, //Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated action button
class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

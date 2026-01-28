import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Expresiones regulares para validación
  final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-]).{8,}$');
  final RegExp _phoneRegExp = RegExp(r'^[0-9]{7,}$'); // Mínimo 7 dígitos

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Función de registro
  void _submitRegistration(LoginProvider provider) async {
    if (_formKey.currentState!.validate()) {
      final userCredential = await provider.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        isAdmin: provider.isAdmin,
      );

      if (userCredential != null && mounted) {
        // Registro exitoso, puedes cerrar esta pantalla o navegar a Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso!')),
        );
        Navigator.of(context).pop(); // Volver a la pantalla de Login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Consumer<LoginProvider>(
            builder: (context, loginProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.person_add, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),

                  // 1. Campo de Nombre
                  _buildTextFormField(
                    controller: _nameController,
                    label: 'Nombre Completo',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Campo de Correo
                  _buildTextFormField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su correo electrónico';
                      }
                      if (!_emailRegExp.hasMatch(value)) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Campo de Contraseña
                  _buildPasswordFormField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    isVisible: loginProvider.isPasswordVisible,
                    toggleVisibility: loginProvider.togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese una contraseña';
                      }
                      if (!_passwordRegExp.hasMatch(value)) {
                        return 'Mínimo 8 caracteres: mayúscula, minúscula, número y especial.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Campo de Repetir Contraseña
                  _buildPasswordFormField(
                    controller: _confirmPasswordController,
                    label: 'Repetir Contraseña',
                    isVisible: loginProvider.isPasswordConfirmVisible,
                    toggleVisibility:
                        loginProvider.togglePasswordConfirmVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme su contraseña';
                      }
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 5. Campo de Teléfono
                  _buildTextFormField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese su número de teléfono';
                      }
                      if (!_phoneRegExp.hasMatch(value)) {
                        return 'El teléfono debe tener al menos 7 dígitos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 6. Toggle Buttons para Rol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Seleccionar Rol:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      // El rol se maneja en el proveedor
                      Switch.adaptive(
                        value: loginProvider.isAdmin,
                        onChanged: loginProvider.toggleRole,
                        activeColor: Colors.blue,
                      ),
                      Text(
                        loginProvider.isAdmin
                            ? 'Administrador'
                            : 'Usuario Normal',
                        style: TextStyle(
                            color: loginProvider.isAdmin
                                ? Colors.blue
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Mostrar mensaje de error si existe
                  if (loginProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        loginProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Botón de Registro
                  ElevatedButton(
                    onPressed: loginProvider.isLoading
                        ? null
                        : () => _submitRegistration(loginProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: loginProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget Helper para campos de texto normales
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  // Widget Helper para campos de contraseña
  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}

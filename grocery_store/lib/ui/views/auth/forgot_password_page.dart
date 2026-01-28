import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();
    // Resetear el estado de recuperación al entrar a la pantalla
    // Usamos addPostFrameCallback para evitar errores de initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginProvider>(context, listen: false)
          .resetPasswordRecoveryState();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitRecovery(LoginProvider provider) {
    if (_formKey.currentState!.validate()) {
      provider.recoverPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Consumer<LoginProvider>(
            builder: (context, loginProvider, child) {
              // --- CONFIRMACIÓN DE ENVÍO EXITOSO ---
              if (loginProvider.isResetLinkSent) {
                return _buildSuccessMessage(context, _emailController.text);
              }

              // --- FORMULARIO DE SOLICITUD ---
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.lock_reset, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingresa tu correo para enviarte un enlace de restablecimiento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Campo de Correo
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El correo no puede estar vacío';
                      }
                      if (!_emailRegExp.hasMatch(value)) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de Envío
                  ElevatedButton(
                    onPressed: loginProvider.isLoading
                        ? null
                        : () => _submitRecovery(loginProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: loginProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Enviar Enlace de Restablecimiento'),
                  ),
                  const SizedBox(height: 20),

                  // Mostrar mensaje de error si existe
                  if (loginProvider.errorMessage != null)
                    Text(
                      loginProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget para mostrar el mensaje de éxito
  Widget _buildSuccessMessage(BuildContext context, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          '¡Enlace Enviado!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Hemos enviado un enlace seguro de restablecimiento de contraseña a:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Volver a la pantalla de Login
          },
          child: const Text('Volver a Iniciar Sesión'),
        ),
      ],
    );
  }
}

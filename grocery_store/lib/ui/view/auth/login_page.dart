import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view/auth/forgot_password_page.dart';
import 'package:grocery_store/ui/view/auth/register_page.dart';
import 'package:grocery_store/ui/view/origin/main_page.dart';
import 'package:grocery_store/ui/view_model/old/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: 'josemndoza2718@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '2718*1817Mma');

  final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp _passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+{}\[\]:;<>,.?~\\-]).{8,}$');

  // Aquí agregamos el listener
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      loginProvider.addListener(() {
        if (loginProvider.isLoggedIn) {
          Navigator.pushReplacement(
            //TODO: REVISAR ESTO EN EL FUTURO
            context,
            MaterialPageRoute(
                builder: (context) => const MainPage(selectedIndex: 0)),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Consumer<LoginProvider>(
            builder: (context, loginProvider, child) {
              return Column(
                // ... (El resto de tu UI se mantiene igual)
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(
                    Icons.shopping_cart,
                    size: 120,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 48),
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
                        return 'Por favor, ingrese su correo electrónico';
                      }
                      if (!_emailRegExp.hasMatch(value)) {
                        return 'Por favor, ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !loginProvider.isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Ingrese su contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          loginProvider.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          loginProvider.togglePasswordVisibility();
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su contraseña';
                      }
                      if (!_passwordRegExp.hasMatch(value)) {
                        return 'La contraseña no cumple con los requisitos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: loginProvider.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              loginProvider.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: loginProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : const Text('Iniciar Sesión'),
                  ),
                  if (loginProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        loginProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegistrationScreen()),
                      );
                    },
                    child: const Text('¿No tienes una cuenta? Regístrate'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

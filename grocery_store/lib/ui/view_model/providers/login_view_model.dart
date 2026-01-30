import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';

class LoginProvider with ChangeNotifier {
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false; // <-- NUEVA VARIABLE DE ESTADO
  bool _isAdmin = true;
  final _firestore = FirebaseFirestore.instance;
  bool _isResetLinkSent = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isPasswordConfirmVisible => _isPasswordConfirmVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn; // <-- NUEVO GETTER
  bool get isAdmin => _isAdmin;
  bool get isResetLinkSent => _isResetLinkSent;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Nuevo toggle para la confirmación de contraseña
  void togglePasswordConfirmVisibility() {
    _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
    notifyListeners();
  }

  // Toggle para seleccionar el rol
  void toggleRole(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoggedIn = true; // <-- CAMBIAMOS EL ESTADO A TRUE SI ES EXITOSO
      _isLoading = false;
      notifyListeners();

      print("¡Inicio de sesión exitoso!");
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'user-not-found') {
        _errorMessage = 'No se encontró un usuario con ese correo electrónico.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Contraseña incorrecta. Inténtelo de nuevo.';
      } else {
        _errorMessage = 'Ocurrió un error inesperado. Inténtelo de nuevo.';
      }
      notifyListeners();
      print("Error de Firebase: $_errorMessage");
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ocurrió un error inesperado: $e';
      notifyListeners();
      print("Error desconocido: $_errorMessage");
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signOut();
      _isLoggedIn = false; // <-- CAMBIAMOS EL ESTADO A FALSE AL CERRAR SESIÓN
      Prefs.clear();
      // Ya no necesitamos manejar _isLoggedIn, el StreamBuilder en main.dart lo hará por nosotros.
    } catch (e) {
      _errorMessage = 'Ocurrió un error al cerrar sesión.';
      print("Error al cerrar sesión: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required bool isAdmin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    UserCredential? userCredential;

    try {
      // 1. Crear el usuario en Firebase Authentication
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Guardar los metadatos en Cloud Firestore
        // La colección será 'users' y el ID del documento será el UID de Firebase Auth.

        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'isAdmin': isAdmin,
          'createdAt':
              FieldValue.serverTimestamp(), // Marca de tiempo del servidor
        });

        // 3. Opcional: Actualizar el nombre del usuario en Auth
        await user.updateDisplayName(name);
      }

      _isLoading = false;
      notifyListeners();
      print("¡Registro exitoso y datos guardados en Firestore!");
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de Auth...
      _isLoading = false;
      if (e.code == 'weak-password') {
        _errorMessage = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Ya existe una cuenta con ese correo electrónico.';
      } else {
        _errorMessage = 'Error de registro: ${e.message}';
      }
      notifyListeners();
      userCredential = null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ocurrió un error inesperado: ${e.toString()}';
      notifyListeners();

      // 🚨 PASO CRÍTICO: Si la escritura en Firestore falla, elimina el usuario de AUTH.
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!.delete();
      }
      userCredential = null;
    }

    return userCredential;
  }

  Future<void> recoverPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _isResetLinkSent = false; // Resetear estado antes de comenzar
    notifyListeners();

    try {
      // 1. Llamar al método de Firebase para enviar el enlace
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 2. Si el envío es exitoso
      _isResetLinkSent = true;
      _isLoading = false;
      notifyListeners();

      log("Enlace de restablecimiento enviado a $email");
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'user-not-found') {
        _errorMessage = 'No hay usuario registrado con ese correo.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'El formato del correo electrónico es inválido.';
      } else {
        _errorMessage = 'Error: No se pudo enviar el enlace de recuperación.';
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          'Ocurrió un error inesperado al solicitar el cambio de contraseña.';
      notifyListeners();
    }
  }

  // Método para resetear el estado del enlace (útil si el usuario vuelve a la pantalla)
  void resetPasswordRecoveryState() {
    _isResetLinkSent = false;
    _errorMessage = null;
    notifyListeners();
  }
}

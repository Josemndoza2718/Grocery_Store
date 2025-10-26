// role_decider_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/ui/view/home/widgets/admin_dashboard.dart';
import 'package:grocery_store/ui/view/home/widgets/user_dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aseguramos que haya un usuario autenticado
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // StreamBuilder para escuchar el documento del usuario en tiempo real
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        // Muestra un loader si los datos aún no están listos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Manejar errores o datos faltantes
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Esto puede indicar que el usuario de Auth existe, pero no en Firestore (un error de registro)
          return const Scaffold(
            body: Center(child: Text('Error: Datos de perfil no encontrados.')),
          );
        }

        // Decidir la navegación
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final isAdmin =
            data['isAdmin'] ?? false; // Leer el rol, por defecto false

        if (isAdmin) {
          return const AdminDashboard();
        } else {
          return const UserDashboard();
        }
      },
    );
  }
}

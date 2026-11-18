import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/app_theme.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/dependencies/di.dart';
import 'package:grocery_store/ui/views/auth/login_page.dart';
import 'package:grocery_store/ui/views/origin/main_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Prefs.init();

  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      path: 'lib/core/resource/langs',
      useFallbackTranslations: true,
      fallbackLocale: const Locale('es'),
      startLocale: const Locale('es'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...globalDi,
      ],
      // The auth state is listened ABOVE MaterialApp so that the session
      // providers (and the whole navigator) are rebuilt when the user changes.
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Muestra un indicador de carga mientras verifica el estado
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildApp(
              context,
              key: const ValueKey('auth-loading'),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final user = snapshot.data;

          // Si no hay usuario, muestra el LoginScreen
          if (user == null) {
            return _buildApp(
              context,
              key: const ValueKey('logged-out'),
              home: const LoginScreen(),
            );
          }

          // Usuario autenticado: los view models se crean para ESTE uid.
          // La key garantiza que al cambiar de usuario se desechen los
          // anteriores (y sus suscripciones a Firestore).
          return MultiProvider(
            key: ValueKey('session-${user.uid}'),
            providers: sessionDi(user.uid),
            child: _buildApp(
              context,
              home: const MainPage(selectedIndex: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApp(BuildContext context, {Key? key, required Widget home}) {
    return MaterialApp(
      key: key,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: home,
    );
  }
}

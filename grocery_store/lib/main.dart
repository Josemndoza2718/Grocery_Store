import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/app_theme.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/dependencies/di.dart';
import 'package:grocery_store/ui/views/auth/login_page.dart';
import 'package:grocery_store/dependencies/providers.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:grocery_store/ui/views/session/session_gate.dart';
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

          // Usuario autenticado: el SessionController (uno por uid) resuelve
          // en qué tienda trabaja y con qué rol; SessionGate muestra la
          // pantalla correspondiente y monta los view models de esa tienda.
          return ChangeNotifierProvider<SessionController>(
            key: ValueKey('user-${user.uid}'),
            create: (_) => SessionController(
              uid: user.uid,
              userName: user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!.trim()
                  : (user.email ?? ''),
              userEmail: user.email ?? '',
              storeRepository: storeRepository,
              employeeRepository: employeeRepository,
              userProfileRepository: userProfileRepository,
              invitationRepository: invitationRepository,
            ),
            child: SessionGate(
              buildApp: ({Key? key, required Widget home}) =>
                  _buildApp(context, key: key, home: home),
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

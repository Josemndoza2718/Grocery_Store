import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/core/data/repositories/local/prefs.dart';
import 'package:grocery_store/core/resource/my_localizations.dart';
import 'package:grocery_store/dependencies/di.dart';
import 'package:grocery_store/ui/view/auth/login_page.dart';
import 'package:grocery_store/ui/view/origin/main_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ¡Esta es la más importante!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Prefs.init();
  //await FlutterLocalization.instance.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en'),],
      path: 'lib/core/resource/langs',
      useFallbackTranslations: true,
      fallbackLocale: Locale('es'),
      startLocale: Locale('es'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ...di,
        ],
        child: MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'Material App',
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            // Escuchamos el estado de autenticación de Firebase
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // Muestra un indicador de carga mientras verifica el estado
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Si hay un usuario autenticado, muestra el HomeScreen
              if (snapshot.hasData) {
                return const MainPage(
                  selectedIndex: 0,
                );
              }

              // Si no hay usuario, muestra el LoginScreen
              return const LoginScreen();
            },
          ),
        ));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/my_localizations.dart';
import 'package:grocery_store/dependencies/di.dart';
import 'package:grocery_store/firebase_options.dart';
import 'package:grocery_store/ui/view/auth/login_page.dart';
import 'package:grocery_store/ui/view/origin/main_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ¡Esta es la más importante!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await FlutterLocalization.instance.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ...di,
          /* ChangeNotifierProvider(
            create: (context) => LoginProvider(),
            child: const MyApp(),
          ),
          ChangeNotifierProvider(
              create: (context) => HomeViewModel(
                    //Categories
                    createCategoriesUseCases: CreateCategoriesUseCases(
                        repository: CategoryRepositoryImpl()),
                    deleteCategoriesUseCases: DeleteCategoriesUseCases(
                        repository: CategoryRepositoryImpl()),
                    updateCategoriesUseCases: UpdateCategoriesUseCases(
                        repository: CategoryRepositoryImpl()),
                    getCategoriesUseCases: GetCategoriesUseCases(
                      repository: CategoryRepositoryImpl(),
                    ),
                    //Products
                    createProductsUseCases: CreateProductsUseCases(
                        repository: ProductRepositoryImpl()),
                    sendProductsToFirebaseUseCases: SendProductFirebaseUseCases(
                        repository: ProductRepositoryImpl()),
                    getProductsUseCases: GetProductsUseCases(
                        repository: ProductRepositoryImpl()),
                    deleteProductsUseCases: DeleteProductsUseCases(
                        repository: ProductRepositoryImpl()),
                    updateProductsUseCases: UpdateProductsUseCases(
                        repository: ProductRepositoryImpl()),
                    //Clients
                    createClientUseCases: CreateClientUseCases(
                        repository: ClientRepositoryImpl()),
                    getClientsUseCases:
                        GetClientsUseCases(repository: ClientRepositoryImpl()),
                    deleteClientsUseCases: DeleteClientsUseCases(
                        repository: ClientRepositoryImpl()),
                  )),
          ChangeNotifierProvider(
              create: (context) => CartViewModel(
                    getProductsUseCases: GetProductsUseCases(
                        repository: ProductRepositoryImpl()),
                    getCarProductsUseCases:
                        GetAllCartsUseCases(repository: CartRepositoryImpl()),
                    addCarProductsUseCases: CreateCarProductsUseCases(
                        repository: CartRepositoryImpl()),
                    deleteCarProductsUseCases: DeleteCarProductsUseCases(
                        repository: CartRepositoryImpl()),
                    updateCarProductsUseCases: UpdateCarProductsUseCases(
                        repository: CartRepositoryImpl()),
                    createClientUseCases: CreateClientUseCases(
                        repository: ClientRepositoryImpl()),
                    getClientsUseCases:
                        GetClientsUseCases(repository: ClientRepositoryImpl()),
                    deleteClientsUseCases: DeleteClientsUseCases(
                        repository: ClientRepositoryImpl()),
                  )),
          ChangeNotifierProvider(
              create: (context) => AddCategoryViewModel(
                  createCategoriesUseCases: CreateCategoriesUseCases(
                      repository: CategoryRepositoryImpl()))),
          ChangeNotifierProvider(
              create: (context) => AddProductViewModel(
                  createProductsUseCases: CreateProductsUseCases(
                      repository: ProductRepositoryImpl()))),
          ChangeNotifierProvider(create: (context) => MainPageViewModel()),
          ChangeNotifierProvider(
              create: (context) => CheckViewModel(
                    createCashProductsUseCases: CreateCashProductsUseCases(
                        repository: CashProductRepositoryImpl()),
                    getCarProductsUseCases:
                        GetAllCartsUseCases(repository: CartRepositoryImpl()),
                    deleteCashProductsUseCases: DeleteCashProductsUseCases(
                        repository: CashProductRepositoryImpl()),
                  )), */
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            MyLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // Inglés
            Locale('es', ''), // Español
          ],
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

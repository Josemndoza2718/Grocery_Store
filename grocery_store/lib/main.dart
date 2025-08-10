import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:grocery_store/core/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/cash_product_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/category_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/product_repository_impl.dart';
import 'package:grocery_store/core/domain/use_cases/car/create_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/car/update_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cash/create_cash_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cash/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/create_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/delete_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/update_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/get_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/core/resource/my_localizations.dart';
import 'package:grocery_store/ui/view_model/add_category_view_model.dart';
import 'package:grocery_store/ui/view_model/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/check_view_model.dart';
import 'package:grocery_store/ui/view_model/main_page_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/ui/origin/main_page.dart';
import 'package:grocery_store/ui/view_model/cart_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ¡Esta es la más importante!

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
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
                  )),
        ],
        child: const MaterialApp(
            localizationsDelegates: [
              MyLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''), // Inglés
              Locale('es', ''), // Español
            ],
            title: 'Material App',
            debugShowCheckedModeBanner: false,
            home: MainPage(
              selectedIndex: 0,
            )));
  }
}

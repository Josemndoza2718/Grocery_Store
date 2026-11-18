import 'package:grocery_store/data/repositories/remote/employee_repository_impl.dart';
import 'package:grocery_store/data/repositories/remote/store_repository_impl.dart';
import 'package:grocery_store/data/repositories/remote/user_profile_repository_impl.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_cart_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_product_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/sales_history_repository_impl.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_create_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_delete_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_get_carts_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_update_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/migrate_local_clients_use_case.dart';
import 'package:grocery_store/data/repositories/local/new/new_client_repository_impl.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/sales/get_sales_use_case.dart';
import 'package:grocery_store/ui/view_model/providers/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/cart_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/home_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/main_page_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/sales_history_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:grocery_store/data/repositories/local/new/payment_repository_impl.dart';
import 'package:grocery_store/domain/use_cases/sales/process_payment_use_case.dart';

// Instancias compartidas únicas de repositorios para inyección de dependencias
final storeRepository = StoreRepositoryImpl();
final employeeRepository = EmployeeRepositoryImpl();
final userProfileRepository = UserProfileRepositoryImpl();
final newProductRepository = NewProductRepositoryImpl();
// Legacy local (Sembast) clients store: only used to migrate them to Firestore.
final legacyClientRepository = ClientRepositoryImpl();
final clientRepository = NewClientRepositoryImpl();
final newCartRepository = NewCartRepositoryImpl();
final salesHistoryRepository = SalesHistoryRepositoryImpl();
final paymentRepository = PaymentRepositoryImpl();

/// Providers that live for the whole app lifetime (independent of the session).
final List<SingleChildWidget> globalProviders = [
  ChangeNotifierProvider(
    create: (context) => LoginProvider(),
  ),
];

/// Providers scoped to an active [AppSession] (user + store).
///
/// They must be mounted under a widget keyed by [AppSession.key], so that
/// logging out or switching store disposes them (cancelling their Firestore
/// subscriptions) and creates fresh instances.
List<SingleChildWidget> sessionProviders(AppSession session) {
  // Phase 1: data is still isolated per user (products, carts, clients and
  // sales keep their `userId`). Phase 2 moves it under `stores/{storeId}`.
  final userId = session.uid;
  return [
    ChangeNotifierProvider(
        create: (context) => HomeViewModel(
              userId: userId,
              //Products
              createProductsUseCases:
                  CreateProductsUseCases(newProductRepository),
              getProductsUseCases: NewGetProductsUseCases(newProductRepository),
              deleteProductsUseCases:
                  NewDeleteProductsUseCases(newProductRepository),
              updateProductsUseCases:
                  UpdateProductsUseCases(newProductRepository),
              //Clients
              createClientUseCases:
                  CreateClientUseCases(repository: clientRepository),
              getClientsUseCases:
                  GetClientsUseCases(repository: clientRepository),
              deleteClientsUseCases:
                  DeleteClientsUseCases(repository: clientRepository),
              migrateLocalClientsUseCase: MigrateLocalClientsUseCase(
                legacyRepository: legacyClientRepository,
                repository: clientRepository,
              ),
            )),
    ChangeNotifierProvider(
        create: (context) => CartViewModel(
              userId: userId,
              getProductsUseCases: NewGetProductsUseCases(newProductRepository),
              getCartsUseCases:
                  NewGetCartsUseCases(repository: newCartRepository),
              createCartUseCases:
                  NewCreateCartUseCases(repository: newCartRepository),
              deleteCartUseCases:
                  NewDeleteCartUseCases(repository: newCartRepository),
              updateCartUseCases:
                  NewUpdateCartUseCases(repository: newCartRepository),
              updateProductsUseCases:
                  UpdateProductsUseCases(newProductRepository),
              //Sales
              processPaymentUseCase: ProcessPaymentUseCase(paymentRepository),
            )),
    ChangeNotifierProvider(
        create: (context) => AddProductViewModel(
              userId: userId,
              createProductsUseCases:
                  CreateProductsUseCases(newProductRepository),
              updateProductsUseCases:
                  UpdateProductsUseCases(newProductRepository),
            )),
    ChangeNotifierProvider(create: (context) => MainPageViewModel()),
    ChangeNotifierProvider(
        create: (context) => SalesHistoryViewModel(
              userId: userId,
              getSalesUseCase: GetSalesUseCase(salesHistoryRepository),
            )),
  ];
}

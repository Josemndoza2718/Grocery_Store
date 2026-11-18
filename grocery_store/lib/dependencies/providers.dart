import 'package:grocery_store/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_cart_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_client_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_product_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/payment_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/sales_history_repository_impl.dart';
import 'package:grocery_store/data/repositories/remote/employee_repository_impl.dart';
import 'package:grocery_store/data/repositories/remote/legacy_migration_repository_impl.dart';
import 'package:grocery_store/data/repositories/remote/store_repository_impl.dart';
import 'package:grocery_store/data/repositories/remote/user_profile_repository_impl.dart';
import 'package:grocery_store/domain/entities/app_session.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_create_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_delete_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_get_carts_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_update_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/sales/get_sales_use_case.dart';
import 'package:grocery_store/domain/use_cases/sales/process_payment_use_case.dart';
import 'package:grocery_store/ui/view_model/providers/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/cart_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/home_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/login_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/main_page_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/sales_history_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// ── Repositories independent of the active store ──
final storeRepository = StoreRepositoryImpl();
final employeeRepository = EmployeeRepositoryImpl();
final userProfileRepository = UserProfileRepositoryImpl();

/// Copies the per-user data of the old model into a store (one-time).
final legacyMigrationRepository = LegacyMigrationRepositoryImpl(
  // Legacy local (Sembast) clients store, only read by the migration.
  localClients: ClientRepositoryImpl(),
);

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
  final userId = session.uid;
  final storeId = session.storeId;

  // Repositories bound to `stores/{storeId}/...`.
  final productRepository = NewProductRepositoryImpl(storeId: storeId);
  final clientRepository = NewClientRepositoryImpl(storeId: storeId);
  final cartRepository = NewCartRepositoryImpl(storeId: storeId);
  final salesRepository = SalesHistoryRepositoryImpl(storeId: storeId);
  final paymentRepository = PaymentRepositoryImpl(storeId: storeId);

  return [
    ChangeNotifierProvider(
        create: (context) => HomeViewModel(
              userId: userId,
              //Products
              createProductsUseCases: CreateProductsUseCases(productRepository),
              getProductsUseCases: NewGetProductsUseCases(productRepository),
              deleteProductsUseCases:
                  NewDeleteProductsUseCases(productRepository),
              updateProductsUseCases: UpdateProductsUseCases(productRepository),
              //Clients
              createClientUseCases:
                  CreateClientUseCases(repository: clientRepository),
              getClientsUseCases:
                  GetClientsUseCases(repository: clientRepository),
              deleteClientsUseCases:
                  DeleteClientsUseCases(repository: clientRepository),
            )),
    ChangeNotifierProvider(
        create: (context) => CartViewModel(
              userId: userId,
              userName: session.userName,
              getProductsUseCases: NewGetProductsUseCases(productRepository),
              getCartsUseCases: NewGetCartsUseCases(repository: cartRepository),
              createCartUseCases:
                  NewCreateCartUseCases(repository: cartRepository),
              deleteCartUseCases:
                  NewDeleteCartUseCases(repository: cartRepository),
              updateCartUseCases:
                  NewUpdateCartUseCases(repository: cartRepository),
              updateProductsUseCases: UpdateProductsUseCases(productRepository),
              //Sales
              processPaymentUseCase: ProcessPaymentUseCase(paymentRepository),
            )),
    ChangeNotifierProvider(
        create: (context) => AddProductViewModel(
              userId: userId,
              createProductsUseCases: CreateProductsUseCases(productRepository),
              updateProductsUseCases: UpdateProductsUseCases(productRepository),
            )),
    ChangeNotifierProvider(create: (context) => MainPageViewModel()),
    ChangeNotifierProvider(
        create: (context) => SalesHistoryViewModel(
              userId: userId,
              canSeeAllSales: session.canSeeAllSales,
              getSalesUseCase: GetSalesUseCase(salesRepository),
            )),
  ];
}

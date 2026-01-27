import 'package:grocery_store/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/cash_product_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_cart_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/new/new_product_repository_impl.dart';
import 'package:grocery_store/data/repositories/local/product_repository_impl.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_create_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_delete_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_get_carts_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cart/new/new_update_cart_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cash/create_cash_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/cash/delete_car_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/create_product_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/delete_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/update_products_use_cases.dart';
import 'package:grocery_store/domain/use_cases/product/send_product_firebase_use_cases.dart';
import 'package:grocery_store/ui/view_model/new/add_new_product_view_model.dart';
import 'package:grocery_store/ui/view_model/old/cart_view_model.dart';
import 'package:grocery_store/ui/view_model/old/check_view_model.dart';
import 'package:grocery_store/ui/view_model/old/home_view_model.dart';
import 'package:grocery_store/ui/view_model/old/login_view_model.dart';
import 'package:grocery_store/ui/view_model/old/main_page_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => LoginProvider(),
  ),
  ChangeNotifierProvider(
      create: (context) => HomeViewModel(
            //Products
            createProductsUseCases:
                CreateProductsUseCases(NewProductRepositoryImpl()),
            sendProductsToFirebaseUseCases: SendProductFirebaseUseCases(
                repository: ProductRepositoryImpl()),
            getProductsUseCases:
                NewGetProductsUseCases(NewProductRepositoryImpl()),
            deleteProductsUseCases:
                NewDeleteProductsUseCases(NewProductRepositoryImpl()),
            updateProductsUseCases:
                UpdateProductsUseCases(NewProductRepositoryImpl()),
            //Clients
            createClientUseCases:
                CreateClientUseCases(repository: ClientRepositoryImpl()),
            getClientsUseCases:
                GetClientsUseCases(repository: ClientRepositoryImpl()),
            deleteClientsUseCases:
                DeleteClientsUseCases(repository: ClientRepositoryImpl()),
          )),
  ChangeNotifierProvider(
      create: (context) => CartViewModel(
            getProductsUseCases:
                NewGetProductsUseCases(NewProductRepositoryImpl()),
            getCartsUseCases:
                NewGetCartsUseCases(repository: NewCartRepositoryImpl()),
            createCartUseCases:
                NewCreateCartUseCases(repository: NewCartRepositoryImpl()),
            deleteCartUseCases:
                NewDeleteCartUseCases(repository: NewCartRepositoryImpl()),
            updateCartUseCases:
                NewUpdateCartUseCases(repository: NewCartRepositoryImpl()),
            updateProductsUseCases:
                UpdateProductsUseCases(NewProductRepositoryImpl()),
            createClientUseCases:
                CreateClientUseCases(repository: ClientRepositoryImpl()),
            getClientsUseCases:
                GetClientsUseCases(repository: ClientRepositoryImpl()),
            deleteClientsUseCases:
                DeleteClientsUseCases(repository: ClientRepositoryImpl()),
          )),
  ChangeNotifierProvider(
      create: (context) => AddProductViewModel(
            createProductsUseCases:
                CreateProductsUseCases(NewProductRepositoryImpl()),
            updateProductsUseCases:
                UpdateProductsUseCases(NewProductRepositoryImpl()),
          )),
  ChangeNotifierProvider(create: (context) => MainPageViewModel()),
  ChangeNotifierProvider(
      create: (context) => CheckViewModel(
            createCashProductsUseCases: CreateCashProductsUseCases(
                repository: CashProductRepositoryImpl()),
            getCartsUseCases:
                NewGetCartsUseCases(repository: NewCartRepositoryImpl()),
            deleteCashProductsUseCases: DeleteCashProductsUseCases(
                repository: CashProductRepositoryImpl()),
          )),
];

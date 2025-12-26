import 'package:grocery_store/core/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/car_product_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/cash_product_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/category_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/new/new_product_repository_impl.dart';
import 'package:grocery_store/core/data/repositories/local/product_repository_impl.dart';
import 'package:grocery_store/core/domain/use_cases/car/create_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/car/get_car_products_use_cases%20copy.dart';
import 'package:grocery_store/core/domain/use_cases/car/update_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cash/create_cash_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/cash/delete_car_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/category/create_categories_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/create_client_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/delete_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/client/get_clients_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/get_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_create_product_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_delete_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_get_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/new/new_update_products_use_cases.dart';
import 'package:grocery_store/core/domain/use_cases/product/send_product_firebase_use_cases.dart';
import 'package:grocery_store/ui/view_model/new/add_new_product_view_model.dart';
import 'package:grocery_store/ui/view_model/old/add_category_view_model.dart';
import 'package:grocery_store/ui/view_model/old/add_product_view_model.dart';
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
                NewCreateProductsUseCases(NewProductRepositoryImpl()),
            sendProductsToFirebaseUseCases: SendProductFirebaseUseCases(
                repository: ProductRepositoryImpl()),
            getProductsUseCases:
                NewGetProductsUseCases(NewProductRepositoryImpl()),
            deleteProductsUseCases:
                NewDeleteProductsUseCases(NewProductRepositoryImpl()),
            updateProductsUseCases:
                NewUpdateProductsUseCases(NewProductRepositoryImpl()),
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
                GetProductsUseCases(repository: ProductRepositoryImpl()),
            getCarProductsUseCases:
                GetAllCartsUseCases(repository: CartRepositoryImpl()),
            addCarProductsUseCases:
                CreateCarProductsUseCases(repository: CartRepositoryImpl()),
            deleteCarProductsUseCases:
                DeleteCarProductsUseCases(repository: CartRepositoryImpl()),
            updateCarProductsUseCases:
                UpdateCarProductsUseCases(repository: CartRepositoryImpl()),
            createClientUseCases:
                CreateClientUseCases(repository: ClientRepositoryImpl()),
            getClientsUseCases:
                GetClientsUseCases(repository: ClientRepositoryImpl()),
            deleteClientsUseCases:
                DeleteClientsUseCases(repository: ClientRepositoryImpl()),
          )),
  ChangeNotifierProvider(
      create: (context) => AddCategoryViewModel(
          createCategoriesUseCases:
              CreateCategoriesUseCases(repository: CategoryRepositoryImpl()))),
  ChangeNotifierProvider(
      create: (context) => AddProductViewModel(
          createProductsUseCases:
              NewCreateProductsUseCases(NewProductRepositoryImpl()),
          getProductsUseCases:
              NewGetProductsUseCases(NewProductRepositoryImpl()))),
  ChangeNotifierProvider(
      create: (context) => AddNewProductViewModel(
            newCreateProductsUseCases:
                NewCreateProductsUseCases(NewProductRepositoryImpl()),
          )),
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
];

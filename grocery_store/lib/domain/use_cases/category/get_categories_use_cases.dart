import 'package:grocery_store/data/repositories/local/category_repository_impl.dart';
import 'package:grocery_store/domain/entities/category.dart';

class GetCategoriesUseCases {
  const GetCategoriesUseCases({required this.repository});

  final CategoryRepositoryImpl repository;

  Future<List<Category>> call() async {
    return await repository.getAllCategories();
  }

  

}

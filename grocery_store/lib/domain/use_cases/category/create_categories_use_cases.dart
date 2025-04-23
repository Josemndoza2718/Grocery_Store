import 'package:grocery_store/data/repositories/local/category_repository_impl.dart';
import 'package:grocery_store/domain/entities/category.dart';

class CreateCategoriesUseCases {
  const CreateCategoriesUseCases({required this.repository});

  final CategoryRepositoryImpl repository;

  Future<void> call(Category category) async {
    await repository.addCategory(category);
  }

  
}
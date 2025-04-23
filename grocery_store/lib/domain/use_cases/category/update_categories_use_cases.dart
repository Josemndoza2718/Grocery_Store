import 'package:grocery_store/data/repositories/local/category_repository_impl.dart';
import 'package:grocery_store/domain/entities/category.dart';

class UpdateCategoriesUseCases {
  const UpdateCategoriesUseCases({required this.repository});

  final CategoryRepositoryImpl repository;

 
  Future<void> updateCategory(Category category) async {
    await repository.updateCategory(category);
  }
}
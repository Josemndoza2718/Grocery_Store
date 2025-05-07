import 'package:grocery_store/core/data/repositories/local/category_repository_impl.dart';

class DeleteCategoriesUseCases {
  const DeleteCategoriesUseCases({required this.repository});

  final CategoryRepositoryImpl repository;

  Future<void> deleteCategory(int id) async {
    await repository.deleteCategory(id);
  }
}

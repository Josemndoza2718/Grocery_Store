

import 'package:grocery_store/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<List<Category>> getAllCategories();
}
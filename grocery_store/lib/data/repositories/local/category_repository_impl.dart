// ignore_for_file: implementation_imports, depend_on_referenced_packages

//import 'package:flutter/src/foundation/annotations.dart';


import 'package:grocery_store/data/models/category_model.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/domain/repositories/local/category_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  String dbPath = 'my_database.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  
  var store = intMapStoreFactory.store('categories');

  

  Future<Database> initDatabase() async {

  final dir = await getApplicationDocumentsDirectory();
  
  await dir.create(recursive: true);
  
  String path = join(dir.path, dbPath);
  
  return await dbFactory.openDatabase(path);

  }

  @override
  Future<void> addCategory(Category category) async {

    final db = await initDatabase();

      CategoryModel categoryModel = CategoryModel(
        id: category.id,
        name: category.name,
        image: category.image,
      );
  
      await store.record(category.id).add(db, (categoryModel.toJson()));
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await initDatabase();
    await store.record(id).delete(db);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final db = await initDatabase();
    final result = await store.find(db).then((records) {
      return records.map((record) {
        return CategoryModel.fromJson(record.value);
      }).toList();
    });
    return result.map<Category>((e) => Category(id: e.id, name: e.name, image: e.image)).toList();
   
  }
  
  @override
  Future<void> updateCategory(Category category) async {
    final db = await initDatabase();
    CategoryModel categoryModel = CategoryModel(
      id: category.id,
      name: category.name,
      image: category.image,
    );

    store.record(category.id).put(db, categoryModel.toJson());
  }


  
  }


 


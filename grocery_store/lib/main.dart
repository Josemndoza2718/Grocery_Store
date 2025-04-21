import 'package:flutter/material.dart';
import 'package:grocery_store/data/repositories/local/category_repository_impl.dart';
import 'package:grocery_store/domain/use_cases/create_categories_use_cases.dart';
import 'package:grocery_store/domain/use_cases/get_categories_use_cases.dart';
import 'package:grocery_store/ui/home_page.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => HomeViewModel(
                  createCategoriesUseCases: CreateCategoriesUseCases(
                      repository: CategoryRepositoryImpl()),
                  getCategoriesUseCases: GetCategoriesUseCases(
                    repository: CategoryRepositoryImpl(),
                  ))),
        ],
        child: const MaterialApp(
            title: 'Material App',
            debugShowCheckedModeBanner: false,
            home: HomePage()));
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/ui/add_product_page.dart';

class ProductsListWidget extends StatelessWidget {
  const ProductsListWidget({
    super.key,
    required this.listProducts,
    required this.onClose,
  });

  final List<Product>? listProducts;
  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color.fromARGB(59, 184, 184, 184),
          borderRadius: BorderRadius.circular(10)),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          //mainAxisSpacing: 2,
          childAspectRatio: 0.8,
        ),
        itemCount: listProducts!.length + 1,
        itemBuilder: (context, index) {
          if (index == listProducts?.length) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(),
                  ),
                ).then((_) {
                  onClose();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(115, 184, 184, 184),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle,
                      size: 40,
                    ),
                    Text(
                      "Add Product",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }
          return GestureDetector(
            /* onTap: () {
              setState(() {
                pressedIndex = index; // Marca el botón como presionado
              });
            },
            onTapUp: (_) {
              setState(() {
                pressedIndex = null; // Quita el efecto al soltar
                selectedIndexGrid = index; // Selecciona el botón
              });
            }, */
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(115, 184, 184, 184), // Color para el no seleccionado
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.file(
                      File(listProducts![index].image),
                      height: 80,
                      width: 80,
                      //fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(
                    listProducts![index].name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    listProducts![index].description,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    listProducts![index].stockQuantity.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listProducts![index].price.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
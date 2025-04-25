import 'package:flutter/material.dart';
import 'package:grocery_store/ui/view_model/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/utils/phone_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatelessWidget {
  AddProductPage({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Consumer<AddProductViewModel>(builder: (context, viewModel, _) {
        return Column(
          spacing: 16,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final pickedImageGalery = await PhoneImage().pickImageFromGallery(ImageSource.gallery);
            
                        if (pickedImageGalery != null) {
                          viewModel.setGalleryImage(pickedImageGalery);
                        }
                  },
                  label: const Text("gallery"),
                  icon: const Icon(Icons.image),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                     final pickedImageCamera = await PhoneImage()
                            .pickImageFromGallery(ImageSource.camera);
            
                        if (pickedImageCamera != null) {
                          viewModel.setGalleryImage(pickedImageCamera);
                        }
                  },
                  label: const Text("photo"),
                  icon: const Icon(Icons.camera_alt),
                )
              ],
            ),
            viewModel.galleryImage == null
                ? const Text("No image selected")
                : Image.file(
                    viewModel.galleryImage!,
                    height: 100,
                    width: 100,
                  ),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
              ),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter price',
              ),
            ),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter quantity',
                
              ),
            ),
            Consumer<HomeViewModel>(builder: (context, homeViewModel, _) {
              return DropdownButtonFormField(
                value: homeViewModel.selectedCategory.isEmpty
                    ? null
                    : homeViewModel.selectedCategory,
                decoration: const InputDecoration(
                  hintText: 'Select category',
                ),
                items: homeViewModel.listCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    homeViewModel.setSelectedCategory(newValue);
                  }
                },
              );
            }),
            Consumer<HomeViewModel>(builder: (context, homeViewModel, _) {
                return ElevatedButton(
                    onPressed: () async {
                      await viewModel.createProduct(
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        stockQuantity: double.parse(quantityController.text),
                        category: homeViewModel.selectedCategory,
                      );
                      print("category: ${homeViewModel.selectedCategory}");
                    },
                    child: const Text("create"),

                    );
              }
            )
          ],
        );
      }),
    ));
  }
}

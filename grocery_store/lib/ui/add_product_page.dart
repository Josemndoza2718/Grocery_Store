import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/ui/view_model/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:grocery_store/core/utils/phone_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  AddProductPage({super.key, this.product});

  final Product? product;


  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  late final TextEditingController nameEditController;
  late final TextEditingController descriptionEditController;
  late final TextEditingController priceEditController;
  late final TextEditingController quantityEditController;
  late String editCategory;

  @override
  void initState() {
    super.initState();
    // var viewModel = context.read<HomeViewModel>();
    // viewModel.setSelectedCategory("");

    if (widget.product != null) {
      var viewModel = context.read<AddProductViewModel>();
      viewModel.initImage(File(widget.product!.image));
    }

    nameEditController = TextEditingController(text: widget.product?.name);
    descriptionEditController = TextEditingController(text: widget.product?.description);
    priceEditController = TextEditingController(text: widget.product?.price.toString());
    quantityEditController = TextEditingController(text: widget.product?.stockQuantity.toString());
    editCategory = widget.product?.category ?? "";
    //viewModel.setSelectedCategory(widget.product?.category ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      final pickedImageGalery = await PhoneImage()
                          .pickImageFromGallery(ImageSource.gallery);

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
                controller: widget.product == null
                    ? nameController
                    : nameEditController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
              ),
              TextFormField(
                controller: widget.product == null
                    ? descriptionController
                    : descriptionEditController,
                decoration: const InputDecoration(
                  hintText: 'Enter description',
                ),
              ),
              TextFormField(
                controller: widget.product == null
                    ? priceController
                    : priceEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter price',
                ),
              ),
              TextFormField(
                controller: widget.product == null
                    ? quantityController
                    : quantityEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter quantity',
                ),
              ),
              Consumer<HomeViewModel>(builder: (context, homeViewModel, _) {
                return DropdownButtonFormField(
                  value: widget.product == null
                      ? null
                      : widget.product?.categoryId.toString(),
                      //homeViewModel.listCategories[].id.toString(),
                  //homeViewModel.selectedCategory,
                  decoration: const InputDecoration(
                    hintText: 'Select category',
                  ),
                  items: homeViewModel.listCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id.toString(),
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
                    if (widget.product != null) {
                      await homeViewModel.updateProduct(
                        Product(
                              id: widget.product!.id,
                              name: nameEditController.text,
                              description: descriptionEditController.text,
                              price: double.parse(priceEditController.text),
                              image: viewModel.galleryImage?.path ?? widget.product!.image,
                              categoryId: widget.product!.categoryId,
                              category: editCategory,
                              stockQuantity: double.parse(quantityEditController.text)))
                          .then((_) {
                        {
                          Navigator.pop(context);
                        }
                      });
                    } else {
                      if (nameController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          quantityController.text.isEmpty) {
                        return;
                      } else {
                        await viewModel.createProduct(
                          name: nameController.text,
                          description: descriptionController.text,
                          price: double.parse(priceController.text),
                          stockQuantity: double.parse(quantityController.text),
                          category: homeViewModel.selectedCategory,
                        ).then((_) {
                          {
                            Navigator.pop(context);
                            homeViewModel.setSelectedCategory("");
                          }
                        });
                      }
                    }

                    print("category: ${homeViewModel.selectedCategory}");
                  },
                  child: const Text("create"),
                );
              })
            ],
          );
        }),
      )),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/view/ui/view_model/add_product_view_model.dart';
import 'package:grocery_store/view/ui/view_model/home_view_model.dart';
import 'package:grocery_store/core/utils/phone_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, this.product});

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
    descriptionEditController =
        TextEditingController(text: widget.product?.description);
    priceEditController =
        TextEditingController(text: widget.product?.price.toString());
    quantityEditController =
        TextEditingController(text: widget.product?.stockQuantity.toString());
  }

  Future<void> _handleProductSubmission(
    AddProductViewModel viewModel,
    HomeViewModel homeViewModel,
  ) async {
    if (widget.product != null) {
      await homeViewModel
          .updateProduct(
        Product(
          id: widget.product!.id,
          name: nameEditController.text,
          description: descriptionEditController.text,
          price: double.parse(priceEditController.text),
          image: viewModel.galleryImage?.path ?? widget.product!.image,
          stockQuantity: double.parse(quantityEditController.text),
        ),
      )
          .then((_) {
        {
          Navigator.pop(context);
        }
      });
    } else {
      if (nameController.text.isEmpty ||
          priceController.text.isEmpty ||
          quantityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all fields"),
          ),
        );
      } else {
        await viewModel
            .createProduct(
          name: nameController.text,
          description: descriptionController.text,
          price: double.parse(priceController.text),
          stockQuantity: double.parse(quantityController.text),
          category: homeViewModel.selectedCategory,
        )
            .then((_) {
          {
            Navigator.pop(context);
            homeViewModel.setSelectedCategory("");
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkgreen,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Esto quita el foco de cualquier TextField
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(child:
            Consumer<AddProductViewModel>(builder: (context, viewModel, _) {
          return Expanded(
            child: Column(
              spacing: 16,
              children: [
                const SizedBox(height: 0),
                Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  /* decoration: BoxDecoration(
                    color: AppColors.lightgrey,
                    borderRadius: BorderRadius.circular(10),
                  ), */
                  child: Row(
                    spacing: 8,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final pickedImageGalery = await PhoneImage()
                                  .pickImageFromGallery(ImageSource.gallery);
                              if (pickedImageGalery != null) {
                                viewModel.setGalleryImage(pickedImageGalery);
                              }
                            },
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: AppColors.darkgreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: AppColors.lightwhite,
                                    size: 40,
                                  ),
                                  Text(
                                    "gallery",
                                    style: TextStyle(
                                        color: AppColors.lightwhite,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final pickedImageCamera = await PhoneImage()
                                  .pickImageFromGallery(ImageSource.camera);

                              if (pickedImageCamera != null) {
                                viewModel.setGalleryImage(pickedImageCamera);
                              }
                            },
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                  color: AppColors.darkgreen,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: AppColors.lightwhite,
                                    size: 40,
                                  ),
                                  Text(
                                    "photo",
                                    style: TextStyle(
                                        color: AppColors.lightwhite,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightwhite,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: viewModel.galleryImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 16,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: AppColors.darkgreen,
                                    ),
                                    Text(
                                      "No image selected",
                                      style: TextStyle(color: AppColors.black),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: double.infinity,
                                  child: Image.file(
                                    viewModel.galleryImage!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: AppColors.darkgreen,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )),
                    child: Consumer<HomeViewModel>(
                        builder: (context, homeViewModel, _) {
                      return SingleChildScrollView(
                        child: Expanded(
                          child: Column(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 0),
                              TextFormField(
                                controller: widget.product == null
                                    ? nameController
                                    : nameEditController,
                                decoration: InputDecoration(
                                  hintText: "Enter name",
                                  filled: true,
                                  fillColor: AppColors.lightwhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.green,
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: widget.product == null
                                    ? descriptionController
                                    : descriptionEditController,
                                decoration: InputDecoration(
                                  hintText: "Enter description",
                                  filled: true,
                                  fillColor: AppColors.lightwhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.green,
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: widget.product == null
                                    ? priceController
                                    : priceEditController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Enter price",
                                  filled: true,
                                  fillColor: AppColors.lightwhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.green,
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 8,
                                children: [
                                  Flexible(
                                    child: TextFormField(
                                      controller: widget.product == null
                                          ? quantityController
                                          : quantityEditController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: "Enter quantity",
                                        filled: true,
                                        fillColor: AppColors.lightwhite,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: AppColors.green,
                                            width: 4,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: DropdownButtonFormField<int>(
                                      value: viewModel.selectedQuantity,
                                      decoration: const InputDecoration(
                                        hintText: 'Measurements',
                                        filled: true,
                                        fillColor: AppColors.lightwhite,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text('other'),
                                        ),
                                        DropdownMenuItem<int>(
                                          value: 1,
                                          child: Text('liters'),
                                        ),
                                        DropdownMenuItem<int>(
                                          value: 2,
                                          child: Text('count'),
                                        ),
                                        DropdownMenuItem<int>(
                                          value: 3,
                                          child: Text('kilograms'),
                                        ),
                                      ],
                                      onChanged: (int? newValue) {
                                        if (newValue != null) {
                                          viewModel.selectedQuantity = newValue;
                                          // Handle the selected value
                                          print("Selected quantity: $newValue");
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              /* DropdownButtonFormField(
                                value: widget.product?.categoryId.toString(),
                                decoration: const InputDecoration(
                                  hintText: 'Select category',
                                  filled: true,
                                  fillColor: AppColors.lightwhite,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.green,
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                items: homeViewModel.listCategories
                                    .map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id.toString(),
                                    child: Text(category.name),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    var addProductViewModel =
                                        context.read<AddProductViewModel>();

                                    homeViewModel.setSelectedCategory(newValue);
                                    addProductViewModel.setID = int.parse(
                                        homeViewModel.selectedCategory);
                                  }
                                },
                              ), */
                              const SizedBox(height: 0),
                              GestureDetector(
                                onTap: () async {
                                  _handleProductSubmission(
                                      viewModel, homeViewModel);
                                  viewModel.selectedQuantity = 0;
                                  //Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    "Save",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.darkgreen,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        })),
      ),
    );
  }
}

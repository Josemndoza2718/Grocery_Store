import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
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
    descriptionEditController =
        TextEditingController(text: widget.product?.description);
    priceEditController =
        TextEditingController(text: widget.product?.price.toString());
    quantityEditController =
        TextEditingController(text: widget.product?.stockQuantity.toString());
    editCategory = widget.product?.category ?? "";
    //viewModel.setSelectedCategory(widget.product?.category ?? "");
  }

  Future<void> _handleProductSubmission(
    AddProductViewModel viewModel,
    HomeViewModel homeViewModel,
  ) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Esto quita el foco de cualquier TextField
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child:
              Consumer<AddProductViewModel>(builder: (context, viewModel, _) {
            return Column(
              spacing: 16,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(10),),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: AppColors.black,
                              size: 40,
                            ),
                            Text(
                              "gallery",
                              style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      "OR",
                      style: TextStyle(color: Colors.black, fontSize: 18),
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
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: AppColors.black,
                              size: 40,
                            ),
                            Text(
                              "photo",
                              style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 8),
                viewModel.galleryImage == null
                    ? const Column(
                      spacing: 16,
                      children: [
                        Icon(Icons.image_not_supported, size: 60, color: AppColors.darkgreen,),
                        Text(
                          "No image selected",
                          style: TextStyle(color: AppColors.black),
                        ),
                      ],
                    )
                    : Image.file(
                        viewModel.galleryImage!,
                        height: 100,
                        width: 100,
                      ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    spacing: 16,
                    children: [
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
                      TextFormField(
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
                      Consumer<HomeViewModel>(
                          builder: (context, homeViewModel, _) {
                        return DropdownButtonFormField(
                          value: widget.product == null
                              ? null
                              : widget.product?.categoryId.toString(),
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
                    ],
                  ),
                ),
                Consumer<HomeViewModel>(builder: (context, homeViewModel, _) {
                  return ElevatedButton(
                    onPressed: () async {
                      _handleProductSubmission(viewModel, homeViewModel);
                    },
                    child: const Text(
                      "save",
                      style: TextStyle(
                          color: AppColors.darkgreen,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                })
              ],
            );
          }),
        )),
      ),
    );
  }
}

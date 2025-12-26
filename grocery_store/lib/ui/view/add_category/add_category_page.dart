/* import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/category.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/utils/phone_image.dart';
import 'package:grocery_store/ui/view_model/old/add_category_view_model.dart';
import 'package:grocery_store/ui/view_model/old/home_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key, this.category});

  final Category? category;

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController nameController = TextEditingController();
  late final TextEditingController nameEditController;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      var viewModel = context.read<AddCategoryViewModel>();
      viewModel.initImage(File(widget.category!.image));
    }
    nameEditController = TextEditingController(text: widget.category?.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child:
          Consumer<AddCategoryViewModel>(builder: (context, viewModel, _) {
        return Column(
          spacing: 16,
          children: [
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              margin: const EdgeInsets.symmetric(horizontal: 24),
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
                            controller: widget.category == null
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
                          const SizedBox(height: 0),
                          GestureDetector(
                            onTap: () async {
                              /* if (widget.category != null) {
                                await homeViewModel.updateCategory(
                                  Category(
                                    id: widget.category!.id,
                                    name: nameEditController.text,
                                    image: viewModel.galleryImage?.path ??
                                        widget.category!.image,
                                  ),
                                );
                              } else {
                                await viewModel
                                    .createCategory(nameController.text);
                              } */
                              nameController.clear();
                              viewModel.setGalleryImage(null);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
        );
      })),
    );
  }
}
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/category.dart';
import 'package:grocery_store/core/utils/phone_image.dart';
import 'package:grocery_store/ui/view_model/add_category_view_model.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
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
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Consumer<AddCategoryViewModel>(builder: (context, viewModel, _) {
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
                          height: 200,
                          width: 200,
                        ),
                  
              TextFormField(
                controller: widget.category == null
                    ? nameController
                    : nameEditController,
                decoration: const InputDecoration(
                  hintText: 'Enter name',
                ),
                /* onChanged: (value) {
                  name = value;
                }, */
              ),
              Consumer<HomeViewModel>(builder: (context, homeViewModel, _) {
                return ElevatedButton(
                    onPressed: () async {
                      if (widget.category != null) {
                        await homeViewModel.updateCategory(
                          Category(
                            id: widget.category!.id,
                            name: nameEditController.text,
                            image: viewModel.galleryImage?.path ?? widget.category!.image,
                          ),
                        );
                      } else {
                        await viewModel.createCategory(nameController.text);
                      }
                      nameController.clear();
                      viewModel.setGalleryImage(null);
                      Navigator.pop(context);
                    },
                    child: const Text("save"));
              }),
            ],
          );
        }),
      )),
    );
  }
}

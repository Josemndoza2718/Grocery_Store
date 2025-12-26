import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_store/core/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/ui/view/widgets/general_button.dart';
import 'package:grocery_store/ui/view/widgets/general_textformfield.dart';
import 'package:grocery_store/ui/view_model/new/add_new_product_view_model.dart';
import 'package:grocery_store/ui/view_model/old/home_view_model.dart';
import 'package:grocery_store/core/utils/phone_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();

  // Controllers para capturar datos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _idStockController = TextEditingController();

  late final TextEditingController nameEditController;
  late final TextEditingController descriptionEditController;
  late final TextEditingController priceEditController;
  late final TextEditingController _stockEditQuantityController;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var viewModel = context.read<AddProductViewModel>();
        viewModel.setGalleryImage(File(widget.product!.image));
      });
      //viewModel.initImage(File(widget.product!.image));
    }

    nameEditController = TextEditingController(text: widget.product?.name);
    descriptionEditController =
        TextEditingController(text: widget.product?.description);
    priceEditController =
        TextEditingController(text: widget.product?.price.toString());
    _stockEditQuantityController =
        TextEditingController(text: widget.product?.stockQuantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _idStockController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockQuantityController.clear();
    _idStockController.clear();
  }

  Future<void> _createProduct({required Product product}) async {
    final provider = Provider.of<AddProductViewModel>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      try {
        await provider.createProduct(product);

        // 1. Mostrar feedback de éxito
        if (mounted) {
          /* ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Producto creado exitosamente.')),
          ); */

          log('✅ Producto creado exitosamente.');

          // 2. Resetear el formulario y navegar de vuelta
          _resetForm();
          Navigator.pop(context); // Volver a AdminHomeScreen
        }
      } catch (e) {
        // 3. Mostrar diálogo de error
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error al crear'),
              content: Text(provider.errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _updateProduct({required Product product}) async {
    final provider = Provider.of<AddProductViewModel>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      try {
        await provider.updateProduct(product);

        // 1. Mostrar feedback de éxito
        if (mounted) {
          /* ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Producto creado exitosamente.')),
          ); */

          log('✅ Producto actualizado exitosamente.');

          // 2. Resetear el formulario y navegar de vuelta
          _resetForm();
          Navigator.pop(context); // Volver a AdminHomeScreen
        }
      } catch (e) {
        // 3. Mostrar diálogo de error
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error al crear'),
              content: Text(provider.errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
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
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 16,
                children: [
                  const SizedBox(height: 0),
                  //TODO: COMPONETIZAR ESTE WIDGET
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
                                        style:
                                            TextStyle(color: AppColors.black),
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
                  //TODO: COMPONETIZAR ESTE WIDGET
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                          color: AppColors.transparent,
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
                                GeneralTextformfield(
                                  controller: widget.product == null
                                      ? _nameController
                                      : nameEditController,
                                  labelText: 'Nombre *',
                                  hintText: 'Nombre único del producto',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El nombre es obligatorio.';
                                    }
                                    if (value.length < 3) {
                                      return 'El nombre debe tener al menos 3 caracteres.';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralTextformfield(
                                    controller: widget.product == null
                                        ? _descriptionController
                                        : descriptionEditController,
                                    labelText: 'Descripción',
                                    hintText: 'Detalles del producto',
                                    maxLines: 2),
                                GeneralTextformfield(
                                  controller: widget.product == null
                                      ? _priceController
                                      : priceEditController,
                                  labelText: 'Precio',
                                  hintText: 'Precio del producto',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final price = double.tryParse(value ?? '');
                                    if (price == null || price <= 0) {
                                      return 'Ingrese un precio válido y positivo.';
                                    }
                                    return null;
                                  },
                                ),
                                Row(
                                  spacing: 8,
                                  children: [
                                    Flexible(
                                      child: GeneralTextformfield(
                                        controller: widget.product == null
                                            ? _stockQuantityController
                                            : _stockEditQuantityController,
                                        labelText: 'Cantidad en Stock *',
                                        hintText: 'Ej: 100',
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          final quantity =
                                              int.tryParse(value ?? '');
                                          if (quantity == null ||
                                              quantity < 0) {
                                            return 'Ingrese una cantidad entera no negativa.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    /* Flexible(
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
                                            viewModel.selectedQuantity =
                                                newValue;
                                            // Handle the selected value
                                            print(
                                                "Selected quantity: $newValue");
                                          }
                                        },
                                      ),
                                    ) */
                                  ],
                                ),
                                const SizedBox(height: 0),
                                GeneralButton(
                                  onTap: widget.product != null
                                      ? () async {
                                          _updateProduct(
                                            product: Product(
                                            id: widget.product!.id,
                                            name: nameEditController.text,
                                            description: descriptionEditController.text,
                                            price: double.tryParse(priceEditController.text) ?? 0.0,
                                            image: viewModel.galleryImage?.path ?? '',
                                            idStock: _idStockController.text,
                                            stockQuantity: int.tryParse(_stockEditQuantityController.text) ?? 0,
                                            quantityToBuy: 0,
                                          ));
                                        }
                                      : () async {
                                          _createProduct(
                                            product: Product(
                                            id: _uuid.v4(),
                                            name: _nameController.text,
                                            description: _descriptionController.text,
                                            price: double.tryParse(_priceController.text) ?? 0.0,
                                            image: viewModel.galleryImage?.path ?? '',
                                            idStock: _idStockController.text,
                                            stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
                                            quantityToBuy: 0,
                                          ));
                                        },
                                  child: Center(
                                    child: Text(
                                      widget.product != null ? "Update" : "Save",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        })),
      ),
    );
  }
}

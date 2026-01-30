import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/core/resource/custom_dialgos.dart';
import 'package:grocery_store/core/utils/prefs_keys.dart';
import 'package:grocery_store/data/repositories/local/prefs.dart';
import 'package:grocery_store/domain/entities/product.dart';
import 'package:grocery_store/core/resource/colors.dart';
import 'package:grocery_store/core/resource/images.dart';
import 'package:grocery_store/core/utils/extension.dart';
import 'package:grocery_store/ui/widgets/general_button.dart';
import 'package:grocery_store/ui/widgets/general_textformfield.dart';
import 'package:grocery_store/ui/view_model/providers/add_product_view_model.dart';
import 'package:grocery_store/ui/view_model/providers/home_view_model.dart';
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
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _idStockController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  late final TextEditingController nameEditController;
  late final TextEditingController descriptionEditController;
  late final TextEditingController priceEditController;
  late final TextEditingController _stockEditQuantityController;

  @override
  void initState() {
    super.initState();

    nameEditController = TextEditingController(text: widget.product?.name);
    descriptionEditController = TextEditingController(text: widget.product?.description);
    priceEditController = TextEditingController(text: widget.product?.price.toString());
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
      //backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkgreen,
        centerTitle: false,
        title: Text(
          widget.product != null
              ? "lbl_update_product".translate
              : "lbl_add_product".translate,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Esto quita el foco de cualquier TextField
        },
        behavior: HitTestBehavior.opaque,
        child: SafeArea(child:
            Consumer<AddProductViewModel>(builder: (context, provider, _) {
          return Form(
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
                  child: Row(
                    spacing: 8,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          ButtonSearchImage(
                            label: "lbl_gallery".translate,
                            icon: Icons.image,
                            onTap: () async {
                              final pickedImageGalery = await PhoneImage()
                                  .pickImageFromGallery(ImageSource.gallery);
                              if (pickedImageGalery != null) {
                                provider.setGalleryImage(pickedImageGalery);
                              }
                            },
                          ),
                          ButtonSearchImage(
                            label: "lbl_internet_image".translate,
                            icon: Icons.link,
                            onTap: () {
                              CustomDialgos.showAlertDialog(
                                context: context,
                                title: 'Definir URL',
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GeneralTextformfield(
                                      controller: _urlController,
                                      hintText: 'URL',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, una url';
                                        }
                                        return null;
                                      },
                                    )
                                  ],
                                ),
                                onConfirm: () {
                                  provider.setUrlImage(_urlController.text);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                          ButtonSearchImage(
                            label: "lbl_photo".translate,
                            icon: Icons.camera_alt,
                            onTap: () async {
                              final pickedImageCamera = await PhoneImage()
                                  .pickImageFromGallery(ImageSource.camera);

                              if (pickedImageCamera != null) {
                                provider.setGalleryImage(pickedImageCamera);
                              }
                            },
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
                          child: provider.urlImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: provider.urlImage,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) =>
                                  Image.asset(AppImages.imageNotFound),
                            )
                          : provider.galleryImage != null
                              ? SizedBox(
                                  height: double.infinity,
                                  child: Image.file(
                                    provider.galleryImage!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        AppImages.imageNotFound,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                )
                              : (widget.product != null && widget.product!.image.isNotEmpty)
                                  ? SizedBox(
                                      height: double.infinity,
                                      child: widget.product!.image
                                              .startsWith('http')
                                          ? Image.network(
                                              widget.product!.image,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  AppImages.imageNotFound,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.file(
                                              File(widget.product!.image),
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  AppImages.imageNotFound,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 16,
                                      children: [
                                        const Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                          color: AppColors.darkgreen,
                                        ),
                                        Text(
                                          "lbl_no_image_selected".translate,
                                          style: const TextStyle(
                                              color: AppColors.black),
                                        ),
                                      ],
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
                        child: Column(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 0),
                            GeneralTextformfield(
                              controller: widget.product == null
                                  ? _nameController
                                  : nameEditController,
                              labelText: 'lbl_name'.translate,
                              hintText: 'lbl_product_name'.translate,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'lbl_product_name_required'.translate;
                                }
                                if (value.length < 3) {
                                  return 'lbl_product_name_>_3'.translate;
                                }
                                return null;
                              },
                            ),
                            GeneralTextformfield(
                              controller: widget.product == null
                                  ? _descriptionController
                                  : descriptionEditController,
                              labelText: 'lbl_product_description'.translate,
                              hintText: 'lbl_product_detail'.translate,
                              maxLines: 2,
                            ),
                            GeneralTextformfield(
                              controller: widget.product == null
                                  ? _priceController
                                  : priceEditController,
                              labelText: 'lbl_product_price'.translate,
                              hintText: 'lbl_product_price'.translate,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^[0-9]*\.?[0-9]*$'))
                              ],
                              validator: (value) {
                                final price = double.tryParse(value ?? '');
                                if (price == null || price <= 0) {
                                  return 'lbl_product_price_>_0'.translate;
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
                                    labelText:
                                        'lbl_quantity_in_stock'.translate,
                                    hintText: 'lbl_quantity_example'.translate,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (value) {
                                      final quantity =
                                          int.tryParse(value ?? '');
                                      if (quantity == null || quantity < 0) {
                                        return 'lbl_quantity_>_0'.translate;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 0),
                            GeneralButton(
                              onTap: widget.product != null
                                  ? () async {
                                      final userId =
                                          Prefs.getString(PrefKeys.userId) ??
                                              '';
                                      _updateProduct(
                                          product: Product(
                                        id: widget.product!.id,
                                        name: nameEditController.text,
                                        description:
                                            descriptionEditController.text,
                                        price: double.tryParse(
                                                priceEditController.text) ??
                                            0.0,
                                        image: provider.urlImage.isEmpty
                                        ? provider.galleryImage?.path ?? ''
                                        : provider.urlImage,
                                        idStock: _idStockController.text,
                                        stockQuantity: int.tryParse(
                                                _stockEditQuantityController
                                                    .text) ??
                                            0,
                                        quantityToBuy: 0,
                                        userId: userId,
                                      ));
                                    }
                                  : () async {
                                      final userId =
                                          Prefs.getString(PrefKeys.userId) ??
                                              '';
                                      _createProduct(
                                          product: Product(
                                        id: _uuid.v4(),
                                        name: _nameController.text,
                                        description: _descriptionController.text,
                                        price: double.tryParse(_priceController.text) ?? 0.0,
                                        image: provider.urlImage.isEmpty
                                                  ? provider.galleryImage?.path ?? ''
                                                  : provider.urlImage,
                                        idStock: _idStockController.text,
                                        stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
                                        quantityToBuy: 0,
                                        userId: userId,
                                      ));
                                    },
                              child: Center(
                                child: Text(
                                  widget.product != null
                                      ? "lbl_update".translate
                                      : "lbl_save".translate,
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

class ButtonSearchImage extends StatelessWidget {
  final Function onTap;
  final String label;
  final IconData icon;

  const ButtonSearchImage({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.darkgreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.lightwhite,
              size: 40,
            ),
            /* Text(
              label,
              style: const TextStyle(
                  color: AppColors.lightwhite, fontWeight: FontWeight.bold),
            ), */
          ],
        ),
      ),
    );
  }
}

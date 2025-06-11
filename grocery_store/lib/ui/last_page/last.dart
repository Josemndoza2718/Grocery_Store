import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para permitir solo números en el TextFormField
import 'package:provider/provider.dart'; // Importa el paquete provider



class LastPage extends StatelessWidget {
  const LastPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3. Envolver la aplicación con ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (context) => ProductProvider(),
      child: const CategoryProductExpansionList(),
    );
  }
}

// Modelo de datos para un Producto
class Product {
  String id;
  String name;
  String imageUrl;
  int stock;
  double price;
  int quantityToBuy; // Cantidad a comprar

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.stock,
    required this.price,
    this.quantityToBuy = 0, // Inicializamos en 0
  });
}

// Modelo de datos para una Categoría
class Carts {
  String categoryId;
  String categoryName;
  List<Product> products;
  bool isExpanded; // Para controlar la expansión del panel de la categoría

  Carts({
    required this.categoryId,
    required this.categoryName,
    required this.products,
    this.isExpanded = true,
  });
}

// 2. Crear el Provider (extiende ChangeNotifier)
class ProductProvider extends ChangeNotifier {
  // Lista de categorías con sus productos (ahora gestionada por el provider)
  final List<Carts> _categories = [
    Carts(
      categoryId: 'cat001',
      categoryName: 'Bebidas',
      products: [
        Product(
          id: 'prod001',
          name: 'Café Premium',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 50,
          price: 8.50,
        ),
        Product(
          id: 'prod004',
          name: 'Jugo de Naranja',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 30,
          price: 4.00,
        ),
      ],
    ),
    Carts(
      categoryId: 'cat002',
      categoryName: 'Snacks',
      products: [
        Product(
          id: 'prod002',
          name: 'Galletas de Avena',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 120,
          price: 3.25,
        ),
        Product(
          id: 'prod005',
          name: 'Papas Fritas',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 75,
          price: 2.50,
        ),
        Product(
          id: 'prod006',
          name: 'Maní Salado',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 90,
          price: 1.80,
        ),
      ],
    ),
    Carts(
      categoryId: 'cat003',
      categoryName: 'Granos',
      products: [
        Product(
          id: 'prod003',
          name: 'Arroz Grano Largo',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 80,
          price: 2.75,
        ),
        Product(
          id: 'prod007',
          name: 'Lentejas',
          imageUrl: 'https://cdn11.bigcommerce.com/s-qbjojecpaq/images/stencil/1280x1280/products/442/1968/Untitled_design_-_2023-06-12T155310.493__67118.1686599665.png?c=1',
          stock: 60,
          price: 3.10,
        ),
      ],
    ),
  ];

  // Getter para acceder a las categorías desde la UI
  List<Carts> get categories => _categories;

  // Método para actualizar el estado de expansión de una categoría
  void toggleCategoryExpansion(int categoryIndex, bool isExpanded) {
    _categories[categoryIndex].isExpanded = !isExpanded;
    notifyListeners(); // Notifica a los oyentes que el estado ha cambiado
  }

  // Métodos para incrementar y decrementar la cantidad de un producto
  void incrementQuantity(String productId) {
    // Buscar el producto en todas las categorías
    for (var category in _categories) {
      for (var product in category.products) {
        if (product.id == productId) {
          if (product.quantityToBuy < product.stock) {
            product.quantityToBuy++;
            notifyListeners(); // Notifica a los oyentes
          }
          return; // Salir una vez encontrado y actualizado
        }
      }
    }
  }

  void decrementQuantity(String productId) {
    // Buscar el producto en todas las categorías
    for (var category in _categories) {
      for (var product in category.products) {
        if (product.id == productId) {
          if (product.quantityToBuy > 0) {
            product.quantityToBuy--;
            notifyListeners(); // Notifica a los oyentes
          }
          return; // Salir una vez encontrado y actualizado
        }
      }
    }
  }

  // Método para actualizar la cantidad directamente desde el TextFormField
  void updateQuantityManually(String productId, String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null) {
      for (var category in _categories) {
        for (var product in category.products) {
          if (product.id == productId) {
            if (newQuantity >= 0 && newQuantity <= product.stock) {
              product.quantityToBuy = newQuantity;
            } else if (newQuantity > product.stock) {
              product.quantityToBuy = product.stock; // Limitar al stock máximo
            } else {
              product.quantityToBuy = 0; // Si es negativo o no válido
            }
            notifyListeners(); // Notifica a los oyentes
            return;
          }
        }
      }
    }
    // Si el valor no es un número o está vacío, no hacemos nada (o podríamos reiniciar a 0)
  }
}

class CategoryProductExpansionList extends StatefulWidget {
  const CategoryProductExpansionList({Key? key}) : super(key: key);

  @override
  State<CategoryProductExpansionList> createState() =>
      _CategoryProductExpansionListState();
}

class _CategoryProductExpansionListState
    extends State<CategoryProductExpansionList> {
  // Mapa para almacenar los TextEditingController por ID de producto
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores solo una vez.
    // Accede al provider en initState, pero asegúrate de que esté disponible en el contexto.
    // Esto se hace con un pequeño truco de post-frame callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      for (var category in productProvider.categories) {
        for (var product in category.products) {
          _quantityControllers[product.id] =
              TextEditingController(text: product.quantityToBuy.toString());
        }
      }
      // Escuchar cambios en el provider para actualizar los controladores
      productProvider.addListener(_onProductProviderChanged);
    });
  }

  void _onProductProviderChanged() {
    // Este método se llamará cada vez que notifyListeners() sea invocado en ProductProvider
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    for (var category in productProvider.categories) {
      for (var product in category.products) {
        // Solo actualiza el controlador si el valor del modelo es diferente para evitar loops infinitos
        if (_quantityControllers[product.id]?.text != product.quantityToBuy.toString()) {
          _quantityControllers[product.id]?.text = product.quantityToBuy.toString();
          // Mueve el cursor al final para mejor UX si el valor cambia
          _quantityControllers[product.id]?.selection = TextSelection.fromPosition(
              TextPosition(offset: product.quantityToBuy.toString().length));
        }
      }
    }
  }

  @override
  void dispose() {
    // Es importante liberar los controladores y remover el listener
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.removeListener(_onProductProviderChanged);
    _quantityControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Acceder al Provider para obtener los datos y llamar a los métodos
    // Usamos Consumer para reconstruir solo la parte necesaria, o Provider.of<T>(context) con listen: true/false
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo por Categorías'),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (int categoryIndex, bool isExpanded) {
            productProvider.toggleCategoryExpansion(categoryIndex, isExpanded);
          },
          children: productProvider.categories
              .map<ExpansionPanel>((Carts category) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    category.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text('${category.products.length} productos'),
                );
              },
              body: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: category.products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = category.products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  product.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Stock: ${product.stock} unidades',
                                          style: TextStyle(
                                              color: Colors.grey[700])),
                                      Text(
                                        'Precio: \$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Cantidad:',
                                  style: TextStyle(fontSize: 15),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.red,
                                      onPressed: () {
                                        productProvider
                                            .decrementQuantity(product.id);
                                        // No necesitamos setState() aquí porque Provider se encargará
                                      },
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: TextFormField(
                                        controller: _quantityControllers[product.id],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          hintText: '0',
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 6),
                                        ),
                                        onChanged: (value) {
                                          productProvider.updateQuantityManually(product.id, value);
                                          // La UI se actualizará a través de notifyListeners() en el provider
                                          // y el listener que actualiza el controlador.
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      color: Colors.green,
                                      onPressed: () {
                                        productProvider
                                            .incrementQuantity(product.id);
                                        // No necesitamos setState() aquí porque Provider se encargará
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  print(
                                      'Añadir ${product.quantityToBuy} de ${product.name} al carrito.');
                                  // Aquí enviarías product.id y product.quantityToBuy a tu lógica de carrito
                                  // La cantidad ya está actualizada en el modelo del provider.
                                },
                                child: const Text('Añadir'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              isExpanded: category.isExpanded,
            );
          }).toList(),
        ),
      ),
    );
  }
}
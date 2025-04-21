import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grocery_store/domain/entities/category.dart';
import 'package:grocery_store/ui/view_model/home_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  int? selectedIndexGrid = 0;
  int? pressedIndex = 0;

  

  List<String> img = [
    "https://www.motortrend.com/uploads/sites/10/2023/08/2023-audi-rs7-sportback-4wd-5door-hatchback-angular-front.png?w=768&width=768&q=75&format=webp",
    "https://finder.porsche.com/_next/image?url=%2F_next%2Fstatic%2Fmedia%2FmodelSeries718.af451930.webp&w=3840&q=75",
    "https://cdn.motor1.com/images/mgl/vxn8lG/s1/the-run-2024-nissan-skyline-r32.jpg",
    "https://di-honda-enrollment.s3.amazonaws.com/2021/model-pages/Civic_Type_R/trims/Civic+Type+R.jpg",
    "https://acnews.blob.core.windows.net/imgnews/large/NAZ_7387335f56554b7c9b9891cf2688a25f.jpg",
    "https://cdn.motor1.com/images/mgl/koEPEx/s1/subaru-wrx-2024---argentina.jpg",
    "https://catalogo.gac-sa.cl/assets/vehiculos/matriz/Salazar/1106/image_principal/image_principal.png",
    "https://deluxerentalcars.ch/wp-content/uploads/2023/08/Ferrari-488-spider-e1722751004360.jpg",
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            //Bar-search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchAnchor(
                viewShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                isFullScreen: false,
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    leading: Icon(Icons.search),
                    hintText: "Search",
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                    /* constraints: BoxConstraints(
                      minHeight: 60,
                      maxWidth: 330,
                    ), */
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return List<ListTile>.generate(5, (int index) {
                    final String item = 'item $index';
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          controller.closeView(item);
                        });
                      },
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            //GridViewButtons
            Consumer<HomeViewModel>(
              builder: (context, viewModel, _) {
                return CategoriesWidget(
                  pressedIndex: pressedIndex,
                  selectedIndexGrid: selectedIndexGrid,
                  listCategories: viewModel.listCategories,
                );
              }
            ),
            ItemListWidget(
              img: img,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AnimatedButton(
              icon: Icons.menu,
              label: "Menu",
              isSelected: selectedIndex == 0,
              onTap: () {
                setState(() {
                  selectedIndex = 0; // Seleccionar el botón de índice 0
                });
              },
            ),
            AnimatedButton(
              icon: Icons.person,
              label: "Profile",
              isSelected: selectedIndex == 1,
              onTap: () {
                setState(() {
                  selectedIndex = 1; // Seleccionar el botón de índice 1
                });
                /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashBoardPage(),
                    )); */
              },
            ),
            AnimatedButton(
              icon: Icons.card_giftcard,
              label: "Gifts",
              isSelected: selectedIndex == 2,
              onTap: () {
                setState(() {
                  selectedIndex = 2; // Seleccionar el botón de índice 2
                });
                /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PagesViewThree(),
                    )); */
              },
            ),
            AnimatedButton(
              icon: Icons.car_repair,
              label: "Car",
              isSelected: selectedIndex == 3,
              onTap: () {
                setState(() {
                  selectedIndex = 3; // Seleccionar el botón de índice 3
                });
                /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PagesViewScreen(),
                    )); */
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ItemListWidget extends StatelessWidget {
  const ItemListWidget({
    super.key,
    this.name,
    this.img,
    this.quantity,
    this.price,
  });

  final String? name;
  final String? quantity;
  final double? price;
  final List<String>? img;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          //childAspectRatio: 1.18,
        ),
        itemCount: img?.length,
        itemBuilder: (context, index) {
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    115, 184, 184, 184), // Color para el no seleccionado
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      img?[index] ?? '',
                      height: 80,
                      width: 150,
                    ),
                  ),
                  const Text(
                    "Car",
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    "Quantity",
                    style: TextStyle(fontSize: 12),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'price',
                        style: TextStyle(fontSize: 12),
                      ),
                      Icon(
                        Icons.shopping_cart_outlined,
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

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({
    super.key,
    required this.pressedIndex,
    required this.selectedIndexGrid,
    this.name, required this.listCategories,
  });

  final int? pressedIndex;
  final int? selectedIndexGrid;
  final List<Category>? listCategories;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Text(
              "Categories",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Container(
            color: Colors.transparent,
            height: 130,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.18,
              ),
              itemCount: listCategories!.length + 1,
              itemBuilder: (context, index) {
                if (index == listCategories?.length) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(115, 184, 184, 184),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                          },
                          icon: const Icon(Icons.add_circle, size: 40),
                        ),
                        const Text(
                          "Add Item",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
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
                  child: AnimatedScale(
                    scale: pressedIndex == index ? 0.9 : 1.0, // Escala animada
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedIndexGrid == index
                            ? Colors.blue // Color para el seleccionado
                            : const Color.fromARGB(115, 184, 184,
                                184), // Color para el no seleccionado
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(listCategories![index].image),
                              radius: 30,
                            ),
                          ),
                          Text(listCategories![index].name ,
                              style: const TextStyle(
                                fontSize: 12,
                              )), // Nombre de la categoría
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          /* AnimatedScale(
            scale: 1.0, // Escala animada
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    115, 184, 184, 184), // Color para el no seleccionado
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.add_circle,
                          size: 40,
                        )),
                  ),
                  const Text('add category',
                      style: TextStyle(
                        fontSize: 12,
                      )),
                ],
              ),
            ),
          ), */
        ],
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool isSelected;

  const AnimatedButton({
    Key? key,
    required this.icon,
    this.label,
    this.onTap,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        width: isSelected && label != null ? 100 : 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueGrey.shade700 : Colors.blueGrey,
          borderRadius: BorderRadius.circular(40),
        ),
        child: isSelected && label != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(icon, color: Colors.white),
                  Text(label!, style: const TextStyle(color: Colors.white)),
                ],
              )
            : Icon(icon, color: Colors.white),
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int categoryId;
  final String category;
  final double stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.category,
    required this.stockQuantity,
  });
}

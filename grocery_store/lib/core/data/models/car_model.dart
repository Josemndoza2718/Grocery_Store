import 'package:grocery_store/core/domain/entities/car.dart';

class CarModel extends Car {
  CarModel({
    required super.id,
    required super.products,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'],
      products: json['products'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products,
    };
  }

 
}

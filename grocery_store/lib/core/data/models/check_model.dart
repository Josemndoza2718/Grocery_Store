import 'package:grocery_store/core/domain/entities/check.dart';

class CheckModel extends Check {
  CheckModel({
    required super.id,
    required super.ownerId,
    super.ownerCarName,
    super.status,
    required super.products,
  });

  factory CheckModel.fromJson(Map<String, dynamic> json) {
    return CheckModel(
      id: json['id'],
      ownerId: json['owner_id'],
      ownerCarName: json['owner_car_name'],
      status: json['status'],
      products: json['products'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'owner_car_name': ownerCarName,
      'status': status,
      'products': products,
    };
  }

    toEntity(){
    return Check(
      id: id,
      ownerId: ownerId,
      ownerCarName: ownerCarName,
      status: status,
      products: products,
    );
  }
}

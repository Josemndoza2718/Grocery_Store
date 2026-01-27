import 'package:grocery_store/data/repositories/local/car_client_repository_impl.dart';
import 'package:grocery_store/domain/entities/client.dart';

class GetClientsUseCases {
  const GetClientsUseCases({required this.repository});

  final ClientRepositoryImpl repository;

  Future<List<Client>> call() async {
    return await repository.getAllClients();
  }

  

}

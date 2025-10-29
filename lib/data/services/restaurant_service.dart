import '../models/restaurant_model.dart';

class RestaurantService {
  // Mock - pas de vrai backend
  Future<void> createRestaurant(RestaurantModel restaurant) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('Mode démo: Restaurant créé - ${restaurant.name}');
  }

  Future<RestaurantModel?> getRestaurant(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    return null;
  }

  Future<List<RestaurantModel>> getRestaurantsByOwner(String ownerId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [];
  }

  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('Mode démo: Restaurant mis à jour');
  }

  Future<void> deleteRestaurant(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('Mode démo: Restaurant supprimé');
  }

  Stream<RestaurantModel?> watchRestaurant(String id) {
    return Stream.value(null);
  }

  Future<void> incrementViews(String restaurantId) async {
    print('Mode démo: Vue incrémentée');
  }

  Future<void> incrementClicks(String restaurantId, String clickType) async {
    print('Mode démo: Clic incrémenté');
  }
}

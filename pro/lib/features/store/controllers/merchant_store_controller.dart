import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';

/// All available store/commerce types — keep in sync with backend StoreType enum
const List<Map<String, String>> kStoreTypes = [
  // Restauration
  {'value': 'restaurant',  'emoji': '🍽️', 'label': 'Restaurant / Maquis'},
  {'value': 'cafe',        'emoji': '☕',  'label': 'Café / Salon de thé'},
  {'value': 'bakery',      'emoji': '🥐', 'label': 'Boulangerie / Pâtisserie'},
  // Alimentation
  {'value': 'grocery',     'emoji': '🛒', 'label': 'Épicerie / Superette'},
  {'value': 'butcher',     'emoji': '🥩', 'label': 'Boucherie'},
  {'value': 'fishmonger',  'emoji': '🐟', 'label': 'Poissonnerie'},
  // Santé & Beauté
  {'value': 'pharmacy',    'emoji': '💊', 'label': 'Pharmacie'},
  {'value': 'beauty',      'emoji': '💄', 'label': 'Beauté / Coiffure'},
  // Mode & Maison
  {'value': 'clothing',    'emoji': '👔', 'label': 'Vêtements / Mode'},
  {'value': 'boutique',    'emoji': '🛍️', 'label': 'Boutique Générale'},
  {'value': 'hardware',    'emoji': '🔧', 'label': 'Quincaillerie / Bricolage'},
  {'value': 'furniture',   'emoji': '🪑', 'label': 'Meubles / Décoration'},
  {'value': 'electronics', 'emoji': '📱', 'label': 'Électronique / Téléphones'},
  {'value': 'other',       'emoji': '🏪', 'label': 'Autre'},
];

class MerchantStoreController extends GetxController implements GetxService {
  final ApiClient apiClient;
  MerchantStoreController({required this.apiClient});

  Map<String, dynamic>? storeProfile;
  List<dynamic> schedules = [];
  List<dynamic> products = [];
  List<dynamic> orders = [];
  bool isLoading = false;

  // Fetch store profile for logged in partner
  Future<bool> getStoreProfile() async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/store/profile');
    isLoading = false;

    if (response.statusCode == 200) {
      storeProfile = response.body;
      if (storeProfile != null && storeProfile!['id'] != null) {
        getProducts();
        getOrders();
      }
      update();
      return true;
    } else {
      // Store profile might not exist yet
      storeProfile = null;
      update();
      return false;
    }
  }

  // Create or Update Store Profile
  Future<bool> createOrUpdateStore({
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required String imageUrl,
    String type = 'restaurant', // See kStoreTypes for all valid values
    String category = '',
  }) async {
    isLoading = true;
    update();

    Map<String, dynamic> payload = {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'type': type,
      'category': category,
    };

    Response response = await apiClient.postData('/api/store', payload);
    isLoading = false;

    if (response.statusCode == 200) {
      storeProfile = response.body;
      getProducts();
      getOrders();
      update();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  // Fetch weekly schedules
  Future<void> getSchedules() async {
    if (storeProfile == null) return;
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/store/schedules');
    if (response.statusCode == 200) {
      schedules = response.body ?? [];
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Update schedules
  Future<bool> updateSchedules(List<Map<String, dynamic>> schedulesPayload) async {
    isLoading = true;
    update();

    Map<String, dynamic> payload = {'schedules': schedulesPayload};
    Response response = await apiClient.putData('/api/store/schedules', payload);
    isLoading = false;

    if (response.statusCode == 200) {
      schedules = response.body ?? [];
      update();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  // Fetch products catalog
  Future<void> getProducts() async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/store/products');
    if (response.statusCode == 200) {
      products = response.body ?? [];
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Add a product
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isFeatured,
    required bool isDeliverable,
    required bool isActive,
  }) async {
    isLoading = true;
    update();

    Map<String, dynamic> payload = {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'is_deliverable': isDeliverable,
      'is_active': isActive,
    };

    Response response = await apiClient.postData('/api/store/products', payload);
    isLoading = false;

    if (response.statusCode == 201) {
      getProducts();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  // Update product details
  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isFeatured,
    required bool isDeliverable,
    required bool isActive,
  }) async {
    isLoading = true;
    update();

    Map<String, dynamic> payload = {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'is_deliverable': isDeliverable,
      'is_active': isActive,
    };

    Response response = await apiClient.putData('/api/store/products/$productId', payload);
    isLoading = false;

    if (response.statusCode == 200) {
      getProducts();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    isLoading = true;
    update();

    Response response = await apiClient.deleteData('/api/store/products/$productId');
    isLoading = false;

    if (response.statusCode == 204) {
      getProducts();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }

  // Fetch orders received by store
  Future<void> getOrders() async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/store/orders');
    if (response.statusCode == 200) {
      orders = response.body ?? [];
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Update order status (Accept order / Preparing / Ready / Completed)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    isLoading = true;
    update();

    Map<String, dynamic> payload = {'status': newStatus};
    Response response = await apiClient.putData('/api/store/orders/$orderId/status', payload);
    isLoading = false;

    if (response.statusCode == 200) {
      getOrders();
      return true;
    } else {
      ApiChecker.checkApi(response);
      update();
      return false;
    }
  }
}

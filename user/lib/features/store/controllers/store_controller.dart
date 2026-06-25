import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';

class StoreController extends GetxController implements GetxService {
  final ApiClient apiClient;
  StoreController({required this.apiClient});

  List<dynamic> nearbyStores = [];
  List<dynamic> products = [];
  Map<String, dynamic>? selectedStore;
  List<dynamic> orders = [];
  Map<String, dynamic>? currentOrder;

  List<Map<String, dynamic>> cart = [];
  double cartTotal = 0.0;
  bool isLoading = false;

  // Search filter
  String storeSearchQuery = '';
  String activeStoreType = ''; // '' = all, 'restaurant', 'boutique', etc.

  // Get nearby stores listing
  Future<void> getNearbyStores({String search = '', String type = ''}) async {
    isLoading = true;
    update();

    storeSearchQuery = search;
    activeStoreType = type;
    double lat = 0.0;
    double lng = 0.0;

    try {
      final locController = Get.find<LocationController>();
      final address = locController.getUserAddress();
      if (address != null) {
        lat = double.tryParse(address.latitude.toString()) ?? 0.0;
        lng = double.tryParse(address.longitude.toString()) ?? 0.0;
      }
    } catch (e) {
      // Fallback
    }

    final typeParam = type.isNotEmpty ? '&type=$type' : '';
    Response response = await apiClient.getData(
      '/api/customer/stores?lat=$lat&lng=$lng&search=$search$typeParam',
    );

    if (response.statusCode == 200) {
      nearbyStores = response.body ?? [];
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Get a single store detail
  Future<void> getStoreDetails(String storeId) async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/customer/stores/$storeId');
    if (response.statusCode == 200) {
      selectedStore = response.body;
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Get product catalog of a store
  Future<void> getStoreProducts(String storeId) async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/customer/stores/$storeId/products');
    if (response.statusCode == 200) {
      products = response.body ?? [];
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Cart operations
  void addToCart(Map<String, dynamic> product, int quantity) {
    // Check if product already exists in cart
    int index = cart.indexWhere((element) => element['product_id'] == product['id']);
    if (index != -1) {
      cart[index]['quantity'] += quantity;
    } else {
      cart.add({
        'product_id': product['id'],
        'name': product['name'],
        'price': double.parse(product['price'].toString()),
        'quantity': quantity,
        'image_url': product['image_url'] ?? '',
      });
    }
    calculateCartTotal();
    update();
  }

  void updateCartQty(String productId, int quantity) {
    int index = cart.indexWhere((element) => element['product_id'] == productId);
    if (index != -1) {
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index]['quantity'] = quantity;
      }
      calculateCartTotal();
      update();
    }
  }

  void removeFromCart(String productId) {
    cart.removeWhere((element) => element['product_id'] == productId);
    calculateCartTotal();
    update();
  }

  void clearCart() {
    cart.clear();
    cartTotal = 0.0;
    update();
  }

  void calculateCartTotal() {
    double total = 0.0;
    for (var item in cart) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    cartTotal = total;
  }

  // Checkout and Order Placement
  Future<Map<String, dynamic>?> placeOrder({
    required String storeId,
    required String deliveryType, // "delivery" or "pickup"
    String? deliveryAddress,
    double? lat,
    double? lng,
  }) async {
    isLoading = true;
    update();

    List<Map<String, dynamic>> itemsPayload = cart.map((item) {
      return {
        'product_id': item['product_id'],
        'quantity': item['quantity'],
      };
    }).toList();

    Map<String, dynamic> payload = {
      'store_id': storeId,
      'delivery_type': deliveryType,
      'items': itemsPayload,
    };

    if (deliveryType == 'delivery') {
      payload['delivery_address'] = deliveryAddress ?? '';
      payload['delivery_lat'] = lat ?? 0.0;
      payload['delivery_lng'] = lng ?? 0.0;
    }

    Response response = await apiClient.postData('/api/customer/stores/orders', payload);
    isLoading = false;
    update();

    if (response.statusCode == 201) {
      clearCart();
      return response.body;
    } else {
      ApiChecker.checkApi(response);
      return null;
    }
  }

  // Get orders history
  Future<void> getOrderHistory() async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/customer/stores/orders');
    if (response.statusCode == 200) {
      orders = response.body ?? [];
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }

  // Get single order details
  Future<void> getOrderDetails(String orderId) async {
    isLoading = true;
    update();

    Response response = await apiClient.getData('/api/customer/stores/orders/$orderId');
    if (response.statusCode == 200) {
      currentOrder = response.body;
    } else {
      ApiChecker.checkApi(response);
    }

    isLoading = false;
    update();
  }
}

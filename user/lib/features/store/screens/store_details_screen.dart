import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/store/controllers/store_controller.dart';
import 'package:ride_sharing_user_app/features/store/screens/store_order_details_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class StoreDetailsScreen extends StatefulWidget {
  final String storeId;
  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  String _deliveryType = 'delivery'; // 'delivery' or 'pickup'

  @override
  void initState() {
    super.initState();
    Get.find<StoreController>().getStoreDetails(widget.storeId);
    Get.find<StoreController>().getStoreProducts(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(title: 'store_details'.tr),
        body: GetBuilder<StoreController>(builder: (storeController) {
          if (storeController.isLoading && storeController.selectedStore == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final store = storeController.selectedStore;
          if (store == null) {
            return Center(child: Text('store_not_found'.tr));
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Store Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      color: Theme.of(context).cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                  child: store['image_url'] != null && store['image_url'].toString().isNotEmpty
                                      ? Image.network(store['image_url'], fit: BoxFit.cover)
                                      : const Icon(Icons.store, size: 45, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store['name'] ?? '',
                                      style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      store['address'] ?? '',
                                      style: textRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 2),
                                        Text(
                                          (store['rating'] ?? 5.0).toString(),
                                          style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            store['description'] ?? '',
                            style: textRegular.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                      child: Text(
                        'catalog_products'.tr,
                        style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                    ),
                  ),

                  // Products List
                  storeController.products.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Center(
                              child: Text(
                                'no_products_in_catalog'.tr,
                                style: textRegular.copyWith(color: Theme.of(context).hintColor),
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = storeController.products[index];
                              final cartIndex = storeController.cart.indexWhere(
                                (element) => element['product_id'] == product['id'],
                              );
                              final cartItem = cartIndex != -1 ? storeController.cart[cartIndex] : null;
                              final qty = cartItem != null ? cartItem['quantity'] as int : 0;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Product Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[150],
                                        child: product['image_url'] != null && product['image_url'].toString().isNotEmpty
                                            ? Image.network(product['image_url'], fit: BoxFit.cover)
                                            : const Icon(Icons.fastfood, size: 30, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeDefault),

                                    // Product Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'] ?? '',
                                            style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product['description'] ?? '',
                                            style: textRegular.copyWith(
                                              color: Theme.of(context).hintColor,
                                              fontSize: Dimensions.fontSizeSmall,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${double.parse(product['price'].toString()).toStringAsFixed(2)} F',
                                            style: textBold.copyWith(
                                              color: Theme.of(context).primaryColor,
                                              fontSize: Dimensions.fontSizeDefault,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Qty Control
                                    Row(
                                      children: [
                                        if (qty > 0) ...[
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                            onPressed: () {
                                              storeController.updateCartQty(product['id'], qty - 1);
                                            },
                                          ),
                                          Text(
                                            qty.toString(),
                                            style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                          ),
                                        ],
                                        IconButton(
                                          icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                                          onPressed: () {
                                            storeController.addToCart(product, 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: storeController.products.length,
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Bottom Cart Bar
              if (storeController.cart.isNotEmpty)
                Positioned(
                  bottom: Dimensions.paddingSizeDefault,
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${storeController.cart.length} ${'items'.tr}',
                              style: textRegular.copyWith(color: Colors.white70, fontSize: Dimensions.fontSizeSmall),
                            ),
                            Text(
                              '${storeController.cartTotal.toStringAsFixed(2)} F',
                              style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showCheckoutSheet(context, storeController),
                          child: Text('checkout'.tr, style: textSemiBold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showCheckoutSheet(BuildContext context, StoreController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          final locController = Get.find<LocationController>();
          final address = locController.getUserAddress();
          final String addressText = address?.address ?? '';
          final double lat = double.parse(address?.latitude?.toString() ?? '0.0');
          final double lng = double.parse(address?.longitude?.toString() ?? '0.0');

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('order_summary'.tr, style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                // Delivery Options Selector
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setModalState(() => _deliveryType = 'delivery'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            border: Border.all(color: _deliveryType == 'delivery' ? Theme.of(context).primaryColor : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                            color: _deliveryType == 'delivery' ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
                          ),
                          child: Center(
                            child: Text('delivery'.tr, style: textMedium.copyWith(color: _deliveryType == 'delivery' ? Theme.of(context).primaryColor : Colors.black87)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: InkWell(
                        onTap: () => setModalState(() => _deliveryType = 'pickup'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            border: Border.all(color: _deliveryType == 'pickup' ? Theme.of(context).primaryColor : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                            color: _deliveryType == 'pickup' ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
                          ),
                          child: Center(
                            child: Text('pickup'.tr, style: textMedium.copyWith(color: _deliveryType == 'pickup' ? Theme.of(context).primaryColor : Colors.black87)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                if (_deliveryType == 'delivery') ...[
                  Text('delivery_address'.tr, style: textMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          addressText.isNotEmpty ? addressText : 'select_location'.tr,
                          style: textRegular.copyWith(color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ],

                // Cost Summary
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('items_price'.tr, style: textRegular),
                    Text('${controller.cartTotal.toStringAsFixed(2)} F', style: textRegular),
                  ],
                ),
                if (_deliveryType == 'delivery') ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('delivery_fee'.tr, style: textRegular),
                      Text('5.00 F', style: textRegular), // Approximation or calculated later
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('total'.tr, style: textBold),
                    Text(
                      '${(controller.cartTotal + (_deliveryType == 'delivery' ? 5.0 : 0.0)).toStringAsFixed(2)} F',
                      style: textBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                GetBuilder<StoreController>(builder: (storeController) {
                  if (storeController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ButtonWidget(
                    buttonText: 'place_order'.tr,
                    onPressed: () async {
                      final order = await storeController.placeOrder(
                        storeId: widget.storeId,
                        deliveryType: _deliveryType,
                        deliveryAddress: addressText,
                        lat: lat,
                        lng: lng,
                      );

                      if (order != null) {
                        Navigator.pop(context); // close sheet
                        Get.to(() => StoreOrderDetailsScreen(orderId: order['id']));
                      }
                    },
                  );
                }),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          );
        });
      },
    );
  }
}

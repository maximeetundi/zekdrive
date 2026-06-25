import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/store/controllers/store_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class StoreOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const StoreOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<StoreOrderDetailsScreen> createState() => _StoreOrderDetailsScreenState();
}

class _StoreOrderDetailsScreenState extends State<StoreOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    Get.find<StoreController>().getOrderDetails(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(
          title: 'order_status'.tr,
          onBackPressed: () {
            // Pop to main page or specific history
            Get.back();
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _fetch();
          },
          child: GetBuilder<StoreController>(builder: (storeController) {
            if (storeController.isLoading && storeController.currentOrder == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final order = storeController.currentOrder;
            if (order == null) {
              return Center(child: Text('order_not_found'.tr));
            }

            // Calculate status index
            final String status = order['status'] ?? 'pending';
            final String deliveryType = order['delivery_type'] ?? 'delivery';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'status'.tr,
                          style: textRegular.copyWith(color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.toUpperCase().tr,
                          style: textBold.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Stepper representation
                        _buildStatusStepper(status, deliveryType),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // OTP representation if pickup or not completed
                  if (status != 'completed' && status != 'cancelled')
                    Container(
                      width: Get.width,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'pickup_otp_code'.tr,
                            style: textSemiBold.copyWith(color: Colors.orange[800]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order['pickup_otp'] ?? '------',
                            style: textBold.copyWith(
                              fontSize: 32,
                              letterSpacing: 4,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            deliveryType == 'pickup'
                                ? 'present_to_merchant_pickup'.tr
                                : 'present_to_driver_delivery'.tr,
                            style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Store/Restaurant info
                  Text('boutique'.tr, style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store, color: Colors.grey, size: 30),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order['store_name'] ?? '', style: textMedium),
                              Text(
                                order['store_address'] ?? '',
                                style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Courier driver info
                  if (deliveryType == 'delivery' && order['driver'] != null) ...[
                    Text('delivery_courier'.tr, style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bike, color: Colors.grey, size: 30),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order['driver']['user']['name'] ?? '', style: textMedium),
                                Text(
                                  order['driver']['license_number'] ?? '',
                                  style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                            onPressed: () {
                              // call driver
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  // Items Summary
                  Text('order_items'.tr, style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3)],
                    ),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (order['items'] as List<dynamic>?)?.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = order['items'][index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['quantity']}x ${item['product_name'] ?? 'product'.tr}',
                                    style: textRegular,
                                  ),
                                  Text(
                                    '${(double.parse(item['price'].toString()) * (item['quantity'] as int)).toStringAsFixed(2)} F',
                                    style: textMedium,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('items_price'.tr, style: textRegular),
                            Text('${double.parse(order['items_total'].toString()).toStringAsFixed(2)} F', style: textRegular),
                          ],
                        ),
                        if (deliveryType == 'delivery') ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('delivery_fee'.tr, style: textRegular),
                              Text('${double.parse(order['delivery_fare'].toString()).toStringAsFixed(2)} F', style: textRegular),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('total'.tr, style: textBold),
                            Text(
                              '${double.parse(order['total_fare'].toString()).toStringAsFixed(2)} F',
                              style: textBold.copyWith(color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStatusStepper(String currentStatus, String deliveryType) {
    List<String> statuses = ['pending', 'accepted', 'preparing'];
    if (deliveryType == 'delivery') {
      statuses.addAll(['ready_for_pickup', 'delivering', 'completed']);
    } else {
      statuses.addAll(['ready_for_pickup', 'completed']);
    }

    int currentIndex = statuses.indexOf(currentStatus);
    if (currentStatus == 'cancelled') {
      return Text('order_cancelled'.tr, style: textSemiBold.copyWith(color: Colors.red));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(statuses.length, (index) {
        bool isDone = index <= currentIndex;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? Theme.of(context).primaryColor : Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: isDone ? Colors.white : Colors.transparent,
                    size: 14,
                  ),
                ),
              ),
              if (index < statuses.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex ? Theme.of(context).primaryColor : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

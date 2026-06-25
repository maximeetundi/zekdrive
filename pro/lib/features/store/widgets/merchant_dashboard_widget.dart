import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/text_field_widget.dart';
import 'package:ride_sharing_user_app/features/store/controllers/merchant_store_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MerchantDashboardWidget extends StatefulWidget {
  const MerchantDashboardWidget({super.key});

  @override
  State<MerchantDashboardWidget> createState() => _MerchantDashboardWidgetState();
}

class _MerchantDashboardWidgetState extends State<MerchantDashboardWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Profile Setup Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _selectedStoreType = 'restaurant'; // restaurant, boutique, grocery, pharmacy, other

  // Add Product Controllers
  final TextEditingController _pNameController = TextEditingController();
  final TextEditingController _pDescController = TextEditingController();
  final TextEditingController _pPriceController = TextEditingController();
  final TextEditingController _pImgController = TextEditingController();
  bool _pFeatured = false;
  bool _pDeliverable = true;
  bool _pActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Get.find<MerchantStoreController>().getStoreProfile().then((hasProfile) {
      if (hasProfile) {
        _fillProfileData();
      }
    });
  }

  void _fillProfileData() {
    final store = Get.find<MerchantStoreController>().storeProfile;
    if (store != null) {
      _nameController.text = store['name'] ?? '';
      _descController.text = store['description'] ?? '';
      _addressController.text = store['address'] ?? '';
      _latController.text = (store['latitude'] ?? 0.0).toString();
      _lngController.text = (store['longitude'] ?? 0.0).toString();
      _imgController.text = store['image_url'] ?? '';
      _categoryController.text = store['category'] ?? '';
      if (store['type'] != null) {
        _selectedStoreType = store['type'];
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imgController.dispose();
    _categoryController.dispose();
    _pNameController.dispose();
    _pDescController.dispose();
    _pPriceController.dispose();
    _pImgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MerchantStoreController>(builder: (storeController) {
      if (storeController.isLoading && storeController.storeProfile == null) {
        return const Center(child: CircularProgressIndicator());
      }

      // 1. If NO store profile created yet, show profile setup screen
      if (storeController.storeProfile == null) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'create_store_profile'.tr,
                style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),
              Text(
                'create_store_profile_desc'.tr,
                style: textRegular.copyWith(color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldWidget(
                controller: _nameController,
                hintText: 'store_name_hint'.tr,
                inputType: TextInputType.name,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldWidget(
                controller: _descController,
                hintText: 'store_desc_hint'.tr,
                inputType: TextInputType.multiline,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldWidget(
                controller: _addressController,
                hintText: 'store_address_hint'.tr,
                inputType: TextInputType.streetAddress,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(
                children: [
                  Expanded(
                    child: TextFieldWidget(
                      controller: _latController,
                      hintText: 'latitude'.tr,
                      inputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: TextFieldWidget(
                      controller: _lngController,
                      hintText: 'longitude'.tr,
                      inputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldWidget(
                controller: _imgController,
                hintText: 'store_image_url_hint'.tr,
                inputType: TextInputType.url,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Store Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStoreType,
                    isExpanded: true,
                    hint: Text('store_type'.tr),
                    items: [
                      DropdownMenuItem(value: 'restaurant', child: Text('restaurant'.tr)),
                      DropdownMenuItem(value: 'boutique', child: Text('boutique'.tr)),
                      DropdownMenuItem(value: 'grocery', child: Text('grocery'.tr)),
                      DropdownMenuItem(value: 'pharmacy', child: Text('pharmacy'.tr)),
                      DropdownMenuItem(value: 'other', child: Text('other'.tr)),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStoreType = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldWidget(
                controller: _categoryController,
                hintText: 'store_category'.tr,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              ButtonWidget(
                buttonText: 'save_profile'.tr,
                isLoading: storeController.isLoading,
                onPressed: () async {
                  if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
                    showCustomSnackBar('please_fill_required_fields'.tr);
                    return;
                  }
                  double lat = double.tryParse(_latController.text) ?? 0.0;
                  double lng = double.tryParse(_lngController.text) ?? 0.0;

                  bool success = await storeController.createOrUpdateStore(
                    name: _nameController.text.trim(),
                    description: _descController.text.trim(),
                    address: _addressController.text.trim(),
                    latitude: lat,
                    longitude: lng,
                    imageUrl: _imgController.text.trim(),
                    type: _selectedStoreType,
                    category: _categoryController.text.trim(),
                  );

                  if (success) {
                    showCustomSnackBar('profile_created_successfully'.tr, isError: false);
                  }
                },
              ),
            ],
          ),
        );
      }

      // 2. Render Main Store Dashboard Panel
      final store = storeController.storeProfile!;

      return Column(
        children: [
          const SizedBox(height: 60),
          // Store Header card
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: store['image_url'] != null && store['image_url'].toString().isNotEmpty
                        ? Image.network(store['image_url'], fit: BoxFit.cover)
                        : const Icon(Icons.store, size: 30, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store['name'] ?? '', style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      Text(
                        store['address'] ?? '',
                        style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: store['is_active'] ?? false,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) {
                    storeController.createOrUpdateStore(
                      name: store['name'],
                      description: store['description'] ?? '',
                      address: store['address'],
                      latitude: store['latitude'],
                      longitude: store['longitude'],
                      imageUrl: store['image_url'] ?? '',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Tab Bar Navigation
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'orders'.tr),
              Tab(text: 'products'.tr),
              Tab(text: 'edit'.tr),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Orders List
                RefreshIndicator(
                  onRefresh: () async => storeController.getOrders(),
                  child: _buildOrdersList(storeController),
                ),

                // TAB 2: Products Management
                _buildProductsList(storeController),

                // TAB 3: Edit Store profile
                _buildEditProfileForm(storeController),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOrdersList(MerchantStoreController controller) {
    if (controller.orders.isEmpty) {
      return Center(child: Text('no_orders_found'.tr));
    }

    return ListView.builder(
      itemCount: controller.orders.length,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemBuilder: (context, index) {
        final order = controller.orders[index];
        final String status = order['status'] ?? 'pending';
        final String deliveryType = order['delivery_type'] ?? 'delivery';

        Color statusColor = Colors.orange;
        if (status == 'preparing') statusColor = Colors.blue;
        if (status == 'ready_for_pickup') statusColor = Colors.teal;
        if (status == 'delivering') statusColor = Colors.purple;
        if (status == 'completed' || status == 'delivered') statusColor = Colors.green;
        if (status == 'cancelled') statusColor = Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order['id'].toString().substring(0, 8)}', style: textSemiBold),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                    child: Text(status.toUpperCase().tr, style: textBold.copyWith(color: statusColor, fontSize: Dimensions.fontSizeExtraSmall)),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text('${'customer'.tr}: ${order['customer_name'] ?? ''} (${order['customer_phone'] ?? ''})', style: textRegular),
              const SizedBox(height: 4),
              Text('${'delivery_type'.tr}: ${deliveryType.toUpperCase().tr}', style: textRegular),
              if (deliveryType == 'delivery') ...[
                const SizedBox(height: 4),
                Text('${'address'.tr}: ${order['delivery_address'] ?? ''}', style: textRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 4),
              Text('${'total'.tr}: ${double.parse(order['total_fare'].toString()).toStringAsFixed(2)} F', style: textBold.copyWith(color: Theme.of(context).primaryColor)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Action Buttons
              if (status == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => controller.updateOrderStatus(order['id'], 'cancelled'),
                        child: Text('reject'.tr),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                        onPressed: () => controller.updateOrderStatus(order['id'], 'accepted'),
                        child: Text('accept'.tr),
                      ),
                    ),
                  ],
                ),
              ] else if (status == 'accepted' || status == 'preparing') ...[
                ButtonWidget(
                  buttonText: 'mark_ready_for_pickup'.tr,
                  onPressed: () => controller.updateOrderStatus(order['id'], 'ready_for_pickup'),
                ),
              ] else if (status == 'ready_for_pickup' && deliveryType == 'pickup') ...[
                ButtonWidget(
                  buttonText: 'verify_otp_complete'.tr,
                  onPressed: () => _showVerifyOtpDialog(context, controller, order),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showVerifyOtpDialog(BuildContext context, MerchantStoreController controller, Map<String, dynamic> order) {
    final TextEditingController otpInputController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('verify_otp'.tr, style: textBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('enter_customer_otp_complete'.tr, style: textRegular),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              TextFieldWidget(
                controller: otpInputController,
                hintText: 'otp_hint'.tr,
                inputType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr, style: textRegular.copyWith(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                if (otpInputController.text.trim() == order['pickup_otp']) {
                  Navigator.pop(context);
                  bool success = await controller.updateOrderStatus(order['id'], 'completed');
                  if (success) {
                    showCustomSnackBar('order_completed_successfully'.tr, isError: false);
                  }
                } else {
                  showCustomSnackBar('invalid_otp'.tr);
                }
              },
              child: Text('confirm'.tr, style: textSemiBold),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsList(MerchantStoreController controller) {
    return Scaffold(
      body: controller.products.isEmpty
          ? Center(child: Text('no_products_found'.tr))
          : ListView.builder(
              itemCount: controller.products.length,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3)],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: product['image_url'] != null && product['image_url'].toString().isNotEmpty
                              ? Image.network(product['image_url'], fit: BoxFit.cover)
                              : const Icon(Icons.fastfood, size: 25, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'] ?? '', style: textMedium),
                            Text('${double.parse(product['price'].toString()).toStringAsFixed(2)} F', style: textBold.copyWith(color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductDialog(context, controller, product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteProduct(product['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showProductDialog(context, controller),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showProductDialog(BuildContext context, MerchantStoreController controller, {Map<String, dynamic>? product}) {
    if (product != null) {
      _pNameController.text = product['name'] ?? '';
      _pDescController.text = product['description'] ?? '';
      _pPriceController.text = product['price'].toString();
      _pImgController.text = product['image_url'] ?? '';
      _pFeatured = product['is_featured'] ?? false;
      _pDeliverable = product['is_deliverable'] ?? true;
      _pActive = product['is_active'] ?? true;
    } else {
      _pNameController.clear();
      _pDescController.clear();
      _pPriceController.clear();
      _pImgController.clear();
      _pFeatured = false;
      _pDeliverable = true;
      _pActive = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(product == null ? 'add_product'.tr : 'edit_product'.tr, style: textBold),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(controller: _pNameController, hintText: 'product_name_hint'.tr),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextFieldWidget(controller: _pDescController, hintText: 'product_desc_hint'.tr),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextFieldWidget(controller: _pPriceController, hintText: 'price_hint'.tr, inputType: TextInputType.number),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextFieldWidget(controller: _pImgController, hintText: 'image_url_hint'.tr),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  CheckboxListTile(
                    title: Text('featured'.tr, style: textRegular),
                    value: _pFeatured,
                    onChanged: (val) => setModalState(() => _pFeatured = val ?? false),
                  ),
                  CheckboxListTile(
                    title: Text('deliverable'.tr, style: textRegular),
                    value: _pDeliverable,
                    onChanged: (val) => setModalState(() => _pDeliverable = val ?? true),
                  ),
                  CheckboxListTile(
                    title: Text('active'.tr, style: textRegular),
                    value: _pActive,
                    onChanged: (val) => setModalState(() => _pActive = val ?? true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr, style: textRegular.copyWith(color: Colors.red))),
              TextButton(
                onPressed: () async {
                  if (_pNameController.text.trim().isEmpty || _pPriceController.text.trim().isEmpty) {
                    showCustomSnackBar('please_fill_required_fields'.tr);
                    return;
                  }
                  double price = double.tryParse(_pPriceController.text) ?? 0.0;
                  bool success;
                  if (product == null) {
                    success = await controller.addProduct(
                      name: _pNameController.text.trim(),
                      description: _pDescController.text.trim(),
                      price: price,
                      imageUrl: _pImgController.text.trim(),
                      isFeatured: _pFeatured,
                      isDeliverable: _pDeliverable,
                      isActive: _pActive,
                    );
                  } else {
                    success = await controller.updateProduct(
                      productId: product['id'],
                      name: _pNameController.text.trim(),
                      description: _pDescController.text.trim(),
                      price: price,
                      imageUrl: _pImgController.text.trim(),
                      isFeatured: _pFeatured,
                      isDeliverable: _pDeliverable,
                      isActive: _pActive,
                    );
                  }
                  if (success) {
                    Navigator.pop(context);
                    showCustomSnackBar(product == null ? 'product_added_successfully'.tr : 'product_updated_successfully'.tr, isError: false);
                  }
                },
                child: Text('save'.tr, style: textSemiBold),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildEditProfileForm(MerchantStoreController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          TextFieldWidget(controller: _nameController, hintText: 'store_name_hint'.tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          TextFieldWidget(controller: _descController, hintText: 'store_desc_hint'.tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          TextFieldWidget(controller: _addressController, hintText: 'store_address_hint'.tr),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              Expanded(child: TextFieldWidget(controller: _latController, hintText: 'latitude'.tr, inputType: TextInputType.number)),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(child: TextFieldWidget(controller: _lngController, hintText: 'longitude'.tr, inputType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          TextFieldWidget(controller: _imgController, hintText: 'store_image_url_hint'.tr),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          ButtonWidget(
            buttonText: 'update_profile'.tr,
            isLoading: controller.isLoading,
            onPressed: () async {
              double lat = double.tryParse(_latController.text) ?? 0.0;
              double lng = double.tryParse(_lngController.text) ?? 0.0;
              bool success = await controller.createOrUpdateStore(
                name: _nameController.text.trim(),
                description: _descController.text.trim(),
                address: _addressController.text.trim(),
                latitude: lat,
                longitude: lng,
                imageUrl: _imgController.text.trim(),
              );
              if (success) {
                showCustomSnackBar('store_updated_successfully'.tr, isError: false);
              }
            },
          ),
        ],
      ),
    );
  }
}

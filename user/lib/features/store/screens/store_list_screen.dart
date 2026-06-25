import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/store/controllers/store_controller.dart';
import 'package:ride_sharing_user_app/features/store/screens/store_details_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// List of store types to display as tabs — sync with backend StoreType enum
const List<Map<String, String>> _storeTypeTabs = [
  {'type': '',            'label': 'all',         'emoji': '🏪'},
  // Restauration
  {'type': 'restaurant',  'label': 'restaurant',  'emoji': '🍽️'},
  {'type': 'cafe',        'label': 'cafe',        'emoji': '☕'},
  {'type': 'bakery',      'label': 'bakery',      'emoji': '🥐'},
  // Alimentation
  {'type': 'grocery',     'label': 'grocery',     'emoji': '🛒'},
  {'type': 'butcher',     'label': 'butcher',     'emoji': '🥩'},
  {'type': 'fishmonger',  'label': 'fishmonger',  'emoji': '🐟'},
  // Santé & Beauté
  {'type': 'pharmacy',    'label': 'pharmacy',    'emoji': '💊'},
  {'type': 'beauty',      'label': 'beauty',      'emoji': '💄'},
  // Mode & Maison
  {'type': 'clothing',    'label': 'clothing',    'emoji': '👔'},
  {'type': 'boutique',    'label': 'boutique',    'emoji': '🛍️'},
  {'type': 'hardware',    'label': 'hardware',    'emoji': '🔧'},
  {'type': 'furniture',   'label': 'furniture',   'emoji': '🪑'},
  {'type': 'electronics', 'label': 'electronics', 'emoji': '📱'},
  {'type': 'other',       'label': 'other',       'emoji': '🏪'},
];

class StoreListScreen extends StatefulWidget {
  final String initialType;
  const StoreListScreen({super.key, this.initialType = ''});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Determine the initial tab index based on the initialType param
    int initialIndex = _storeTypeTabs.indexWhere((e) => e['type'] == widget.initialType);
    if (initialIndex < 0) initialIndex = 0;

    _tabController = TabController(
      length: _storeTypeTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    // Load data for initial tab
    final initialType = _storeTypeTabs[initialIndex]['type']!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<StoreController>().getNearbyStores(type: initialType);
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final type = _storeTypeTabs[_tabController.index]['type']!;
        _searchController.clear();
        Get.find<StoreController>().getNearbyStores(type: type);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Get icon for each store type tab
  IconData _typeIcon(String type) {
    switch (type) {
      case 'restaurant':  return Icons.restaurant;
      case 'cafe':        return Icons.local_cafe;
      case 'bakery':      return Icons.bakery_dining;
      case 'grocery':     return Icons.local_grocery_store;
      case 'butcher':     return Icons.set_meal;
      case 'fishmonger':  return Icons.set_meal_outlined;
      case 'pharmacy':    return Icons.local_pharmacy;
      case 'beauty':      return Icons.face_retouching_natural;
      case 'clothing':    return Icons.checkroom;
      case 'boutique':    return Icons.store;
      case 'hardware':    return Icons.hardware;
      case 'furniture':   return Icons.chair;
      case 'electronics': return Icons.devices;
      case 'other':       return Icons.category;
      default:            return Icons.grid_view;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(title: 'stores'.tr),
        body: Column(
          children: [
            // ── Type Tab Bar ──────────────────────────────────────────────
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: _storeTypeTabs.map((tab) {
                  return Tab(
                    icon: Icon(_typeIcon(tab['type']!), size: 18),
                    text: tab['label']!.tr,
                    height: 52,
                  );
                }).toList(),
              ),
            ),

            // ── Search Field ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeSmall,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_store'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            final type = _storeTypeTabs[_tabController.index]['type']!;
                            Get.find<StoreController>().getNearbyStores(search: '', type: type);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                onChanged: (val) {
                  final type = _storeTypeTabs[_tabController.index]['type']!;
                  Get.find<StoreController>().getNearbyStores(search: val, type: type);
                },
              ),
            ),

            // ── Store List (shared for all tabs, filtered by controller) ──
            Expanded(
              child: GetBuilder<StoreController>(builder: (storeController) {
                if (storeController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (storeController.nearbyStores.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store_mall_directory_outlined,
                            size: 60, color: Theme.of(context).hintColor),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          'no_stores_found'.tr,
                          style: textRegular.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  itemCount: storeController.nearbyStores.length,
                  itemBuilder: (context, index) {
                    final store = storeController.nearbyStores[index];
                    return _StoreCard(store: store);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Store Card Widget ─────────────────────────────────────────────────────

class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  const _StoreCard({required this.store});

  bool _isStoreClosed() {
    try {
      int weekday = DateTime.now().weekday;
      int dbWeekday = weekday == 7 ? 0 : weekday;
      final schedules = store['schedule'] as List<dynamic>?;
      if (schedules != null) {
        final todaySched = schedules.firstWhere(
          (e) => e['day_of_week'] == dbWeekday,
          orElse: () => null,
        );
        if (todaySched != null) {
          return todaySched['is_closed'] ?? false;
        }
      }
    } catch (_) {}
    return false;
  }

  IconData _storeTypeIcon(String? type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
      case 'boutique':
        return Icons.store;
      case 'grocery':
        return Icons.local_grocery_store;
      case 'pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.store_mall_directory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosed = _isStoreClosed();
    final double distanceKm = store['distance'] != null
        ? double.parse(store['distance'].toString()) / 1000.0
        : 0.0;
    final String storeType = store['type'] ?? '';

    return InkWell(
      onTap: () {
        Get.to(() => StoreDetailsScreen(storeId: store['id']));
      },
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Store Image / Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: Container(
                width: 80,
                height: 80,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: store['image_url'] != null && store['image_url'].toString().isNotEmpty
                    ? Image.network(
                        store['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(_storeTypeIcon(storeType), size: 36,
                                color: Theme.of(context).primaryColor),
                      )
                    : Icon(_storeTypeIcon(storeType), size: 36,
                        color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store['name'] ?? '',
                          style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isClosed
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          isClosed ? 'closed'.tr : 'open'.tr,
                          style: textRegular.copyWith(
                            color: isClosed ? Colors.red : Colors.green,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Type badge
                  if (storeType.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        storeType.tr,
                        style: textRegular.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                    ),
                  Text(
                    store['description'] ?? '',
                    style: textRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km',
                        style: textRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/store/controllers/store_controller.dart';
import 'package:ride_sharing_user_app/features/store/screens/store_details_screen.dart';
import 'package:ride_sharing_user_app/util/colors.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

const List<Map<String, String>> _restaurantTypeTabs = [
  {'type': 'restaurant', 'label': 'restaurant', 'emoji': '🍽️'},
  {'type': 'cafe',       'label': 'cafe',        'emoji': '☕'},
  {'type': 'bakery',     'label': 'bakery',      'emoji': '🥐'},
];

class RestaurantListScreen extends StatefulWidget {
  final String initialType;
  const RestaurantListScreen({super.key, this.initialType = 'restaurant'});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int initialIndex = _restaurantTypeTabs.indexWhere((e) => e['type'] == widget.initialType);
    if (initialIndex < 0) initialIndex = 0;
    _tabController = TabController(length: _restaurantTypeTabs.length, vsync: this, initialIndex: initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<StoreController>().getNearbyStores(type: _restaurantTypeTabs[initialIndex]['type']!);
    });
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _searchController.clear();
        Get.find<StoreController>().getNearbyStores(type: _restaurantTypeTabs[_tabController.index]['type']!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BodyWidget(
        appBar: const AppBarWidget(title: 'Restauration', showBackButton: true),
        body: Column(
          children: [
            // ── Type Tabs ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2333) : const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).hintColor,
                labelStyle: textSemiBold.copyWith(fontSize: 13),
                unselectedLabelStyle: textMedium.copyWith(fontSize: 13),
                indicator: BoxDecoration(
                  gradient: kBrandGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: kBrandTeal.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                tabs: _restaurantTypeTabs.map((tab) =>
                  SizedBox(height: 40, child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tab['emoji']!, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(tab['label']!.tr),
                    ],
                  )),
                ).toList(),
              ),
            ),

            // ── Search Field ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2333) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: TextField(
                controller: _searchController,
                style: textRegular.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'search_restaurant_hint'.tr,
                  hintStyle: textRegular.copyWith(fontSize: 14, color: Theme.of(context).hintColor),
                  prefixIcon: Icon(Icons.search_rounded, color: kBrandTeal, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () {
                          _searchController.clear();
                          Get.find<StoreController>().getNearbyStores(
                            search: '', type: _restaurantTypeTabs[_tabController.index]['type']!);
                        })
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onChanged: (val) => Get.find<StoreController>().getNearbyStores(
                  search: val, type: _restaurantTypeTabs[_tabController.index]['type']!),
              ),
            ),

            // ── Store List ────────────────────────────────────────────────
            Expanded(
              child: GetBuilder<StoreController>(builder: (storeController) {
                if (storeController.isLoading) {
                  return Center(child: CircularProgressIndicator(color: kBrandTeal));
                }
                if (storeController.nearbyStores.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: kBrandTeal.withOpacity(0.08), shape: BoxShape.circle),
                      child: Icon(Icons.restaurant_outlined, size: 40, color: kBrandTeal.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 16),
                    Text('no_restaurant_found'.tr, style: textSemiBold.copyWith(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('try_another_category'.tr, style: textRegular.copyWith(fontSize: 13, color: Theme.of(context).hintColor)),
                  ]));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: storeController.nearbyStores.length,
                  itemBuilder: (context, index) => _StoreCard(store: storeController.nearbyStores[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  const _StoreCard({required this.store});

  bool _isStoreClosed() {
    try {
      int weekday = DateTime.now().weekday;
      int dbWeekday = weekday == 7 ? 0 : weekday;
      final schedules = store['schedule'] as List<dynamic>?;
      if (schedules != null) {
        final todaySched = schedules.firstWhere((e) => e['day_of_week'] == dbWeekday, orElse: () => null);
        if (todaySched != null) return todaySched['is_closed'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  IconData _storeTypeIcon(String? type) {
    switch (type) {
      case 'restaurant': return Icons.restaurant;
      case 'cafe': return Icons.local_cafe;
      case 'bakery': return Icons.bakery_dining;
      default: return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosed = _isStoreClosed();
    final double distanceKm = store['distance'] != null
        ? double.parse(store['distance'].toString()) / 1000.0 : 0.0;
    final String storeType = store['type'] ?? '';
    final double rating = double.tryParse(store['rating']?.toString() ?? '5') ?? 5.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.to(() => StoreDetailsScreen(storeId: store['id'])),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Container(
                    height: 130, width: double.infinity,
                    color: kBrandTeal.withOpacity(0.08),
                    child: store['image_url'] != null && store['image_url'].toString().isNotEmpty
                        ? Image.network(store['image_url'], fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(_storeTypeIcon(storeType), size: 48, color: kBrandTeal.withOpacity(0.4)))
                        : Icon(_storeTypeIcon(storeType), size: 48, color: kBrandTeal.withOpacity(0.4)),
                  ),
                  // Closed overlay
                  if (isClosed)
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                      child: Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(20)),
                        child: Text('closed'.tr, style: textSemiBold.copyWith(color: Colors.white, fontSize: 14)),
                      )),
                    )),
                  // Open badge
                  if (!isClosed)
                    Positioned(top: 10, right: 10, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: kSuccessGreen, borderRadius: BorderRadius.circular(20)),
                      child: Text('open'.tr, style: textSemiBold.copyWith(color: Colors.white, fontSize: 11)),
                    )),
                ],
              ),
            ),

            // ── Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(store['name'] ?? '', style: textSemiBold.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                    const SizedBox(width: 3),
                    Text(rating.toStringAsFixed(1), style: textSemiBold.copyWith(fontSize: 13)),
                  ]),
                ]),
                if (store['description'] != null && store['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(store['description'], style: textRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 10),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: kBrandTeal.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
                    child: Text(storeType.tr, style: textMedium.copyWith(color: kBrandTeal, fontSize: 11)),
                  ),
                  const Spacer(),
                  Icon(Icons.location_on_rounded, size: 14, color: Theme.of(context).hintColor),
                  const SizedBox(width: 3),
                  Text('${distanceKm.toStringAsFixed(1)} km', style: textRegular.copyWith(fontSize: 12, color: Theme.of(context).hintColor)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

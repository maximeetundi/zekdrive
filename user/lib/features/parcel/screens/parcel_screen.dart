import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/dotted_border_card.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_category_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/colors.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_view.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<ParcelController>().getParcelCategoryList(notify: true);
    Get.find<RideController>().initData();
    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initParcelData();
    Get.find<ParcelController>().initParcelData();
    Get.find<MapController>().initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BodyWidget(
        appBar: AppBarWidget(title: 'parcel_delivery'.tr),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── How it works banner ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: kBrandGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'parcel_send_title'.tr,
                                style: textBold.copyWith(fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'parcel_send_subtitle'.tr,
                                style: textRegular.copyWith(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Steps ───────────────────────────────────────────────
                  Row(
                    children: [
                      _stepItem('1', 'parcel_step_address'.tr, Icons.location_on_rounded, context),
                      _stepConnector(context),
                      _stepItem('2', 'parcel_step_size'.tr, Icons.inventory_2_rounded, context),
                      _stepConnector(context),
                      _stepItem('3', 'parcel_step_confirm'.tr, Icons.check_circle_rounded, context),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Promos banner ────────────────────────────────────────
                  const BannerView(),
                  const SizedBox(height: 20),

                  // ── Address fields ───────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 12)],
                      border: Border.all(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFF0F0F0)),
                    ),
                    child: const DottedBorderCard(),
                  ),

                  const SizedBox(height: 20),

                  // ── Category title ───────────────────────────────────────
                  Text(
                    'parcel_category_title'.tr,
                    style: textSemiBold.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // ── Categories ───────────────────────────────────────────
                  const ParcelCategoryView(),
                ],
              ),
            ),

            // ── Bottom CTA button ────────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
                ),
                child: GestureDetector(
                  onTap: () {
                    if (Get.find<ParcelController>().parcelCategoryList == null ||
                        Get.find<ParcelController>().parcelCategoryList!.isEmpty) {
                      showCustomSnackBar('no_parcel_category_found'.tr);
                    } else {
                      Get.find<ParcelController>().updateTabControllerIndex(0);
                      Get.find<ParcelController>().updateParcelState(ParcelDeliveryState.initial);
                      Get.to(() => const MapScreen(fromScreen: MapScreenType.parcel));
                    }
                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: kBrandGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: kBrandTeal.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text('add_parcel'.tr, style: textSemiBold.copyWith(fontSize: 16, color: Colors.white)),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(String num, String label, IconData icon, BuildContext context) {
    return Expanded(
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: kBrandTeal.withOpacity(0.10), shape: BoxShape.circle),
          child: Center(child: Icon(icon, color: kBrandTeal, size: 22)),
        ),
        const SizedBox(height: 6),
        Text(label, style: textRegular.copyWith(fontSize: 11, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _stepConnector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(children: List.generate(4, (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Container(width: 4, height: 2, decoration: BoxDecoration(color: kBrandTeal.withOpacity(0.3), borderRadius: BorderRadius.circular(1))),
      ))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/banner_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/banner_view.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_my_address.dart';
import 'package:ride_sharing_user_app/features/home/widgets/main_drawer.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/ongoing_parcel_list_view.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/rider_details_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/features/map/widgets/google_map_replacement.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/features/store/screens/store_list_screen.dart';
import 'package:ride_sharing_user_app/features/store/screens/restaurant_list_screen.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String greetingMessage() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'good_morning'.tr;
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'good_afternoon'.tr;
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  bool clickedMenu = false;
  Future<void> loadData() async {
    try {
      Get.find<ParcelController>().getUnpaidParcelList();
      Get.find<BannerController>().getBannerList();
      Get.find<CategoryController>().getCategoryList();
      Get.find<AddressController>().getAddressList(1);
      Get.find<CouponController>().getCouponList(1, isUpdate: false);
      Get.find<OfferController>().getOfferList(1);
      await Get.find<RideController>().getCurrentRide();
      if (Get.find<RideController>().currentTripDetails != null) {
        PusherHelper().pusherDriverStatus(
            Get.find<RideController>().currentTripDetails!.id!);
        if (Get.find<RideController>().currentTripDetails!.currentStatus ==
                'accepted' ||
            Get.find<RideController>().currentTripDetails!.currentStatus ==
                'ongoing') {
          Get.find<RideController>().startLocationRecord();
        }
      }
      await Get.find<ParcelController>().getOngoingParcelList();
      if (Get.find<ParcelController>().parcelListModel?.data?.isNotEmpty == true) {
        for (var element in Get.find<ParcelController>().parcelListModel!.data!) {
          PusherHelper().pusherDriverStatus(element.id!);
        }
      }
      // Guard: only call getNearestDriverList if lat/lng are available
      final userAddress = Get.find<LocationController>().getUserAddress();
      final lat = userAddress?.latitude;
      final lng = userAddress?.longitude;
      if (lat != null && lng != null) {
        Get.find<RideController>().getNearestDriverList(
            lat.toString(), lng.toString());
      }
    } catch (e) {
      debugPrint('[HomeScreen.loadData] error: $e');
    }
  }

  Widget _buildServiceItem(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textBold.copyWith(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      body: GetBuilder<RideController>(builder: (rideController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          int parcelCount = parcelController.parcelListModel?.totalSize ?? 0;
          int rideCount = (rideController.tripDetails != null &&
                  rideController.tripDetails!.type == 'ride_request' &&
                  (rideController.tripDetails!.currentStatus == 'pending' ||
                      rideController.tripDetails!.currentStatus == 'accepted' ||
                      rideController.tripDetails!.currentStatus == 'ongoing' ||
                      (rideController.tripDetails!.currentStatus ==
                              'completed' &&
                          (rideController.tripDetails!.paymentStatus ?? '') ==
                              'unpaid') ||
                      (rideController.tripDetails!.currentStatus ==
                              'cancelled' &&
                          (rideController.tripDetails!.paymentStatus ?? '') ==
                              'unpaid')))
              ? 1
              : 0;
          return Stack(
            children: [
              // Map layer
              Positioned.fill(
                child: GetBuilder<MapController>(builder: (mapController) {
                  return GoogleMap(
                    markers: mapController.nearestDeliveryManMarkers?.toSet() ?? {},
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        Get.find<LocationController>().getUserAddress()?.latitude ?? 3.8480,
                        Get.find<LocationController>().getUserAddress()?.longitude ?? 11.5021,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (gController) {
                      gController.setMapStyle(
                        Get.isDarkMode
                            ? Get.find<ThemeController>().darkMap
                            : Get.find<ThemeController>().lightMap,
                      );
                      mapController.setMapController(gController);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                  );
                }),
              ),

              // Floating drawer menu trigger
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: Dimensions.paddingSizeDefault,
                child: Builder(builder: (context) {
                  return GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.menu,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        size: 24,
                      ),
                    ),
                  );
                }),
              ),

              // Banners floating carousel (Sits above the bottom sheet)
              Positioned(
                bottom: 275,
                left: 0,
                right: 0,
                child: const BannerView(),
              ),

              // Floating bottom sheet/card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const SetDestinationScreen()),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).hoverColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Theme.of(context).primaryColor, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'where_to_go'.tr,
                                style: textBold.copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Get.find<RideController>().setRideCategoryIndex(0);
                                Get.to(() => const SetDestinationScreen());
                              },
                              child: _buildServiceItem(
                                context,
                                icon: Icons.local_taxi,
                                label: 'ride'.tr,
                                color: const Color(0xFF14B19E),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.to(() => const ParcelScreen()),
                              child: _buildServiceItem(
                                context,
                                icon: Icons.local_shipping,
                                label: 'parcel_delivery'.tr,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.to(() => const RestaurantListScreen(initialType: 'restaurant')),
                              child: _buildServiceItem(
                                context,
                                icon: Icons.restaurant,
                                label: 'restaurant'.tr,
                                color: const Color(0xFFFF5722),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.to(() => const StoreListScreen(initialType: '')),
                              child: _buildServiceItem(
                                context,
                                icon: Icons.store,
                                label: 'commerce'.tr,
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const HomeMyAddress(addressPage: AddressPage.home),
                    ],
                  ),
                ),
              ),

              // Bidding lists / Ongoing overlay widgets
              (rideCount + parcelCount) != 0
                  ? Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      right: Dimensions.paddingSizeDefault,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            clickedMenu = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.airport_shuttle, color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '${rideCount + parcelCount}',
                                style: textBold.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),

              if (clickedMenu)
                Positioned(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: GetBuilder<RideController>(
                            builder: (rideController) {
                          return GetBuilder<ParcelController>(
                              builder: (parcelController) {
                            return Container(
                                width: 220,
                                height: 120,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .hintColor
                                              .withOpacity(.5),
                                          blurRadius: 1,
                                          spreadRadius: 1,
                                          offset: const Offset(1, 1))
                                    ],
                                    borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(10)),
                                    color: Theme.of(context).cardColor),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          clickedMenu = false;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Theme.of(context).hintColor,
                                          size: Dimensions.iconSizeMedium,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeDefault),
                                            child: InkWell(
                                                onTap: () async {
                                                  await rideController
                                                      .getCurrentRideStatus(
                                                          fromRefresh: true);
                                                  setState(() {
                                                    clickedMenu = false;
                                                  });
                                                },
                                                child: Container(
                                                    width: 150,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Theme.of(context)
                                                                .primaryColor
                                                                .withOpacity(
                                                                    .5)),
                                                        borderRadius: BorderRadius.circular(
                                                            10),
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(.125)),
                                                    child: Padding(
                                                        padding: const EdgeInsets.all(
                                                            8.0),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                  'ongoing_ride'
                                                                      .tr),
                                                              CircleAvatar(
                                                                radius: 10,
                                                                backgroundColor:
                                                                    Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .error,
                                                                child: Text(
                                                                  '$rideCount',
                                                                  style: textRegular.copyWith(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .cardColor,
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeSmall),
                                                                ),
                                                              )
                                                            ]))))),
                                        InkWell(
                                          onTap: () {
                                            if (parcelController
                                                        .parcelListModel !=
                                                    null &&
                                                parcelController
                                                        .parcelListModel!
                                                        .data !=
                                                    null &&
                                                parcelController
                                                    .parcelListModel!
                                                    .data!
                                                    .isNotEmpty) {
                                              Get.to(() => OngoingParcelListView(
                                                  title: 'ongoing_parcel_list',
                                                  parcelListModel:
                                                      parcelController
                                                          .parcelListModel!));
                                            } else {
                                              showCustomSnackBar(
                                                  'no_parcel_available'.tr);
                                            }
                                          },
                                          child: Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(.5)),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(.125)),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          'parcel_delivery'.tr),
                                                      CircleAvatar(
                                                        radius: 10,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .error,
                                                        child: Text(
                                                          '${parcelController.parcelListModel?.totalSize ?? 0}',
                                                          style: textRegular.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall),
                                                        ),
                                                      )
                                                    ],
                                                  ))),
                                        ),
                                      ],
                                    ),
                                  ],
                                ));
                          });
                        }))),
              if (rideController.biddingList.isNotEmpty &&
                  rideController.tripDetails?.currentStatus == 'pending')
                Positioned(
                    bottom: 90,
                    left: 15,
                    right: 15,
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: GetBuilder<RideController>(
                            builder: (rideController) {
                          return SizedBox(
                            height: 170,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: rideController.biddingList.length,
                                  addRepaintBoundaries: false,
                                  addAutomaticKeepAlives: false,
                                  itemBuilder: (context, index) {
                                    return Container(
                                        width: Get.width - 70,
                                        decoration: BoxDecoration(boxShadow: [
                                          BoxShadow(
                                              color: Theme.of(context)
                                                  .hintColor
                                                  .withOpacity(.125),
                                              blurRadius: 1,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 0))
                                        ]),
                                        child: RiderDetailsWidget(
                                          bidding:
                                              rideController.biddingList[index],
                                          tripId:
                                              rideController.tripDetails?.id ?? '',
                                        ));
                                  }),
                            ),
                          );
                        })))
            ],
          );
        });
      }),
    );
  }
}
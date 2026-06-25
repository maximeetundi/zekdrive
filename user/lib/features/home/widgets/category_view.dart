import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/home/widgets/category_shimmer.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/store/screens/store_list_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (categoryController) {
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              // Left column: Parcel and first element of categoryList
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(() => const StoreListScreen()),
                        child: Container(
                          margin: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 800 : 500]!,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                Images.restaurant,
                                width: Get.width,
                                height: 84,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Text(
                                'restaurant'.tr,
                                style: textSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.to(() => const ParcelScreen()),
                        child: Container(
                          margin: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 800 : 500]!,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                Images.parcel,
                                width: Get.width,
                                height: 84,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              Text(
                                'parcel_delivery'.tr,
                                style: textSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right column: Remaining elements of categoryList
              if (categoryController.categoryList != null &&
                  categoryController.categoryList!.isNotEmpty)
                Expanded(
                  child: Column(
                    children: categoryController.categoryList!
                        .sublist(0)
                        .map(
                          (category) => Expanded(
                            child: InkWell(
                              onTap: () {
                                int index = categoryController.categoryList!
                                    .indexOf(category);
                                Get.find<RideController>()
                                    .setRideCategoryIndex(index);
                                Get.to(() => const SetDestinationScreen());
                              },
                              child: Container(
                                margin: const EdgeInsets.all(
                                    Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall),
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 800 : 500]!,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    category.id == '0'
                                        ? Image.asset(category.image ?? '')
                                        : ImageWidget(
                                            image:
                                                '${Get.find<ConfigController>().config?.imageBaseUrl?.vehicleCategory}/${category.image}',
                                            fit: BoxFit.contain,
                                          ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Text(
                                      '${category.name}'.tr,
                                      style: textSemiBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              else
                const Expanded(
                  child: CategoryShimmer(),
                ),
            ],
          ),
        );
      },
    );
  }
}

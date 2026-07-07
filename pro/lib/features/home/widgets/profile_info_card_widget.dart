import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/colors.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';

class ProfileStatusCardWidget extends StatelessWidget {
  final ProfileController profileController;
  const ProfileStatusCardWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isOnline = profileController.isOnline == "1";

    if (profileController.profileInfo == null || profileController.profileInfo!.firstName == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline ? kBrandTeal.withOpacity(0.3) : (isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB)),
            width: isOnline ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isOnline ? kBrandTeal.withOpacity(0.12) : Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Avatar
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOnline ? kBrandTeal : Theme.of(context).hintColor,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: ImageWidget(
                      width: 48,
                      height: 48,
                      image: '${Get.find<SplashController>().config!.imageBaseUrl!.profileImage}/${profileController.profileInfo!.profileImage}',
                    ),
                  ),
                ),
                // Online dot indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isOnline ? kSuccessGreen : Theme.of(context).hintColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).cardColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // ── Name & Level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profileController.profileInfo!.firstName!}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kBrandTeal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${'level'.tr} ${profileController.profileInfo!.level?.sequence ?? 0}',
                        style: textMedium.copyWith(color: kBrandTeal, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isOnline ? kSuccessGreen : Theme.of(context).hintColor).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOnline ? 'En ligne' : 'Hors ligne',
                        style: textMedium.copyWith(
                          color: isOnline ? kSuccessGreen : Theme.of(context).hintColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            // ── Online/Offline toggle
            FlutterSwitch(
              width: 80.0,
              height: 34.0,
              valueFontSize: 0,
              toggleSize: 26.0,
              value: isOnline,
              borderRadius: 30.0,
              padding: 4,
              activeColor: kBrandTeal,
              inactiveColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
              toggleBorder: Border.all(width: 0, color: Colors.transparent),
              toggleColor: Colors.white,
              showOnOff: false,
              onToggle: (val) async {
                if (GetPlatform.isIOS) {
                  Get.dialog(const LoaderWidget(), barrierDismissible: false);
                  await profileController.profileOnlineOffline(val).then((value) {
                    if (value.statusCode == 200) Get.back();
                  });
                } else {
                  Get.find<LocationController>().checkPermission(() async {
                    Get.dialog(const LoaderWidget(), barrierDismissible: false);
                    await profileController.profileOnlineOffline(val).then((value) {
                      if (value.statusCode == 200) Get.back();
                    });
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

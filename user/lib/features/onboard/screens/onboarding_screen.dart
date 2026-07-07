import 'package:ride_sharing_user_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/onboard/controllers/on_board_page_controller.dart';
import 'package:ride_sharing_user_app/features/onboard/widget/pager_content.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0E8F7E), Color(0xFF14B19E), Color(0xFF1ECDB9)],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          GetBuilder<OnBoardController>(builder: (onBoardController) {
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    onPageChanged: (value) {
                      if (value == 4) {
                        Get.find<ConfigController>().disableIntro();
                        Get.offAll(() => const SignInScreen());
                      } else {
                        onBoardController.onPageChanged(value);
                      }
                    },
                    itemCount: AppConstants.onBoardPagerData.length,
                    itemBuilder: (context, index) => PagerContent(
                      image: AppConstants.onBoardPagerData[onBoardController.pageIndex].image,
                      text: AppConstants.onBoardPagerData[onBoardController.pageIndex].title,
                      index: onBoardController.pageIndex,
                    ),
                  ),
                ),
                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(AppConstants.onBoardPagerData.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == onBoardController.pageIndex ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == onBoardController.pageIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                GetBuilder<OnBoardController>(builder: (onBoardController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraLarge,
                    ),
                    child: onBoardController.pageIndex == 3
                        ? ButtonWidget(
                            transparent: false,
                            backgroundColor: Colors.white,
                            textColor: kBrandTeal,
                            radius: 25,
                            buttonText: 'get_started'.tr,
                            onPressed: () {
                              Get.find<ConfigController>().disableIntro();
                              Get.offAll(() => const SignInScreen());
                            },
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.find<ConfigController>().disableIntro();
                                  Get.offAll(() => const SignInScreen());
                                },
                                child: Text(
                                  'skip'.tr,
                                  style: textMedium.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (AppConstants.onBoardPagerData.length - 1 ==
                                      onBoardController.pageIndex) {
                                    Get.find<ConfigController>().disableIntro();
                                    Get.offAll(() => const SignInScreen());
                                  } else {
                                    onBoardController.onPageIncrement();
                                  }
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: kBrandTeal,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                }),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            );
          }),
        ],
      ),
    );
  }
}

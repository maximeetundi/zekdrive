import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/address/screens/my_address.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_list.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/support/support_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

// Importez les autres dépendances nécessaires

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final List<NavigationModel> item = [
    NavigationModel(
      name: 'home'.tr,
      activeIcon: Images.homeActive,
      inactiveIcon: Images.homeActive,
      screen: const HomeScreen(),
    ),
    NavigationModel(
      name: 'activity'.tr,
      activeIcon: Images.activityActive,
      inactiveIcon: Images.activityActive,
      screen: const TripScreen(fromProfile: false),
    ),
    NavigationModel(
      name: 'message'.tr,
      activeIcon: Images.profileMessage,
      inactiveIcon: Images.profileMessage,
      screen: const MessageListScreen(),
    ),
    NavigationModel(
      name: 'notification'.tr,
      activeIcon: Images.notificationActive,
      inactiveIcon: Images.notificationActive,
      screen: const NotificationScreen(),
    ),
    NavigationModel(
      name: 'my_wallet'.tr,
      activeIcon: Images.profileMyWallet,
      inactiveIcon: Images.profileMyWallet,
      screen: const WalletScreen(),
    ),
    NavigationModel(
      name: 'my_address'.tr,
      activeIcon: Images.location,
      inactiveIcon: Images.location,
      screen: const MyAddressScreen(),
    ),
    NavigationModel(
      name: 'profile'.tr,
      activeIcon: Images.profileActive,
      inactiveIcon: Images.profileActive,
      screen: const ProfileScreen(),
    ),
    NavigationModel(
      name: 'help_support'.tr,
      activeIcon: Images.profileHelpSupport,
      inactiveIcon: Images.profileHelpSupport,
      screen: const HelpAndSupportScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GetBuilder<ProfileController>(builder: (profileController) {
            return DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              margin: EdgeInsets.zero, // Remove default margin
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context)
                      .padding
                      .top), // Add top padding to avoid overlapping with status bar
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: ImageWidget(
                        height: 70,
                        width: 70,
                        image: profileController
                                    .profileModel?.data?.profileImage !=
                                null
                            ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/${profileController.profileModel?.data?.profileImage ?? ''}'
                            : '',
                        placeholder: Images.personPlaceholder,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profileController.customerName(),
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).dialogBackgroundColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Row(children: [
                        Text(
                          "${'level'.tr} : ${profileController.profileModel?.data?.level?.name ?? '0'}",
                          style: textBold.copyWith(
                            color: Theme.of(context).dialogBackgroundColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ]),
                      Row(children: [
                        Text(
                          '${"your_rating".tr} :',
                          style: textBold.copyWith(
                            color: Theme.of(context).dialogBackgroundColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          profileController.profileModel!.data!.userRating ??
                              "0",
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            letterSpacing: 3,
                            color: Theme.of(context).dialogBackgroundColor,
                          ),
                        ),
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                      ]),
                    ],
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...item.map((item) => Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              item.inactiveIcon,
                              width: 24,
                              height: 24,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColor,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(item.screen);
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ),
          ListTile(
            leading:
                Icon(Icons.exit_to_app, color: Theme.of(context).primaryColor),
            title: const Text('Déconnexion', style: textMedium),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) {
                  return GetBuilder<AuthController>(builder: (authController) {
                    return ConfirmationDialogWidget(
                      icon: Images.profileLogout,
                      isLoading: authController.isLoading,
                      description: 'do_you_want_to_log_out_this_account'.tr,
                      onYesPressed: () {
                        Get.find<AuthController>().logOut();
                      },
                    );
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

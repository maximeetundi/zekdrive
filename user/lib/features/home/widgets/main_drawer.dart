import 'package:ride_sharing_user_app/util/colors.dart';
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
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Premium drawer header with gradient
          GetBuilder<ProfileController>(builder: (profileController) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF14B19E), Color(0xFF0E8F7E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: ImageWidget(
                        height: 72,
                        width: 72,
                        image: profileController.profileModel?.data?.profileImage != null
                            ? '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImage ?? ''}/${profileController.profileModel?.data?.profileImage ?? ''}'
                            : '',
                        placeholder: Images.personPlaceholder,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    profileController.customerName(),
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Level + Rating row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${'level'.tr}: ${profileController.profileModel?.data?.level?.name ?? '0'}",
                          style: textMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        profileController.profileModel?.data?.userRating ?? "0",
                        style: textMedium.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...item.map((navItem) => _DrawerItem(item: navItem)),
              ],
            ),
          ),

          // Logout button at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'logout'.tr,
                      style: textMedium.copyWith(
                        color: const Color(0xFFEF4444),
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final NavigationModel item;
  const _DrawerItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Get.to(item.screen);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kBrandTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    item.inactiveIcon,
                    width: 20,
                    height: 20,
                    color: kBrandTeal,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.name,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Theme.of(context).hintColor.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/address/screens/my_address.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_list.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_item.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/settings/screens/setting_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/support/support_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/util/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        if (profileController.profileModel == null ||
            profileController.profileModel!.data == null) {
          return const Center(child: CircularProgressIndicator(color: kBrandTeal));
        }

        final data = profileController.profileModel!.data!;
        final name = profileController.customerName();
        final rating = data.userRating ?? '5.0';
        final rides = data.totalRideCount ?? 0;
        final points = data.loyaltyPoints ?? 0;

        return CustomScrollView(
          slivers: [
            // ── SLIVER HEADER ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background gradient header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 32,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF14B19E), Color(0xFF0E8A7A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profil',
                              style: textBold.copyWith(fontSize: 20, color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(() => const EditProfileScreen()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text('Modifier', style: textMedium.copyWith(fontSize: 13, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Avatar + name
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: ImageWidget(
                                      height: 76,
                                      width: 76,
                                      image: data.profileImage != null
                                          ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/${data.profileImage}'
                                          : '',
                                      placeholder: Images.personPlaceholder,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: textBold.copyWith(fontSize: 20, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFBBF24)),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating,
                                        style: textMedium.copyWith(fontSize: 13, color: Colors.white),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Colors.white54,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        '${data.level?.name ?? 'Bronze'}',
                                        style: textMedium.copyWith(fontSize: 13, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _statItem('$rides', 'Courses', context),
                              _divider(),
                              _statItem('$points', 'Points', context),
                              _divider(),
                              _statItem(rating, 'Note', context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── MENU ITEMS ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // ── Account section
                    _sectionHeader('Mon Compte', context),
                    ProfileMenuItem(
                      title: 'profile',
                      icon: Images.profileProfile,
                      iconColor: kBrandTeal,
                      iconBgColor: kBrandTeal.withOpacity(0.10),
                      onTap: () => Get.to(() => const EditProfileScreen()),
                    ),
                    ProfileMenuItem(
                      title: 'my_wallet',
                      icon: Images.profileMyWallet,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.10),
                      onTap: () => Get.to(() => const WalletScreen()),
                    ),
                    ProfileMenuItem(
                      title: 'my_address',
                      icon: Images.location,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFEF4444).withOpacity(0.10),
                      onTap: () => Get.to(() => const MyAddressScreen()),
                    ),
                    ProfileMenuItem(
                      title: 'my_trips',
                      icon: Images.profileMyTrip,
                      iconColor: const Color(0xFF3B82F6),
                      iconBgColor: const Color(0xFF3B82F6).withOpacity(0.10),
                      onTap: () => Get.to(() => const TripScreen(fromProfile: true)),
                    ),

                    // ── Offers section
                    _sectionHeader('Offres & Promotions', context),
                    ProfileMenuItem(
                      title: 'my_offer',
                      icon: Images.paymentAndVoucher,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFF59E0B).withOpacity(0.10),
                      onTap: () => Get.to(() => MyOfferWidget()),
                    ),
                    ProfileMenuItem(
                      title: 'message',
                      icon: Images.profileMessage,
                      iconColor: const Color(0xFF10B981),
                      iconBgColor: const Color(0xFF10B981).withOpacity(0.10),
                      onTap: () => Get.to(() => const MessageListScreen()),
                    ),

                    // ── Support section
                    _sectionHeader('Support', context),
                    ProfileMenuItem(
                      title: 'help_support',
                      icon: Images.profileHelpSupport,
                      iconColor: const Color(0xFF6366F1),
                      iconBgColor: const Color(0xFF6366F1).withOpacity(0.10),
                      onTap: () => Get.to(() => const HelpAndSupportScreen()),
                    ),
                    ProfileMenuItem(
                      title: 'settings',
                      icon: Images.profileSetting,
                      iconColor: const Color(0xFF6B7280),
                      iconBgColor: const Color(0xFF6B7280).withOpacity(0.10),
                      onTap: () => Get.to(() => const SettingScreen()),
                    ),

                    // ── Legal section
                    _sectionHeader('Légal', context),
                    ProfileMenuItem(
                      title: 'privacy_policy',
                      icon: Images.privacyPolicyIcon,
                      iconColor: const Color(0xFF6B7280),
                      iconBgColor: const Color(0xFF6B7280).withOpacity(0.08),
                      onTap: () => Get.to(() => PolicyScreen(
                        isPolicy: true,
                        image: Get.find<ConfigController>().config?.privacyPolicy?.image ?? '',
                      )),
                    ),
                    ProfileMenuItem(
                      title: 'terms_and_condition',
                      icon: Images.termsAndCondition,
                      iconColor: const Color(0xFF6B7280),
                      iconBgColor: const Color(0xFF6B7280).withOpacity(0.08),
                      onTap: () => Get.to(() => PolicyScreen(
                        image: Get.find<ConfigController>().config?.termsAndConditions?.image ?? '',
                      )),
                    ),

                    const SizedBox(height: 16),

                    // ── Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: GetBuilder<AuthController>(builder: (authController) {
                        return OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: Text('Se déconnecter', style: textSemiBold.copyWith(fontSize: 15)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => GetBuilder<AuthController>(
                                builder: (ac) => ConfirmationDialogWidget(
                                  icon: Images.profileLogout,
                                  isLoading: ac.isLoading,
                                  description: 'do_you_want_to_log_out_this_account'.tr,
                                  onYesPressed: () => Get.find<AuthController>().logOut(),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    // ── Delete account
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => GetBuilder<AuthController>(
                              builder: (ac) => ConfirmationDialogWidget(
                                icon: Images.profileLogout,
                                isLoading: ac.isLoading,
                                description: 'are_you_sure_permanent_delete_smg'.tr,
                                onYesPressed: () => Get.find<AuthController>().permanentlyDelete(),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Supprimer mon compte',
                          style: textRegular.copyWith(fontSize: 13, color: Theme.of(context).hintColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _statItem(String value, String label, BuildContext context) {
    return Column(
      children: [
        Text(value, style: textBold.copyWith(fontSize: 20, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: textRegular.copyWith(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.3));

  Widget _sectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: textSemiBold.copyWith(
          fontSize: 11,
          letterSpacing: 1.2,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

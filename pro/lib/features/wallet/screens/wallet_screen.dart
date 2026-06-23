
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_menu_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/widgets/loyalty_point_list_widget.dart';
import 'package:ride_sharing_user_app/features/wallet/widgets/wallet_amount_type_card_widget.dart';
import 'package:ride_sharing_user_app/features/wallet/widgets/wallet_money_amount_widget.dart';
import 'package:ride_sharing_user_app/features/wallet/widgets/wallet_transaction_list_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/zoom_drawer_context_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/title_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/type_button_widget.dart';


class WalletScreenMenu extends GetView<ProfileController> {
  const WalletScreenMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (_) => ZoomDrawer(
        controller: _.zoomDrawerController,
        menuScreen: const ProfileMenuScreen(),
        mainScreen: const WalletScreen(),
        borderRadius: 24.0,
        angle: -5.0,
        isRtl: !Get.find<LocalizationController>().isLtr,
        menuBackgroundColor: Theme.of(context).primaryColor,
        slideWidth: MediaQuery.of(context).size.width * 0.85,
        mainScreenScale: .4,
      ),
    );
  }
}




class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<WalletController>().getTransactionList(1);
    Get.find<ProfileController>().getProfileInfo();
    Get.find<WalletController>().getLoyaltyPointList(1);
    Get.find<WalletController>().getWithdrawMethods();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Stack( children: [
        Scaffold(
          resizeToAvoidBottomInset: false,

          body: CustomScrollView(
            controller: scrollController, slivers: [

            SliverAppBar(
              pinned: true,
              elevation: 0,
              centerTitle: false,
              toolbarHeight: 90,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).highlightColor,
                flexibleSpace: GetBuilder<WalletController>(
                builder: (walletController) {
                  return AppBarWidget(title: 'my_wallet'.tr, showBackButton: false, onTap: (){
                    Get.find<ProfileController>().toggleDrawer();});
                }
              )
            ),

            SliverToBoxAdapter(child: GetBuilder<WalletController>(
                builder: (walletController) {
                  return Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault,),
                    TitleWidget(title: walletController.walletTypeIndex == 0?
                    'wallet_money'.tr :'account_point'.tr,
                      color: Theme.of(context).textTheme.bodyMedium!.color,),
                    const WalletMoneyAmountWidget(),

                    GetBuilder<ProfileController>(
                        builder: (profileController) {
                          return Padding(
                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                            child: SizedBox(height: 165,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: [

                                  WalletAmountTypeCardWidget(icon: Images.withdrawableAmount,
                                      amount: profileController.profileInfo?.wallet?.receivableBalance??0, title: 'withdrawable_amount'.tr),

                                  WalletAmountTypeCardWidget(icon: Images.pendingWithdrawn,
                                      amount: profileController.profileInfo?.wallet?.pendingBalance??0, title: 'pending_withdrawn'.tr),

                                  WalletAmountTypeCardWidget(icon: Images.alreadyWithdrawn,
                                      amount: profileController.profileInfo?.wallet?.totalWithdrawn??0, title: 'already_withdrawn'.tr),

                                  WalletAmountTypeCardWidget(icon: Images.totalEarning,
                                      amount: profileController.profileInfo?.wallet?.payableBalance??0, title: 'payable_amount'.tr),

                                  if(profileController.profileInfo != null && profileController.profileInfo!.wallet != null)
                                    WalletAmountTypeCardWidget(icon: Images.totalEarning,
                                        amount:  profileController.profileInfo!.wallet!.receivedBalance! + profileController.profileInfo!.wallet!.totalWithdrawn!, title: 'total_earning'.tr),

                                ],),
                            ),
                          );
                        }
                    ),
                  ],);
                }
            ),),
            SliverToBoxAdapter(child: GetBuilder<WalletController>(
                builder: (walletController) {
                  return Column(children: [

                    Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Row(children: [
                        Text(walletController.walletTypeIndex == 0?
                        'transaction_history'.tr:
                        'point_gained_history'.tr,
                          style: textBold.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: Dimensions.fontSizeExtraLarge),),


                      ],),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    if(walletController.walletTypeIndex == 1)
                      LoyaltyPointTransactionListWidget(walletController: walletController),

                    if(walletController.walletTypeIndex == 0)
                      WalletTransactionListWidget(walletController: walletController, scrollController: scrollController),




                  ],);
                }
            ),)
          ],),
        ),
      Positioned(top: 90,
        child: GetBuilder<WalletController>(
          builder: (walletController) {
            return Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              child: SizedBox(height: Get.find<LocalizationController>().isLtr? 45 : 50,
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: walletController.walletTypeList.length,
                    itemBuilder: (context, index){
                      return SizedBox(width: Get.width/2.1,
                        child: TypeButtonWidget(
                          index: index,name: walletController.walletTypeList[index],selectedIndex: walletController.walletTypeIndex,
                          onTap: ()=> walletController.setWalletTypeIndex(index),
                        ),
                      );
                    }),
              ),
            );
          }
        ),
      ),
      ],
    );
  }
}



class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverDelegate({required this.child, this.height = 70});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
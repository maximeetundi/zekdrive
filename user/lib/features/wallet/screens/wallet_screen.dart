import 'package:ride_sharing_user_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/loyality_point_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/wallet_money_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    Get.find<WalletController>().getTransactionList(1);
    Get.find<WalletController>().getLoyaltyPointList(1);
    Get.find<ProfileController>().getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kBrandTeal,
      onRefresh: () async {
        Get.find<ProfileController>().getProfileInfo();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BodyWidget(
          appBar: AppBarWidget(title: 'wallet'.tr, centerTitle: true),
          body: GetBuilder<WalletController>(builder: (walletController) {
            return Column(children: [
              // Premium tab bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Theme.of(context).hintColor,
                  labelStyle: textSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                  unselectedLabelStyle: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                  indicator: BoxDecoration(
                    gradient: kBrandGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  tabs: [
                    SizedBox(height: 38, child: Tab(text: 'wallet_money'.tr)),
                    SizedBox(height: 38, child: Tab(text: 'loyalty_point'.tr)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: const [
                    WalletMoneyScreen(),
                    LoyaltyPointScreen(),
                  ],
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }
}

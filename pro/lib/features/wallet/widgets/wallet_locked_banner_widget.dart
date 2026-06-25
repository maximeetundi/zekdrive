import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Bannière rouge affichée sur le home screen quand le wallet pro est verrouillé
/// ou quand le solde est insuffisant pour accepter des missions en espèces.
class WalletLockedBannerWidget extends StatelessWidget {
  const WalletLockedBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      builder: (walletController) {
        final bool showBanner = walletController.driverWallet != null &&
            !walletController.canAcceptRide;

        if (!showBanner) return const SizedBox.shrink();

        final bool isLocked = walletController.isLocked;

        return GestureDetector(
          onTap: () {
            // Naviguer vers le wallet pour recharger
            // Utiliser la navigation de l'app (dashboard bottom nav index 2 = wallet)
            Get.toNamed('/wallet');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSeven,
            ),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFFB71C1C)
                  : const Color(0xFFE65100),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_outline : Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLocked
                            ? 'wallet_locked'.tr
                            : 'insufficient_wallet_balance'.tr,
                        style: textSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      Text(
                        isLocked
                            ? 'wallet_locked_description'.tr
                            : 'recharge_to_accept_cash_rides'.tr,
                        style: textRegular.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeTiny,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    'recharge'.tr,
                    style: textSemiBold.copyWith(
                      color: isLocked ? const Color(0xFFB71C1C) : const Color(0xFFE65100),
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';

class WalletAmountTypeCardWidget extends StatelessWidget {
  final String icon;
  final double amount;
  final String title;
  const WalletAmountTypeCardWidget({super.key, required this.icon, required this.amount, required this.title});

  @override
  Widget build(BuildContext context) {
    bool inRight = Get.find<SplashController>().config!.currencySymbolPosition == 'right';
    String symbol = Get.find<SplashController>().config!.currencySymbol?? '\$';
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall),
      child: Container(width: 210, padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: .125),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        color: Theme.of(context).primaryColor.withOpacity(.08)
      ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 40,child: Image.asset(icon)),
          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end,children: [
                if(!inRight) Text(symbol, style: textMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                Text(amount.toString(), style: textMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                if(inRight) Text(symbol, style: textMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
              ],
            ),
          ),
          Text(title, style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ],),),
    );
  }
}

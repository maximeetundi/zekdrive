import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/setting/controllers/setting_controller.dart';
import 'package:ride_sharing_user_app/features/setting/widgets/theme_change_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: 'setting'.tr, regularAppbar: true,),
      body: GetBuilder<SettingController>(
        builder: (settingController) {
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSize),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(Images.languageIcon,scale: 2,),
                      const SizedBox(width: Dimensions.paddingSizeLarge,),
                      Text('language'.tr,
                        style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge),),
                    ],
                  ),
                  DropdownButton<String>(
                    isDense: true,
                    style: textMedium.copyWith(color: Theme.of(context).primaryColor),
                    value:Get.locale!.languageCode == 'en' ? 'English':'عربي',
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_sharp),

                    elevation: 1,
                    selectedItemBuilder: (_) {
                      return <String>['English','عربي'].map<Widget>((String item) {
                        return Center(
                          child: Text(item,style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),),
                        );
                      }).toList();
                    },

                    items: [
                      DropdownMenuItem<String>(
                        value: 'English',
                        child: Text('English',style: textRegular.copyWith(color:
                        Get.locale!.languageCode == 'en' ?
                        Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color),),
                      ),

                      DropdownMenuItem<String>(
                        value: 'عربي',
                        child: Text('عربي',style: textRegular.copyWith(color:
                        Get.locale!.languageCode == 'ar' ?
                        Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color),),
                      ),
                    ],

                    onChanged: (String? newValue) {
                      if(newValue == 'English'){
                        Get.find<LocalizationController>().setLanguage(const Locale( 'en','US'));
                      }else{
                        Get.find<LocalizationController>().setLanguage(const Locale( 'ar', 'SA'));
                      }
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding:  const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,Dimensions.paddingSizeDefault),
              child: Row(children: [
                SizedBox(width: Dimensions.iconSizeMedium,
                    child: Image.asset(Images.themeIcon)),
                SizedBox(width: Get.find<LocalizationController>().isLtr? 0: Dimensions.paddingSizeSmall),
                Padding(
                  padding:  const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  child: Text('theme'.tr),
                )
              ],),
            ),

            const ThemeChangeWidget(),

          ],);
        }
      ),
    );
  }
}

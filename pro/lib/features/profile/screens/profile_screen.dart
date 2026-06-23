import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/reset_password_screen.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_item_widget.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_type_button_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';


class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ProfileController>(
        builder: (profileController) {

          return Stack(children: [
              Column(children: [
                  AppBarWidget(title: 'profile'.tr, showBackButton: true, onTap: () => Get.find<ProfileController>().toggleDrawer()),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                  Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,0),
                      child: SingleChildScrollView(
                        child: Column(children:  [
                          Container(
                              decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).hintColor.withOpacity(.25),width: .5),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                            child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                              child:  ImageWidget(
                              width: 80,height: 80,
                              image: profileController.profileTypeIndex == 0?
                              '${Get.find<SplashController>().config!.imageBaseUrl!.profileImage}/${profileController.profileInfo!.profileImage!}':
                              profileController.profileInfo!.vehicle != null?'${Get.find<SplashController>().config!.imageBaseUrl!.vehicleModel}/'
                                  '${profileController.profileInfo!.vehicle!.model!.image}' : ''))),



                          const SizedBox(height : Dimensions.paddingSizeDefault),
                          InkWell(highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: ()=> Get.to(()=>  ProfileEditScreen(profileInfo: profileController.profileInfo!)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('${profileController.profileInfo!.firstName!}  ${profileController.profileInfo!.lastName!}',
                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                  style: textBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                if(profileController.profileTypeIndex == 0)
                                SizedBox(width: Dimensions.iconSizeMedium, child: Image.asset(Images.editIcon)),
                                const SizedBox(width: Dimensions.paddingSizeSmall)])),


                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('${'your_ratting'.tr} : ${profileController.profileInfo!.avgRatting.toString()} '),
                              const Icon(Icons.star_rounded, color: Colors.orange,size: Dimensions.iconSizeSmall)],),
                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          profileController.profileTypeIndex == 0?
                          Column(children:  [

                             ProfileItemWidget(title: 'my_level',value: profileController.profileInfo?.level?.name??'',isLevel: true,),
                             ProfileItemWidget(title: 'contact',value:Get.find<LocalizationController>().isLtr ? profileController.profileInfo!.phone! : '${profileController.profileInfo!.phone!.substring(1)}+'),
                             ProfileItemWidget(title: 'mail_address',value: profileController.profileInfo!.email!),
                             ProfileItemWidget(title: 'registration_type',value: profileController.profileInfo!.identificationType!.tr),
                             ProfileItemWidget(title: 'registration_number',value: profileController.profileInfo!.identificationNumber!),
                          ],):


                          profileController.profileInfo!.vehicle != null ?
                          Column(children:  [
                            ProfileItemWidget(title: 'vehicle', value: profileController.profileInfo!.vehicle!.category!.type!.tr),
                            ProfileItemWidget(title: 'vehicle_brand', value: profileController.profileInfo!.vehicle!.brand!.name!),
                            ProfileItemWidget(title: 'vehicle_model', value: profileController.profileInfo!.vehicle!.model!.name!),
                           // ProfileItemWidget(title: 'vin', value: profileController.profileInfo!.vehicle!.vinNumber!),
                            ProfileItemWidget(title: 'number_plate', value: profileController.profileInfo!.vehicle!.licencePlateNumber!)]):
                          const SizedBox(),

                          profileController.profileTypeIndex == 0?
                          Container(decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).hintColor)),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: GestureDetector(
                              onTap: ()=>  Get.to(()=>const ResetPasswordScreen(phoneNumber: '',fromChangePassword: true)),
                              child: Row(children: [
                                SizedBox(width: Dimensions.iconSizeMedium, child: Image.asset(Images.changePasswordIcon)),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text('change_password'.tr,style: textRegular.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeDefault),)
                              ],),
                            )):
                          const SizedBox(),

                          const SizedBox(height: Dimensions.paddingSizeDefault,),
                          profileController.profileInfo!.isOldIdentificationImage! ?
                          Row(children: [
                            const SizedBox(width: Dimensions.iconSizeMedium, child: Icon(Icons.error)),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text('identity_info_is_pending_for_approval'.tr,style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault),)
                          ],) : const SizedBox(),
                        ],))))


                ],
              ),
              Positioned( top: Dimensions.topSpace,left: Dimensions.paddingSizeSmall,
                child: SizedBox(height: Get.find<LocalizationController>().isLtr? 45 : 50,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: profileController.profileType.length,
                      itemBuilder: (context, index){
                        return SizedBox(width: Get.width/2.1,
                            child: ProfileTypeButtonWidget(profileTypeName : profileController.profileType[index], index: index));
                      }),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}




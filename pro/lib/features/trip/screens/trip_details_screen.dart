import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/map/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/sub_total_header.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/payment_item_info_widget.dart';

class TripDetails extends StatefulWidget {
  final String tripId;
  const TripDetails({super.key, required this.tripId});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {

  @override
  void initState() {
    Get.find<RideController>().getRideDetails(widget.tripId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<RideController>(
        builder: (rideController) {


          String firstRoute = '';
          String secondRoute = '';
          double finalPrice = 0;
          Duration? tripDuration;
          if(rideController.tripDetail != null){
             finalPrice = double.parse(rideController.tripDetail!.paidFare!);
            if(rideController.tripDetail!.actualTime != null){
              tripDuration =  Duration(minutes: rideController.tripDetail!.actualTime!.ceil());
            }

            List<dynamic> extraRoute = [];
            if(rideController.tripDetail!.intermediateAddresses != null && rideController.tripDetail!.intermediateAddresses != '[[, ]]'){
              extraRoute = jsonDecode(rideController.tripDetail!.intermediateAddresses!);

              if(extraRoute.isNotEmpty){
                firstRoute = extraRoute[0];
              }
              if(extraRoute.isNotEmpty && extraRoute.length>1){
                secondRoute = extraRoute[1];
              }}}


          return rideController.tripDetail != null?
          SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              AppBarWidget(title: 'trip_details'.tr),
              SubTotalHeaderTitle(title: '${'your_trip'.tr} #${rideController.tripDetail!.refId} ${'is'.tr} ${rideController.tripDetail!.currentStatus!.tr}',
                color: Theme.of(context).primaryColor,tripId: widget.tripId,isReviewed: rideController.tripDetail!.isReviewed,
                paymentStatus: rideController.tripDetail!.paymentStatus, type: rideController.tripDetail!.type,
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                  if(rideController.tripDetail!.actualTime != null)
                  SummeryItem(title: '${tripDuration!.inHours}:${tripDuration.inMinutes % 60} hr',subTitle: 'time'.tr,),
                  SummeryItem(title: '${rideController.tripDetail!.actualDistance} km',subTitle: 'distance'.tr,),

                ],),
              ),


              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Text('trip_details'.tr),),
               Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: RouteWidget(pickupAddress: rideController.tripDetail!.pickupAddress!,
                    destinationAddress: rideController.tripDetail!.destinationAddress!,
                  extraOne: firstRoute,extraTwo: secondRoute,entrance: rideController.tripDetail!.entrance,
                ),),

              Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: .5),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('payment_details'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor),),
                          Text(rideController.tripDetail!.paymentMethod!.replaceAll('_', ' ').capitalize!, style: textSemiBold.copyWith(color: Theme.of(context).primaryColor),),
                        ],
                      ),
                    ),

                    PaymentItemInfoWidget(icon: Images.farePrice,title: 'fare_price'.tr,amount: rideController.tripDetail!.distanceWiseFare??0),
                    PaymentItemInfoWidget(icon: Images.idleHourIcon,title: 'idle_price'.tr,amount: rideController.tripDetail!.idleFee??0),
                    PaymentItemInfoWidget(icon: Images.waitingPrice,title: 'delay_price'.tr,amount: rideController.tripDetail!.delayFee??0),
                    PaymentItemInfoWidget(icon: Images.idleHourIcon,title: 'cancellation_price'.tr,amount: rideController.tripDetail!.cancellationFee??0),
                    PaymentItemInfoWidget(icon: Images.coupon, title: 'discount_amount'.tr, amount: rideController.tripDetail!.discountAmount??0, discount: true,
                    toolTipText: 'discount_applied_for_this_ride'.tr,subTitle: 'later_admin_will_pay_you_this_amount',),
                    PaymentItemInfoWidget(icon: Images.coupon, title: 'coupon_amount'.tr, amount: rideController.tripDetail!.couponAmount??0, discount: true,
                      toolTipText: 'customer_applied_coupon_for_this_ride'.tr,
                      subTitle: 'later_admin_will_pay_you_this_amount', ),
                    PaymentItemInfoWidget(icon: Images.farePrice,title: 'tips'.tr,amount: rideController.tripDetail!.tips??0),
                    PaymentItemInfoWidget(icon: Images.farePrice,title: 'vat_tax'.tr,amount: rideController.tripDetail!.vatTax??0),
                    PaymentItemInfoWidget(title: 'sub_total'.tr,amount: finalPrice, isSubTotal: true,),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('payment_status'.tr,style: textSemiBold.copyWith(color: Theme.of(context).primaryColor),),
                        Text(rideController.tripDetail!.paymentStatus!.replaceAll('_', ' ').capitalize!, style: textSemiBold.copyWith(color: Theme.of(context).primaryColor),),

                      ]))]))),

              if(rideController.tripDetail!.paymentStatus == 'unpaid' && rideController.tripDetail!.paidFare != '0')
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall,bottom: Dimensions.paddingSizeLarge),
                child: ButtonWidget(buttonText: 'request_for_payment'.tr, onPressed: (){
                  Get.find<RideController>().getFinalFare(rideController.tripDetail!.id!).then((value){if(value.statusCode == 200){
                    Get.to(()=> const PaymentReceivedScreen());
                  }});
                },),
              ),

             /* const SizedBox(height: Dimensions.paddingSizeDefault,),
              if(rideController.tripDetail!.type == 'parcel')
              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Center(
                    child: SliderButton(
                      action: () {
                        Get.dialog(Dialog(child: Container(
                            decoration: BoxDecoration(color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              InkWell(onTap: ()=> Get.back(),
                                child: Align( alignment: Alignment.topRight,
                                    child: Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall,right: Dimensions.paddingSizeExtraSmall),
                                        child: Image.asset(Images.cancelIcon,height: 24,width: 24,))),
                              ),

                               Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                                 child: Text('enter_cancellation_otp'.tr,style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault ))),

                               Text('collect_the_otp_from_customer'.tr,style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault )),

                              Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                 child: Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(50,Dimensions.paddingSizeDefault,50,Dimensions.paddingSizeDefault,),
                                     child: PinCodeTextField(
                                        length: 4,
                                        appContext: context,
                                        obscureText: false,
                                        showCursor: true,
                                        keyboardType: TextInputType.number,
                                        animationType: AnimationType.fade,
                                        pinTheme: PinTheme(
                                            shape: PinCodeFieldShape.box,
                                            fieldHeight: 40,
                                            fieldWidth: 40,
                                            borderWidth: 1,
                                            borderRadius: BorderRadius.circular(10),
                                            selectedColor: Theme.of(context).primaryColor,
                                            selectedFillColor: Theme.of(context).primaryColor.withOpacity(.25),
                                            inactiveFillColor: Theme.of(context).disabledColor.withOpacity(.125),
                                            inactiveColor: Theme.of(context).disabledColor.withOpacity(.125),
                                            activeColor: Theme.of(context).primaryColor.withOpacity(.123),
                                            activeFillColor: Theme.of(context).primaryColor.withOpacity(.125)),
                                        animationDuration: const Duration(milliseconds: 300),
                                        backgroundColor: Colors.transparent,
                                        enableActiveFill: true,
                                        onChanged: rideController.updateVerificationCode,
                                        beforeTextPaste: (text) {
                                          return true;}))),
                              ),

                              Padding(padding: EdgeInsets.only(bottom: 20,left: Get.width*0.2,right: Get.width*0.2),
                                child: InkWell(onTap: () async {
                                  if(rideController.verificationCode.length == 4){

                                   // rideController.matchOtp(rideController.tripDetail!.id!, rideController.verificationCode);

                                  }else{
                                    showCustomSnackBar("pin_code_is_required".tr);}},
                                    child: rideController.isLoading ?  const SizedBox(width: 30,height: 30,child: CircularProgressIndicator()):

                                    ButtonWidget(buttonText: 'submit'.tr,backgroundColor: Theme.of(context).primaryColor,)
                                ),
                              )
                            ]))),
                        barrierDismissible: false);
                      },
                      label: Text('parcel_returned'.tr, style: TextStyle(color: Theme.of(context).cardColor)),
                      dismissThresholds: 0.5,dismissible: false, shimmer: false,width: 1170, height: 40, buttonSize: 40, radius: 20,
                      icon: Center(
                          child: Container(width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                            child: Center(child: Icon(
                                Get.find<LocalizationController>().isLtr ? Icons.arrow_forward_ios_rounded : Icons.keyboard_arrow_left,
                                color: Colors.grey, size: 20.0),
                            ),
                          )),
                      isLtr: Get.find<LocalizationController>().isLtr,
                      boxShadow: const BoxShadow(blurRadius: 0),
                      buttonColor: Colors.transparent,
                      backgroundColor: Theme.of(context).primaryColor,
                      baseColor: Theme.of(context).primaryColor,
                    )),
              )*/

            ],),
          ): const LoaderWidget();
        }
      ),
    );
  }
}

class SummeryItem extends StatelessWidget {
  final String title;
  final String subTitle;
  const SummeryItem({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Icon(Icons.check_circle,size: Dimensions.iconSizeSmall, color: Colors.green),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Text(title, style: textMedium.copyWith(color: Theme.of(context).primaryColor)),
      ),
      Text(subTitle, style: textRegular.copyWith(color: Theme.of(context).hintColor)),

    ],);
  }
}



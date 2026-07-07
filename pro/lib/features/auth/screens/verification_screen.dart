import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String number;
  final String? from;
  final String countryCode;
  const VerificationScreen({super.key, required this.number, this.from, required this.countryCode});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  TextEditingController pinController = TextEditingController();
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<SplashController>().config!.otpResendTime!;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Get.isDarkMode;
    int minutes = (_seconds! / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (_seconds! % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBarWidget(title: 'otp_verification'.tr, showBackButton: true, regularAppbar: true),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Illustration avec halo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: primary.withOpacity(0.15), blurRadius: 32, spreadRadius: 4),
                    ],
                  ),
                  child: Image.asset(Images.verification, width: 110),
                ),
                const SizedBox(height: 20),

                Text(
                  'enter_verification_code'.tr,
                  style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.countryCode + widget.number,
                  style: textMedium.copyWith(color: Theme.of(context).hintColor),
                ),

                (Get.find<SplashController>().config?.isDemo ?? true)
                    ? Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(bottom: Dimensions.paddingSizeOver),
                        child: Text('for_demo_purpose_use'.tr,
                            style: textSemiBold.copyWith(color: Theme.of(context).disabledColor)),
                      )
                    : const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // ── OTP SQUARES ───────────────────────────────────
                PinCodeTextField(
                  length: 6,
                  appContext: context,
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.slide,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    fieldHeight: 52,
                    fieldWidth: 42,
                    borderWidth: 1.5,
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: primary,
                    selectedFillColor: isDark
                        ? primary.withOpacity(0.15)
                        : primary.withOpacity(0.06),
                    activeColor: primary.withOpacity(0.6),
                    activeFillColor: isDark
                        ? primary.withOpacity(0.12)
                        : primary.withOpacity(0.04),
                    inactiveColor: Theme.of(context).dividerColor,
                    inactiveFillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.06),
                  ),
                  animationDuration: const Duration(milliseconds: 250),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onChanged: authController.updateVerificationCode,
                  beforeTextPaste: (text) => true,
                  textStyle: textSemiBold.copyWith(fontSize: 20),
                  pastedTextStyle: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                // ─────────────────────────────────────────────────

                const SizedBox(height: 16),

                // Resend timer / button
                if (_seconds! <= 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'did_not_receive_the_code'.tr,
                        style: textMedium.copyWith(color: Theme.of(context).hintColor),
                      ),
                      TextButton(
                        onPressed: () {
                          authController.sendOtp(countryCode: widget.countryCode, phone: widget.number).then((value) {
                            if (value.statusCode == 200) _startTimer();
                          });
                        },
                        child: Text('resend_it'.tr, style: textSemiBold.copyWith(color: primary)),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).hintColor),
                      const SizedBox(width: 4),
                      Text(
                        '${'resend_it'.tr} ${'after'.tr} $minutesStr:$secondsStr ${'sec'.tr}',
                        style: textMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ],
                  ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Bouton vérifier
                if (!authController.isLoading)
                  if (authController.verificationCode.length == 6)
                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      child: ButtonWidget(
                        buttonText: 'send'.tr,
                        radius: 50,
                        onPressed: () => authController
                            .otpVerification(
                              widget.countryCode,
                              widget.number,
                              authController.verificationCode,
                              from: widget.from!,
                            )
                            .then((value) {
                          if (value.statusCode == 200) pinController.clear();
                        }),
                      ),
                    )
                  else
                    const SizedBox.shrink()
                else
                  Center(child: SpinKitCircle(color: primary, size: 40.0)),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            );
          }),
        ),
      ),
    );
  }
}

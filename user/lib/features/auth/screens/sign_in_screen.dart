import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/otp_log_in_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

const _kTeal = Color(0xFF14B19E);

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  bool _isWhatsAppPhone = true;

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().getUserNumber().isNotEmpty) {
      phoneController.text = Get.find<AuthController>().getUserNumber();
      if (phoneController.text.contains('@')) _isWhatsAppPhone = false;
    }
    passwordController.text = Get.find<AuthController>().getUserPassword();
    if (passwordController.text.isNotEmpty) Get.find<AuthController>().setRememberMe();

    final savedCode = Get.find<AuthController>().getLoginCountryCode();
    if (savedCode.isNotEmpty && savedCode != '+33' && savedCode != '+880') {
      Get.find<AuthController>().countryDialCode = savedCode;
    } else {
      Get.find<AuthController>().countryDialCode = '+237';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFB),
      body: GetBuilder<AuthController>(builder: (authController) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HEADER ──────────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _kTeal.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(Images.logoWithName, fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppConstants.appName,
                            style: textBold.copyWith(
                              fontSize: 28,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Votre chauffeur en quelques secondes 🚗',
                            style: textRegular.copyWith(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    // ── TITLE ────────────────────────────────────────────────
                    Text(
                      'Connexion',
                      style: textBold.copyWith(
                        fontSize: 26,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entrez votre numéro pour continuer',
                      style: textRegular.copyWith(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── MODE SELECTOR ────────────────────────────────────────
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C2333) : const Color(0xFFEFF0F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _modeTab(
                            label: 'WhatsApp',
                            icon: Icons.phone_android_rounded,
                            isActive: _isWhatsAppPhone,
                            onTap: () => setState(() {
                              _isWhatsAppPhone = true;
                              phoneController.clear();
                            }),
                          ),
                          _modeTab(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            isActive: !_isWhatsAppPhone,
                            onTap: () => setState(() {
                              _isWhatsAppPhone = false;
                              phoneController.clear();
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── INPUT FIELDS ─────────────────────────────────────────
                    if (_isWhatsAppPhone)
                      CustomTextField(
                        hintText: 'Numéro WhatsApp',
                        inputType: TextInputType.phone,
                        countryDialCode: authController.countryDialCode,
                        prefixHeight: 70,
                        controller: phoneController,
                        focusNode: phoneNode,
                        nextFocus: passwordNode,
                        inputAction: TextInputAction.done,
                        onCountryChanged: (CountryCode countryCode) {
                          authController.countryDialCode = countryCode.dialCode!;
                          authController.setCountryCode(countryCode.dialCode!);
                        },
                      )
                    else ...[
                      CustomTextField(
                        hintText: 'email'.tr,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Images.email,
                        prefixHeight: 70,
                        controller: phoneController,
                        focusNode: phoneNode,
                        nextFocus: passwordNode,
                        inputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: 'Mot de passe',
                        inputType: TextInputType.text,
                        prefixIcon: Images.lock,
                        prefixHeight: 70,
                        inputAction: TextInputAction.done,
                        isPassword: true,
                        controller: passwordController,
                        focusNode: passwordNode,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                activeColor: _kTeal,
                                value: authController.isActiveRememberMe,
                                onChanged: (v) => authController.toggleRememberMe(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Se souvenir', style: textRegular.copyWith(fontSize: 13)),
                          ]),
                          TextButton(
                            onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                            child: Text(
                              'Mot de passe oublié ?',
                              style: textMedium.copyWith(fontSize: 13, color: _kTeal),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── PRIMARY BUTTON ───────────────────────────────────────
                    authController.isLoading
                        ? Center(child: SpinKitCircle(color: _kTeal, size: 42))
                        : ButtonWidget(
                            buttonText: _isWhatsAppPhone
                                ? 'Continuer avec WhatsApp'
                                : 'Se connecter',
                            height: 54,
                            radius: 14,
                            onPressed: () {
                              final input = phoneController.text.trim();
                              final password = passwordController.text.trim();

                              if (_isWhatsAppPhone) {
                                if (input.isEmpty) {
                                  showCustomSnackBar('enter_your_phone_number'.tr);
                                } else {
                                  authController.sendOtp(authController.countryDialCode + input).then((value) {
                                    if (value.statusCode == 200) {
                                      Get.to(() => VerificationScreen(
                                        number: authController.countryDialCode + input,
                                        fromOtpLogin: true,
                                      ));
                                    }
                                  });
                                }
                              } else {
                                if (!GetUtils.isEmail(input)) {
                                  showCustomSnackBar('email_is_not_valid'.tr);
                                } else if (password.isEmpty) {
                                  showCustomSnackBar('password_is_required'.tr);
                                } else if (password.length < 8) {
                                  showCustomSnackBar('minimum_password_length_is_8'.tr);
                                } else {
                                  authController.login('', input, password);
                                }
                              }
                            },
                          ),

                    const SizedBox(height: 16),

                    // ── OR DIVIDER ───────────────────────────────────────────
                    Row(children: [
                      Expanded(child: Divider(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ou', style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: 13)),
                      ),
                      Expanded(child: Divider(color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB))),
                    ]),

                    const SizedBox(height: 16),

                    // ── OTP LOGIN ────────────────────────────────────────────
                    ButtonWidget(
                      showBorder: true,
                      transparent: true,
                      buttonText: 'otp_login'.tr,
                      height: 52,
                      radius: 14,
                      onPressed: () => Get.to(() => const OtpLoginScreen(fromSignIn: true)),
                    ),

                    const SizedBox(height: 28),

                    // ── SIGN UP LINK ─────────────────────────────────────────
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pas encore de compte ? ',
                            style: textRegular.copyWith(
                              fontSize: 14,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.to(() => const SignUpScreen()),
                            child: Text(
                              "S'inscrire",
                              style: textSemiBold.copyWith(fontSize: 14, color: _kTeal),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── TERMS ────────────────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.to(() => const PolicyScreen()),
                        child: Text(
                          'Conditions d\'utilisation',
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _modeTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          decoration: BoxDecoration(
            color: isActive ? _kTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isActive ? Colors.white : Theme.of(context).hintColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: textSemiBold.copyWith(
                  fontSize: 13,
                  color: isActive ? Colors.white : Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

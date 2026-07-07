import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/util/colors.dart';

class ButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets margin;
  final double height;
  final double width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final bool boldText;
  final bool isLoading;

  const ButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin = EdgeInsets.zero,
    this.width = Dimensions.webMaxWidth,
    this.height = 52,
    this.fontSize,
    this.radius = 14,
    this.icon,
    this.showBorder = false,
    this.borderWidth = 1.5,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.boldText = true,
    this.isLoading = false,
  });

  static DateTime? _lastClickTime;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final Color effectiveBg = backgroundColor ??
        (isDisabled
            ? Theme.of(context).disabledColor
            : transparent
                ? Colors.transparent
                : kBrandTeal);

    return Center(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: margin,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: (!transparent && !isDisabled && !showBorder)
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF14B19E), Color(0xFF0E8A7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandTeal.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  )
                : null,
            child: TextButton(
              onPressed: isDisabled
                  ? null
                  : () {
                      final now = DateTime.now();
                      if (_lastClickTime == null ||
                          now.difference(_lastClickTime!) >
                              const Duration(milliseconds: 1000)) {
                        _lastClickTime = now;
                        onPressed!();
                      }
                    },
              style: TextButton.styleFrom(
                backgroundColor: (!transparent && !showBorder) ? Colors.transparent : effectiveBg,
                minimumSize: Size(width, height),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                  side: showBorder
                      ? BorderSide(
                          color: borderColor ?? kBrandTeal,
                          width: borderWidth,
                        )
                      : BorderSide.none,
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: transparent ? kBrandTeal : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          style: boldText
                              ? textSemiBold.copyWith(
                                  color: textColor ??
                                      (transparent
                                          ? kBrandTeal
                                          : isDisabled
                                              ? Colors.white54
                                              : Colors.white),
                                  fontSize: fontSize ?? Dimensions.fontSizeLarge,
                                  letterSpacing: 0.3,
                                )
                              : textRegular.copyWith(
                                  color: textColor ??
                                      (transparent ? kBrandTeal : Colors.white),
                                  fontSize: fontSize ?? Dimensions.fontSizeLarge,
                                ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

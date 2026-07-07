import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/util/colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final String icon;
  final Function()? onTap;
  final bool divider;
  final Color? iconColor;
  final Color? iconBgColor;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.divider = true,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? kBrandTeal;
    final Color effectiveIconBg = iconBgColor ?? kBrandTeal.withOpacity(0.10);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: kBrandTeal.withOpacity(0.06),
            highlightColor: kBrandTeal.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: 13,
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        icon,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        color: effectiveIconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Text(
                      title.tr,
                      style: textMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Theme.of(context).hintColor.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (divider)
          Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1,
            indent: Dimensions.paddingSizeLarge + 42 + Dimensions.paddingSizeDefault,
            endIndent: 0,
            height: 1,
          ),
      ],
    );
  }
}

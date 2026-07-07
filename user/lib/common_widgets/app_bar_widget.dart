import 'package:ride_sharing_user_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool isHome;
  final String? subTitle;
  final Widget? drawer;

  const AppBarWidget({
    super.key,
    required this.title,
    this.subTitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.showActionButton = true,
    this.isHome = false,
    this.drawer,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: kBrandTeal,
          boxShadow: [
            BoxShadow(
              color: kBrandTeal.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: isHome || subTitle != null ? 74 : 56,
            child: Row(
              children: [
                // Leading
                if (showBackButton)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          onBackPressed != null ? onBackPressed!() : Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  )
                else
                  Builder(
                    builder: (ctx) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Title
                Expanded(
                  child: InkWell(
                    onTap: isHome
                        ? () => Get.to(() => const AccessLocationScreen())
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: centerTitle
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.tr,
                            style: textSemiBold.copyWith(
                              fontSize: fontSize ?? 17,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subTitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${'trip'.tr} #$subTitle',
                              style: textMedium.copyWith(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.to(() => const HomeScreen()),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(
        Dimensions.webMaxWidth,
        isHome || subTitle != null ? 90.0 : 56.0,
      );
}

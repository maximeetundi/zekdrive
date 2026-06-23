import 'package:flutter/material.dart';
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
      preferredSize: const Size.fromHeight(150.0),
      child: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap:
              isHome ? () => Get.to(() => const AccessLocationScreen()) : null,
          child: Padding(
            padding:
                const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.tr,
                    style: textRegular.copyWith(
                        fontSize: fontSize ?? Dimensions.fontSizeLarge,
                        fontWeight:
                            isHome ? FontWeight.bold : FontWeight.normal,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis),
                subTitle != null
                    ? Text('${'trip'.tr} #$subTitle',
                        style: textRegular.copyWith(
                            fontSize: fontSize ??
                                (isHome
                                    ? Dimensions.fontSizeExtraLarge
                                    : Dimensions.fontSizeExtraLarge),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis)
                    : const SizedBox(),
                const SizedBox.shrink()
              ],
            ),
          ),
        ),
        centerTitle: centerTitle,
        excludeHeaderSemantics: true,
        titleSpacing: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Theme.of(context).scaffoldBackgroundColor,
                onPressed: () =>
                    onBackPressed != null ? onBackPressed!() : Get.back(),
              )
            : IconButton(
                icon: const Icon(Icons.menu),
                color: Theme.of(context).scaffoldBackgroundColor,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Theme.of(context).scaffoldBackgroundColor,
            onPressed: () => Get.to(() => const HomeScreen()),
          ),
        ],
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 50);
}

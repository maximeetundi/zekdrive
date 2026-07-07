import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';

class BottomMenuController extends GetxController implements GetxService{

  int _currentTab = 0;
  int get currentTab => _currentTab;

  void resetNavBar() {
    _currentTab = 0;
  }

  void setTabIndex(int index) {
    _currentTab = index;
     update();
  }

  void navigateToDashboard() {
    _currentTab = 0;
    // Aller toujours au Dashboard — la carte utilise les coords par défaut si pas de GPS
    Get.offAll(() => const DashboardScreen());
  }

  void exitApp() {
    Get.dialog(ConfirmationDialogWidget(
      icon: Images.profileLogout,
      description: 'do_you_want_to_exit_the_app'.tr,
      onYesPressed:() => SystemNavigator.pop(),
    ), barrierDismissible: false);
  }

}

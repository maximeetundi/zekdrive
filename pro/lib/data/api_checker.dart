import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'error_response.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if(response.statusCode == 401) {
      Get.find<SplashController>().removeSharedData();
      //showCustomSnackBar(response.body['message']);
      Get.offAll(()=> const SignInScreen());

    }else {
      String? errorMessage;
      if (response.body != null && response.body is Map) {
        errorMessage = response.body['message'] ?? response.body['error'];
      }
      errorMessage ??= response.statusText;
      showCustomSnackBar(errorMessage ?? 'Unknown error');
    }
  }
}

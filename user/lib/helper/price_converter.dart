import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class PriceConverter {

  /// Retourne le symbole de devise actif.
  /// Priorité : CountryController (si disponible) > ConfigController
  static String _getSymbol({bool? loyaltyPoint}) {
    if (loyaltyPoint == true) return '';
    try {
      // Utilise le CountryController si enregistré
      final dynamic cc = Get.find(tag: 'country');
      if (cc != null) {
        final String sym = cc.currencySymbol as String;
        if (sym.isNotEmpty) return sym;
      }
    } catch (_) {}
    return Get.find<ConfigController>().config?.currencySymbol ?? '\$';
  }

  static String convertPrice(
    double price, {
    double? discount,
    String? discountType,
    bool? loyaltyPoint,
  }) {
    bool inRight =
        Get.find<ConfigController>().config?.currencySymbolPosition == 'right';
    String decimal =
        Get.find<ConfigController>().config?.currencyDecimalPoint ?? '1';
    String symbol = _getSymbol(loyaltyPoint: loyaltyPoint);
    String finalResult;

    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price - discount;
      } else if (discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }

    final formatted = (price)
        .toStringAsFixed(int.parse(decimal))
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    if (inRight) {
      finalResult = '$formatted $symbol';
    } else {
      finalResult = '$symbol $formatted';
    }
    return finalResult;
  }

  static double convertWithDiscount(
      double price, double discount, String discountType) {
    if (discountType == 'amount') {
      price = price - discount;
    } else if (discountType == 'percent') {
      price = price - ((discount / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
      String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : '\$'} OFF';
  }
}

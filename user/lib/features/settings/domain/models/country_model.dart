class CountryModel {
  final String code;
  final String nameFr;
  final String nameEn;
  final String currencyCode;
  final String currencySymbol;
  final String flagEmoji;

  CountryModel({
    required this.code,
    required this.nameFr,
    required this.nameEn,
    required this.currencyCode,
    required this.currencySymbol,
    required this.flagEmoji,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] ?? '',
      nameFr: json['name_fr'] ?? '',
      nameEn: json['name_en'] ?? '',
      currencyCode: json['currency_code'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      flagEmoji: json['flag_emoji'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name_fr': nameFr,
      'name_en': nameEn,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'flag_emoji': flagEmoji,
    };
  }
}

class CountryConfigModel {
  final double? baseFare;
  final double? perKmRate;
  final double? perMinRate;
  final double? minFare;
  final double? commissionRide;

  CountryConfigModel({
    this.baseFare,
    this.perKmRate,
    this.perMinRate,
    this.minFare,
    this.commissionRide,
  });

  factory CountryConfigModel.fromJson(Map<String, dynamic> json) {
    return CountryConfigModel(
      baseFare: (json['base_fare'] as num?)?.toDouble(),
      perKmRate: (json['per_km_rate'] as num?)?.toDouble(),
      perMinRate: (json['per_min_rate'] as num?)?.toDouble(),
      minFare: (json['min_fare'] as num?)?.toDouble(),
      commissionRide: (json['commission_ride'] as num?)?.toDouble(),
    );
  }
}

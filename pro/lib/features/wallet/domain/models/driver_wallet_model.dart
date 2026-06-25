class DriverWallet {
  final String id;
  final String driverId;
  final double balance;
  final String currencyCode;
  final double minBalance;
  final bool isLocked;

  DriverWallet({
    required this.id,
    required this.driverId,
    required this.balance,
    required this.currencyCode,
    required this.minBalance,
    required this.isLocked,
  });

  factory DriverWallet.fromJson(Map<String, dynamic> json) {
    return DriverWallet(
      id: json['id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['currency_code']?.toString() ?? '',
      minBalance: (json['min_balance'] as num?)?.toDouble() ?? 0.0,
      isLocked: json['is_locked'] == true || json['is_locked'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'balance': balance,
      'currency_code': currencyCode,
      'min_balance': minBalance,
      'is_locked': isLocked,
    };
  }

  /// Le chauffeur peut accepter une mission en espèces si son solde >= solde minimum
  bool get canAcceptCashRide => !isLocked && balance >= minBalance;
}

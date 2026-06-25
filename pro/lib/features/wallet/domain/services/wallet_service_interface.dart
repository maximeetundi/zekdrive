
abstract class WalletServiceInterface {
  Future<dynamic> getTransactionList(int offset);
  Future<dynamic> getLoyaltyPointList(int offset);
  Future<dynamic> convertPoint(String point);
  Future<dynamic> getDynamicWithdrawMethodList();
  Future<dynamic> withdrawBalance(List <String> typeKey, List<String> typeValue,int id, String balance, String note);

  // --- Nouveau système wallet pro ---
  Future<dynamic> getWallet();
  Future<dynamic> getWalletTransactions();
  Future<dynamic> recharge(double amount, String paymentMethod, String phoneNumber, String reference);
}

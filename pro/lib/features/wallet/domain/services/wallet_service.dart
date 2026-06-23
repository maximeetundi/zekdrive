

import 'package:ride_sharing_user_app/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/services/wallet_service_interface.dart';

class WalletService implements WalletServiceInterface{
  final WalletRepositoryInterface walletRepositoryInterface;
  WalletService({required this.walletRepositoryInterface});

  @override
  Future convertPoint(String point) {
    return walletRepositoryInterface.convertPoint(point);
  }

  @override
  Future getDynamicWithdrawMethodList() {
    return walletRepositoryInterface.getDynamicWithdrawMethodList();
  }

  @override
  Future getLoyaltyPointList(int offset) {
    return walletRepositoryInterface.getLoyaltyPointList(offset);
  }

  @override
  Future getTransactionList(int offset) {
    return walletRepositoryInterface.getTransactionList(offset);
  }

  @override
  Future withdrawBalance(List<String> typeKey, List<String> typeValue, int id, String balance, String note) {
   return walletRepositoryInterface.withdrawBalance(typeKey, typeValue, id, balance, note);
  }


}
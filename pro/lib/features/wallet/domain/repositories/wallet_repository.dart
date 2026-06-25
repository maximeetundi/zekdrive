import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

class WalletRepository implements WalletRepositoryInterface{
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  @override
  Future<Response?> getTransactionList(int offset) async {
    return await apiClient.getData('${AppConstants.transactionListUri}$offset');
  }

  @override
  Future<Response?> getLoyaltyPointList(int offset) async {
    return await apiClient.getData('${AppConstants.loyaltyPointListUri}$offset');
  }

  @override
  Future<Response?> convertPoint(String point) async {
    return await apiClient.postData(AppConstants.pointConvert,{
      'points' : point
    });
  }

  @override
  Future<Response?> getDynamicWithdrawMethodList() async {
    return await apiClient.getData(AppConstants.dynamicWithdrawMethodList);
  }

  @override
  Future<Response?> withdrawBalance(List <String> typeKey, List<String> typeValue,int id, String balance, String note) async {

      Map<String, String> fields = {};

      for(var i = 0; i < typeKey.length; i++){
        fields.addAll(<String, String>{
          typeKey[i] : typeValue[i]
        });
        if (kDebugMode) {
          print('--here is type key =${typeKey.toList()}/${typeValue.toList()}');
        }
      }
      fields.addAll(<String, String>{
        'amount': balance,
        'withdraw_method': id.toString(),
        'note': note
      });

      Response response = await apiClient.postData(
          AppConstants.withdrawRequestUri, fields);

      return response;

  }

  // --- Nouveau système wallet pro ---

  @override
  Future<Response?> getWallet() async {
    return await apiClient.getData(AppConstants.proWalletUri);
  }

  @override
  Future<Response?> getWalletTransactions() async {
    return await apiClient.getData(AppConstants.proWalletTransactionsUri);
  }

  @override
  Future<Response?> recharge(double amount, String paymentMethod, String phoneNumber, String reference) async {
    return await apiClient.postData(AppConstants.proWalletRechargeUri, {
      'amount': amount,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
      'reference': reference,
    });
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    throw UnimplementedError();
  }

}

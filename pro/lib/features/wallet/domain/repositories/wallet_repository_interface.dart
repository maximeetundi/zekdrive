

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:ride_sharing_user_app/interface/repository_interface.dart';

abstract class WalletRepositoryInterface implements RepositoryInterface{

  Future<Response?> getTransactionList(int offset);
  Future<Response?> getLoyaltyPointList(int offset);
  Future<Response?> convertPoint(String point);
  Future<Response?> getDynamicWithdrawMethodList();
  Future<Response?> withdrawBalance(List <String> typeKey, List<String> typeValue,int id, String balance, String note);
}
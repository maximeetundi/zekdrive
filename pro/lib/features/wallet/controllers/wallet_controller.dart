import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/loyalty_point_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/transaction_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/withdraw_model.dart';


class WalletController extends GetxController implements GetxService{
  final WalletServiceInterface walletServiceInterface;

  WalletController({required this.walletServiceInterface});


  List<String> walletTypeList =['wallet_money', 'my_point'];
  List<String> walletFilterType =['select','today', 'this_month', 'this_year'];
  List<String> walletTransactionType =['select','pending', 'withdrawn', 'cancelled'];
  List<String> selectedFilterType = ['select','today', 'this_month', 'this_year'];
  int _walletTypeIndex = 0;
  int get walletTypeIndex => _walletTypeIndex;



  bool isLoading = false;
  String selectedValue = 'select';

  String _selectedFilterTypeName = 'pending';
  String get selectedFilterTypeName => _selectedFilterTypeName;

  void setFilterTypeName(String name){
    _selectedFilterTypeName = name;
    update();
  }

  bool isConvert = false;
  void toggleConvertCard(bool value){
    isConvert = value;
    update();
  }

  void setWalletTypeIndex(int index){
    _walletTypeIndex = index;
    getTransactionList(1);
    update();
  }

  LoyaltyPointModel? loyaltyPointModel;
  Future<Response> getLoyaltyPointList(int offset) async {
    isLoading = true;
    // update();
    Response? response = await walletServiceInterface.getLoyaltyPointList(offset);
    if (response!.statusCode == 200) {
      if(offset == 1){
        loyaltyPointModel = LoyaltyPointModel.fromJson(response.body);
      }else{
        loyaltyPointModel!.data!.addAll(LoyaltyPointModel.fromJson(response.body).data!);
        loyaltyPointModel!.offset = LoyaltyPointModel.fromJson(response.body).offset;
        loyaltyPointModel!.totalSize = LoyaltyPointModel.fromJson(response.body).totalSize;
      }
      isLoading = false;

    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  TransactionModel? transactionModel;


  Future<Response> getTransactionList(int offset) async {
    isLoading = true;

    Response? response = await walletServiceInterface.getTransactionList(offset);
    if (response!.statusCode == 200) {
      if(offset == 1){
        transactionModel = TransactionModel.fromJson(response.body);
      }else{
        transactionModel!.data!.addAll(TransactionModel.fromJson(response.body).data!);
        transactionModel!.offset = TransactionModel.fromJson(response.body).offset;
        transactionModel!.totalSize = TransactionModel.fromJson(response.body).totalSize;
      }
      isLoading = false;

    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> convertPoint(String point) async {
    isLoading = true;
    update();
    Response? response = await walletServiceInterface.convertPoint(point);
    if (response!.statusCode == 200) {
      getLoyaltyPointList(1);
      Get.find<ProfileController>().getProfileInfo();
      isLoading = false;
      showCustomSnackBar('pont_converted_successfully'.tr, isError: false);
    }else{
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Withdraw? selectedMethod;
  List<Withdraw> methodList = [];
  List<TextEditingController> inputFieldControllerList = [];
  List<int> isRequiredList = [];
  void getInputFieldList(){
    inputFieldControllerList = [];
    if(methodList.isNotEmpty && selectedMethod != null){
      for(int i= 0; i< selectedMethod!.methodFields!.length; i++){
        inputFieldControllerList.add(TextEditingController());
        isRequiredList.add(selectedMethod!.methodFields![i].isRequired!);
      }
    }
  }
  final List<int> suggestedAmount = [100,200,300,400,500, 1000,1500, 2000];
  int selectedIndex = -1;
  void setSelectedIndex(int index){
    selectedIndex = index;
    update();
  }
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  List <String> keyList = [];
  void setMethodTypeIndex(Withdraw withdraw, {bool notify = true}){
    selectedMethod = withdraw;
    keyList = [];
    if(methodList.isNotEmpty){
      for(int i= 0; i< selectedMethod!.methodFields!.length; i++){
        keyList.add(selectedMethod!.methodFields![i].inputName!);
      }
      getInputFieldList();
    }
    if(notify){
      update();
    }

  }
  Future<void> getWithdrawMethods() async{
    methodList = [];
    Response? response = await walletServiceInterface.getDynamicWithdrawMethodList();
    if(response!.statusCode == 200) {
      methodList.addAll(WithdrawModel.fromJson(response.body).data!);
      getInputFieldList();
      for(int index = 0; index < methodList.length; index++) {
        if(methodList[index].isDefault!){
          setMethodTypeIndex(methodList[index], notify: false);
        }
      }

    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }


  List<String> inputValueList = [];
  bool validityCheck = false;
  Future<Response?> updateBalance(String balance, String note) async {
    isLoading = true;
    update();
    for(TextEditingController textEditingController in inputFieldControllerList) {
      inputValueList.add(textEditingController.text.trim());
    }
    Response? response = await walletServiceInterface.withdrawBalance(keyList, inputValueList, selectedMethod!.id!, balance, note);

    if (response!.statusCode == 200) {
     Get.back();
      inputValueList.clear();
      inputFieldControllerList.clear();

      isLoading = false;
      showCustomSnackBar('withdraw_request_sent_successfully'.tr, isError: false);
      Get.find<ProfileController>().getProfileInfo();
      Get.find<WalletController>().getTransactionList(1);
    }
    else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }

    update();
    return response;
  }


}
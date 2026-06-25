import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/loyalty_point_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/transaction_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/withdraw_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/driver_wallet_model.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/wallet_transaction_model.dart';


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

  // ============================================================
  // Nouveau système wallet pro (modèle Yango)
  // ============================================================

  DriverWallet? _driverWallet;
  DriverWallet? get driverWallet => _driverWallet;

  double get walletBalance => _driverWallet?.balance ?? 0.0;
  String get walletCurrency => _driverWallet?.currencyCode ?? '';
  bool get isLocked => _driverWallet?.isLocked ?? false;
  double get minBalance => _driverWallet?.minBalance ?? 0.0;

  /// true = le chauffeur peut accepter des courses en espèces
  bool get canAcceptRide => _driverWallet?.canAcceptCashRide ?? true;

  bool _isWalletLoading = false;
  bool get isWalletLoading => _isWalletLoading;

  List<WalletTransaction> _walletTransactions = [];
  List<WalletTransaction> get walletTransactions => _walletTransactions;

  bool _isTransactionsLoading = false;
  bool get isTransactionsLoading => _isTransactionsLoading;

  bool _isRecharging = false;
  bool get isRecharging => _isRecharging;

  /// Récupère le wallet pro depuis le backend
  Future<void> getWallet() async {
    _isWalletLoading = true;
    update();
    try {
      Response? response = await walletServiceInterface.getWallet();
      if (response != null && response.statusCode == 200) {
        _driverWallet = DriverWallet.fromJson(response.body);
      } else if (response != null) {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      // Silently handle - the wallet feature may not be deployed yet
    }
    _isWalletLoading = false;
    update();
  }

  /// Récupère l'historique des transactions du wallet pro
  Future<void> getProWalletTransactions() async {
    _isTransactionsLoading = true;
    update();
    try {
      Response? response = await walletServiceInterface.getWalletTransactions();
      if (response != null && response.statusCode == 200) {
        final List<dynamic> data = response.body is List
            ? response.body
            : (response.body['data'] ?? []);
        _walletTransactions = data
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response != null) {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      _walletTransactions = [];
    }
    _isTransactionsLoading = false;
    update();
  }

  /// Recharge le wallet pro
  Future<bool> rechargeWallet({
    required double amount,
    required String paymentMethod,
    required String phoneNumber,
    required String reference,
  }) async {
    _isRecharging = true;
    update();
    bool success = false;
    try {
      Response? response = await walletServiceInterface.recharge(
        amount, paymentMethod, phoneNumber, reference,
      );
      if (response != null && response.statusCode == 200) {
        success = true;
        showCustomSnackBar('recharge_successful'.tr, isError: false);
        // Rafraîchir le wallet et les transactions
        await getWallet();
        await getProWalletTransactions();
      } else if (response != null) {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      showCustomSnackBar('recharge_failed'.tr);
    }
    _isRecharging = false;
    update();
    return success;
  }

  // Contrôleurs pour le formulaire de recharge
  final TextEditingController rechargeAmountController = TextEditingController();
  final TextEditingController rechargePhoneController = TextEditingController();
  final TextEditingController rechargeReferenceController = TextEditingController();

  String _selectedPaymentMethod = 'mobile_money';
  String get selectedPaymentMethod => _selectedPaymentMethod;

  final List<String> paymentMethods = ['mobile_money', 'bank_transfer', 'cash'];

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    update();
  }

  void clearRechargeForm() {
    rechargeAmountController.clear();
    rechargePhoneController.clear();
    rechargeReferenceController.clear();
    _selectedPaymentMethod = 'mobile_money';
  }

  @override
  void onClose() {
    rechargeAmountController.dispose();
    rechargePhoneController.dispose();
    rechargeReferenceController.dispose();
    super.onClose();
  }
}

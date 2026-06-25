import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/domain/models/wallet_transaction_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

/// Écran wallet pro (modèle Yango) :
/// - Affiche le solde en grand avec la devise
/// - Alerte si wallet verrouillé
/// - Bouton Recharger (bottom sheet)
/// - Liste des transactions
class ProWalletScreen extends StatefulWidget {
  const ProWalletScreen({super.key});

  @override
  State<ProWalletScreen> createState() => _ProWalletScreenState();
}

class _ProWalletScreenState extends State<ProWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<WalletController>();
      c.getWallet();
      c.getProWalletTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('pro_wallet'.tr,
            style: textSemiBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeExtraLarge,
            )),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Get.back(),
        ),
        actions: [
          GetBuilder<WalletController>(builder: (c) {
            return IconButton(
              icon: Icon(Icons.refresh,
                  color: Theme.of(context).primaryColor),
              onPressed: () async {
                await c.getWallet();
                await c.getProWalletTransactions();
              },
            );
          }),
        ],
      ),
      body: GetBuilder<WalletController>(
        builder: (walletController) {
          if (walletController.isWalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await walletController.getWallet();
              await walletController.getProWalletTransactions();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // --- Carte solde principal ---
                    _WalletBalanceCard(walletController: walletController),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // --- Alerte wallet verrouillé ---
                    if (walletController.isLocked)
                      _LockedAlert(),

                    // --- Alerte solde insuffisant (pas verrouillé mais < min) ---
                    if (!walletController.isLocked &&
                        walletController.driverWallet != null &&
                        walletController.walletBalance <
                            walletController.minBalance)
                      _InsufficientBalanceAlert(
                          minBalance: walletController.minBalance,
                          currency: walletController.walletCurrency),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // --- Bouton Recharger ---
                    _RechargeButton(walletController: walletController),

                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    // --- Titre historique ---
                    Text(
                      'transaction_history'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // --- Liste des transactions ---
                    _ProTransactionList(walletController: walletController),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// Widget carte solde
// ============================================================
class _WalletBalanceCard extends StatelessWidget {
  final WalletController walletController;
  const _WalletBalanceCard({required this.walletController});

  @override
  Widget build(BuildContext context) {
    final bool locked = walletController.isLocked;
    final bool sufficient = walletController.canAcceptRide;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: locked
              ? [const Color(0xFFB71C1C), const Color(0xFFE53935)]
              : sufficient
                  ? [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.75),
                    ]
                  : [const Color(0xFFE65100), const Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        boxShadow: [
          BoxShadow(
            color: (locked
                    ? Colors.red
                    : sufficient
                        ? Theme.of(context).primaryColor
                        : Colors.orange)
                .withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icone statut
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              locked
                  ? Icons.lock_outline
                  : sufficient
                      ? Icons.account_balance_wallet
                      : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(
            'pro_wallet_balance'.tr,
            style: textMedium.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Solde en grand
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                walletController.walletBalance.toStringAsFixed(0),
                style: textBold.copyWith(
                  color: Colors.white,
                  fontSize: 52,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                walletController.walletCurrency,
                style: textSemiBold.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Solde minimum requis
          if (walletController.driverWallet != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSeven),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusExtraLarge),
              ),
              child: Text(
                '${'min_required'.tr}: ${walletController.minBalance.toStringAsFixed(0)} ${walletController.walletCurrency}',
                style: textRegular.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ),

          if (locked)
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSeven),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'wallet_locked'.tr,
                      style: textSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Alerte wallet verrouillé
// ============================================================
class _LockedAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline,
              color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'wallet_locked'.tr,
                  style: textSemiBold.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: 4),
                Text(
                  'wallet_locked_description'.tr,
                  style: textRegular.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .error
                          .withOpacity(0.8),
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Alerte solde insuffisant
// ============================================================
class _InsufficientBalanceAlert extends StatelessWidget {
  final double minBalance;
  final String currency;
  const _InsufficientBalanceAlert(
      {required this.minBalance, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'insufficient_wallet_balance'.tr,
                  style: textSemiBold.copyWith(
                      color: Colors.orange,
                      fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: 4),
                Text(
                  '${'recharge_minimum_required'.tr} ${minBalance.toStringAsFixed(0)} $currency',
                  style: textRegular.copyWith(
                      color: Colors.orange.withOpacity(0.85),
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Bouton Recharger
// ============================================================
class _RechargeButton extends StatelessWidget {
  final WalletController walletController;
  const _RechargeButton({required this.walletController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _showRechargeBottomSheet(context, walletController),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: Text(
          'recharge_wallet'.tr,
          style: textSemiBold.copyWith(
              color: Colors.white, fontSize: Dimensions.fontSizeLarge),
        ),
      ),
    );
  }

  void _showRechargeBottomSheet(
      BuildContext context, WalletController walletController) {
    walletController.clearRechargeForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RechargeBottomSheet(walletController: walletController),
    );
  }
}

// ============================================================
// Bottom sheet de recharge
// ============================================================
class _RechargeBottomSheet extends StatefulWidget {
  final WalletController walletController;
  const _RechargeBottomSheet({required this.walletController});

  @override
  State<_RechargeBottomSheet> createState() => _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends State<_RechargeBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final List<double> _suggestedAmounts = [500, 1000, 2000, 5000, 10000];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.paddingSizeExtraLarge)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge,
        Dimensions.paddingSizeLarge + bottomPadding,
      ),
      child: GetBuilder<WalletController>(
        builder: (c) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'recharge_wallet'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeOverLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // --- Montant ---
                  Text('amount'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextFormField(
                    controller: c.rechargeAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration(
                        context, 'enter_amount'.tr, Icons.monetization_on_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'amount_required'.tr;
                      }
                      final d = double.tryParse(v.trim());
                      if (d == null || d <= 0) return 'invalid_amount'.tr;
                      return null;
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Montants suggérés
                  Wrap(
                    spacing: Dimensions.paddingSizeSmall,
                    runSpacing: Dimensions.paddingSizeSmall,
                    children: _suggestedAmounts
                        .map((amount) => GestureDetector(
                              onTap: () {
                                c.rechargeAmountController.text =
                                    amount.toStringAsFixed(0);
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeSeven),
                                decoration: BoxDecoration(
                                  color: c.rechargeAmountController.text ==
                                          amount.toStringAsFixed(0)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusExtraLarge),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3)),
                                ),
                                child: Text(
                                  amount.toStringAsFixed(0),
                                  style: textSemiBold.copyWith(
                                    color:
                                        c.rechargeAmountController.text ==
                                                amount.toStringAsFixed(0)
                                            ? Colors.white
                                            : Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // --- Méthode de paiement ---
                  Text('payment_method'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                          color:
                              Theme.of(context).hintColor.withOpacity(0.3)),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: c.selectedPaymentMethod,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                      ),
                      items: c.paymentMethods
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.replaceAll('_', ' ').tr,
                                    style: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) c.setPaymentMethod(v);
                      },
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // --- Numéro de téléphone ---
                  Text('phone_number'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextFormField(
                    controller: c.rechargePhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                        context, 'enter_phone_number'.tr, Icons.phone_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'phone_required'.tr;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // --- Référence de paiement ---
                  Text('payment_reference'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  TextFormField(
                    controller: c.rechargeReferenceController,
                    decoration: _inputDecoration(context, 'enter_reference'.tr,
                        Icons.receipt_long_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'reference_required'.tr;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // --- Bouton confirmer ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: c.isRecharging
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final amount = double.parse(
                                    c.rechargeAmountController.text.trim());
                                final success = await c.rechargeWallet(
                                  amount: amount,
                                  paymentMethod: c.selectedPaymentMethod,
                                  phoneNumber:
                                      c.rechargePhoneController.text.trim(),
                                  reference:
                                      c.rechargeReferenceController.text.trim(),
                                );
                                if (success && context.mounted) {
                                  Get.back();
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        disabledBackgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge),
                        ),
                      ),
                      child: c.isRecharging
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'confirm_recharge'.tr,
                              style: textSemiBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: textRegular.copyWith(
          color: Theme.of(context).hintColor,
          fontSize: Dimensions.fontSizeDefault),
      prefixIcon:
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide: BorderSide(
            color: Theme.of(context).hintColor.withOpacity(0.3), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide: BorderSide(
            color: Theme.of(context).hintColor.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
      ),
    );
  }
}

// ============================================================
// Liste des transactions pro
// ============================================================
class _ProTransactionList extends StatelessWidget {
  final WalletController walletController;
  const _ProTransactionList({required this.walletController});

  @override
  Widget build(BuildContext context) {
    if (walletController.isTransactionsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (walletController.walletTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 60,
                  color: Theme.of(context).hintColor.withOpacity(0.5)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(
                'no_transaction_found'.tr,
                style: textMedium.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeDefault),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: walletController.walletTransactions.length,
      separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Theme.of(context).hintColor.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final tx = walletController.walletTransactions[index];
        return _ProTransactionTile(transaction: tx);
      },
    );
  }
}

// ============================================================
// Tuile transaction individuelle
// ============================================================
class _ProTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;
  const _ProTransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.error;

    String formattedDate = transaction.createdAt;
    try {
      formattedDate =
          DateConverter.isoStringToDateTimeString(transaction.createdAt);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          // Icone type
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(transaction.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          // Description et date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : transaction.type.replaceAll('_', ' ').tr,
                  style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),

          // Montant
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSeven),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(Dimensions.radiusExtraLarge),
            ),
            child: Text(
              '${isCredit ? '+' : '-'}${transaction.amount.abs().toStringAsFixed(0)}',
              style: textBold.copyWith(color: color,
                  fontSize: Dimensions.fontSizeDefault),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'recharge':
      case 'credit':
      case 'deposit':
        return Icons.add_circle_outline;
      case 'commission':
      case 'deduction':
      case 'debit':
        return Icons.remove_circle_outline;
      case 'refund':
        return Icons.undo;
      default:
        return Icons.swap_horiz;
    }
  }
}

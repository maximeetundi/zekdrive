import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/settings/controllers/country_controller.dart';
import 'package:ride_sharing_user_app/features/settings/domain/models/country_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CountrySelectBottomSheet extends StatefulWidget {
  const CountrySelectBottomSheet({super.key});

  @override
  State<CountrySelectBottomSheet> createState() =>
      _CountrySelectBottomSheetState();
}

class _CountrySelectBottomSheetState extends State<CountrySelectBottomSheet> {
  CountryModel? _tempSelected;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = Get.find<CountryController>().selectedCountry;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountryController>(builder: (controller) {
      final filtered = controller.countries.where((c) {
        final name = controller.countryDisplayName(c).toLowerCase();
        final code = c.code.toLowerCase();
        final q = _query.toLowerCase();
        return name.contains(q) || code.contains(q);
      }).toList();

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(
              'select_country'.tr,
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Champ de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_country'.tr,
                hintStyle: textRegular.copyWith(
                    color: Theme.of(context).hintColor.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSize),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSize),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSize),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Liste des pays
            controller.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final country = filtered[index];
                        final isSelected =
                            _tempSelected?.code == country.code;
                        return InkWell(
                          onTap: () =>
                              setState(() => _tempSelected = country),
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusLarge),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05)
                                  : null,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusLarge),
                              border: isSelected
                                  ? Border.all(
                                      width: 0.5,
                                      color:
                                          Theme.of(context).primaryColor)
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Row(children: [
                              Text(
                                country.flagEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller
                                          .countryDisplayName(country),
                                      style: textSemiBold.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeDefault),
                                    ),
                                    Text(
                                      '${country.currencySymbol} (${country.currencyCode})',
                                      style: textRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: Dimensions.iconSizeMedium,
                                ),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: Dimensions.paddingSizeDefault),
            ButtonWidget(
              buttonText: 'update'.tr,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                if (_tempSelected != null) {
                  await controller.selectCountry(_tempSelected!);
                }
                Get.back();
              },
            ),
          ]),
        ),
      );
    });
  }
}

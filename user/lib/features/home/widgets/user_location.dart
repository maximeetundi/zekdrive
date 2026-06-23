import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';

class UserLocation extends StatelessWidget {
  final bool isHome; // Conservé pour la compatibilité ascendante
  const UserLocation({super.key, this.isHome = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (locationController) {
        String location =
            locationController.getUserAddress()?.address ?? 'Unknown location';
        return GestureDetector(
          onTap: () => Get.to(() => const AccessLocationScreen()),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('current_position'.tr,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 13)),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24, // Augmentez la taille ici
                      weight: 4, // Utilisez cette propriété pour l'épaisseur
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(location,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
        );
      },
    );
  }
}

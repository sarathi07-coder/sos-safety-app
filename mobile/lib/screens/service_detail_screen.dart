import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/emergency_service.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final List<String> features;
  final String ctaButtonText;
  final String phoneToCall;

  const ServiceDetailScreen({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.features,
    required this.ctaButtonText,
    required this.phoneToCall,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.textBlack),
            onPressed: () => EmergencyService.callEmergencyPhone(phoneToCall),
            tooltip: 'Call $phoneToCall',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Subtitle in bold red (Screen 3 from design)
              Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Large Bold Headline
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textDarkGrey,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Feature Badges with Circular Red Icons
              Expanded(
                child: ListView.separated(
                  itemCount: features.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final parts = features[index].split('\n');
                    final headline = parts[0];
                    final body = parts.length > 1 ? parts[1] : '';

                    IconData featureIcon;
                    if (index == 0) {
                      featureIcon = Icons.medical_services_rounded;
                    } else if (index == 1) {
                      featureIcon = Icons.location_on_rounded;
                    } else {
                      featureIcon = Icons.health_and_safety_rounded;
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(featureIcon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headline,
                                style: const TextStyle(
                                  color: AppColors.textBlack,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: const TextStyle(
                                  color: AppColors.textDarkGrey,
                                  fontSize: 12,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Black Pill CTA Button (Screen 3 from design)
              GestureDetector(
                onTap: () async {
                  await EmergencyService.triggerFullEmergency();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryRed,
                        content: Text('Dispatched $category alert!'),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textBlack,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ctaButtonText.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.textBlack,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Privacy Note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 14),
                  SizedBox(width: 6),
                  Text(
                    '100% PRIVATE & CONFIDENTIAL',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

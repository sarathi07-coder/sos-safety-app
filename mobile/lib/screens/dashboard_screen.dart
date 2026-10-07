import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/emergency_service.dart';
import 'service_detail_screen.dart';
import 'ghost_timer_screen.dart';
import 'police_finder_screen.dart';
import 'contacts_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenPulseMode;

  const DashboardScreen({super.key, required this.onOpenPulseMode});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  void _triggerFastSOS() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🚨 Confirm Instant SOS', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will immediately send Direct SIM SMS to your emergency contacts and broadcast to the cloud responders with your live GPS location.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await EmergencyService.triggerFullEmergency();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.primaryRed,
                    content: Text('🚨 SOS Alert Dispatched via Native SIM + Cloud Server!'),
                  ),
                );
              }
            },
            child: const Text('DISPATCH SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textBlack),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: AppColors.textBlack),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.lightBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryRed,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'CONTACTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              label: 'GHOST TIMER',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_police_outlined),
              label: 'POLICE CSP',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentNavIndex) {
      case 1:
        return const ContactsScreen();
      case 2:
        return const GhostTimerScreen();
      case 3:
        return const PoliceFinderScreen();
      case 0:
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header (Screen 2 from design)
          const Text(
            'WELCOME BACK,',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ALEX',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'HOW CAN WE HELP?',
            style: TextStyle(
              color: AppColors.textDarkGrey,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // Hero Red Active SOS Card (Screen 2 from design)
          GestureDetector(
            onTap: _triggerFastSOS,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'TAP FOR HELP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  // Concentric target icon (matching design mockup)
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.65), width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Banner to switch to Screen 1 Pulsing Emergency Mode
          InkWell(
            onTap: widget.onOpenPulseMode,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_share, color: AppColors.glowRed, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Switch to Full-Screen Dark SOS Pulse Mode',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: QUICK SERVICES (Screen 2 from design)
          const Text(
            'QUICK SERVICES',
            style: TextStyle(
              color: AppColors.textDarkGrey,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          _buildServiceTile(
            icon: Icons.add_circle_outline_rounded,
            iconColor: AppColors.primaryRed,
            title: 'Medical Emergency',
            subtitle: 'Connect to medical experts & nearby aid',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ServiceDetailScreen(
                  category: 'MEDICAL EMERGENCY',
                  title: 'EXPERT CARE, ANYWHERE.',
                  description:
                      'Connect instantly with top medical emergency responders, ambulance coordinates, and verified first responders in your area.',
                  features: [
                    '24/7 EMERGENCY DOCTORS\nAccess board-certified doctors anytime, anywhere.',
                    'ER NAVIGATION & CSP\nWe guide you to the nearest best-suited hospital ER.',
                    'FOLLOW-UP GUARDIAN CARE\nOngoing live monitoring for your recovery and safety.',
                  ],
                  ctaButtonText: 'REQUEST MEDICAL HELP',
                  phoneToCall: '108',
                ),
              ),
            ),
          ),

          _buildServiceTile(
            icon: Icons.shield_rounded,
            iconColor: AppColors.textBlack,
            title: 'Security Assistance',
            subtitle: 'Request immediate security & verified responders',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ServiceDetailScreen(
                  category: 'SECURITY ASSISTANCE',
                  title: 'INSTANT PROTECTION NETWORK.',
                  description:
                      'Broadcast silent or loud distress alerts to verified nearby citizens, police stations, and trusted guardian rooms.',
                  features: [
                    'VERIFIED CITIZEN CORPS\nAlerts verified helpers within 5km of your location.',
                    'STEALTH WEBRTC STREAM\nSecretly streams live audio/video to guardians.',
                    'UNIVERSAL POLICE 112 DISPATCH\nInstant local police station SMS + phone call backup.',
                  ],
                  ctaButtonText: 'REQUEST SECURITY PATROL',
                  phoneToCall: '112',
                ),
              ),
            ),
          ),

          _buildServiceTile(
            icon: Icons.directions_car_filled_rounded,
            iconColor: AppColors.textBlack,
            title: 'Roadside & Pacer Help',
            subtitle: 'Volume auto-up on door open & intrusion sensor',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ServiceDetailScreen(
                  category: 'ROADSIDE & PACER DEFENSE',
                  title: 'ACTIVE DETERRENCE SYSTEM.',
                  description:
                      'When your phone detects sudden door jolts or noise spikes, AlleyPilot automatically cranks volume to 100% and triggers deterrent sirens.',
                  features: [
                    'AUTOMATIC VOLUME BOOST\nForces phone audio to maximum when door opens.',
                    'ACCELEROMETER JOLT DETECTION\nMonitors rapid movement even when screen is off.',
                    'ROADSIDE TOW & ASSISTANCE\nConnects you to verified 24/7 recovery services.',
                  ],
                  ctaButtonText: 'ARM PACER SENSOR',
                  phoneToCall: '1033',
                ),
              ),
            ),
          ),

          _buildServiceTile(
            icon: Icons.flight_takeoff_rounded,
            iconColor: AppColors.textBlack,
            title: 'Travel Assistance',
            subtitle: 'Live bus/train tracker & AI safe route planner',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ServiceDetailScreen(
                  category: 'TRAVEL TRACKER & AI RAG',
                  title: 'SAFE COMMUTE GUARDIAN.',
                  description:
                      'Real-time tracking of bus/train journeys with RAG AI that predicts lit streets, safety ratings, and warns guardians on delays.',
                  features: [
                    'LIVE TRANSIT REGISTRY\nGuardian dashboard watches your bus/train moving.',
                    'AI SAFETY ROUTE PLANNER\nRecommends safe lit arterial roads over dark alleys.',
                    'EMERGENCY DELAY ALARM\nAlerts guardians if stopped unexpectedly for >10 mins.',
                  ],
                  ctaButtonText: 'START PROTECTED COMMUTE',
                  phoneToCall: '139',
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textDarkGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textMuted,
            size: 14,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

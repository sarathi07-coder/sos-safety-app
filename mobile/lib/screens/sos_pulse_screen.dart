import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/emergency_service.dart';

class SosPulseScreen extends StatefulWidget {
  final VoidCallback onNavigateToDashboard;

  const SosPulseScreen({super.key, required this.onNavigateToDashboard});

  @override
  State<SosPulseScreen> createState() => _SosPulseScreenState();
}

class _SosPulseScreenState extends State<SosPulseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isDispatching = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleEmergencyTap() async {
    setState(() {
      _isDispatching = true;
      _statusMessage = 'DISPATCHING EMERGENCY ALERTS...';
    });

    await EmergencyService.triggerFullEmergency();

    if (mounted) {
      setState(() {
        _isDispatching = false;
        _statusMessage = '🚨 SOS BROADCAST ACTIVE!\nDirect SIM SMS + Cloud Network Notified';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text(
            'Emergency triggered! Contacts alerted via Native SMS & Backend Server.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          action: SnackBarAction(
            label: 'VIEW DASHBOARD',
            textColor: Colors.white,
            onPressed: widget.onNavigateToDashboard,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar & Title
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '9:41',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.dashboard_customize_rounded, color: Colors.white70),
                        tooltip: 'Open Dashboard',
                        onPressed: widget.onNavigateToDashboard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'EXPERT HELP. ANYTIME.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),

              // Center Glowing Pulsing Emergency Button (Screen 1 from design)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _isDispatching ? null : _handleEmergencyTap,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.35),
                              blurRadius: 70,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: AppColors.glowRed.withOpacity(0.2),
                              blurRadius: 100,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Ring
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                                border: Border.all(
                                  color: AppColors.primaryRed.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Middle Red Gradient Disk
                            Container(
                              width: 210,
                              height: 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.glowRed,
                                    AppColors.primaryRed,
                                    AppColors.darkRed,
                                  ],
                                  stops: const [0.2, 0.7, 1.0],
                                ),
                              ),
                              child: Center(
                                child: _isDispatching
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'TAP FOR',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'EMERGENCY',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.glowRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),

              // Bottom 3 Safety Indicator Badges (Screen 1 from design)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSafetyBadge(
                        icon: Icons.shield_outlined,
                        label: '24/7\nPROTECTION',
                      ),
                      _buildSafetyBadge(
                        icon: Icons.location_on_outlined,
                        label: 'REAL-TIME\nLOCATION',
                      ),
                      _buildSafetyBadge(
                        icon: Icons.lock_outline_rounded,
                        label: 'PRIVATE &\nSECURE',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Pagination dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: widget.onNavigateToDashboard,
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 16),
                    label: const Text(
                      'OPEN FULL SERVICES DASHBOARD',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyBadge({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 26),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

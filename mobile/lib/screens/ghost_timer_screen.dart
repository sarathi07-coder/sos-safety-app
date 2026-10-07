import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/emergency_service.dart';

class GhostTimerScreen extends StatefulWidget {
  const GhostTimerScreen({super.key});

  @override
  State<GhostTimerScreen> createState() => _GhostTimerScreenState();
}

class _GhostTimerScreenState extends State<GhostTimerScreen> {
  int _selectedMinutes = 15;
  bool _isTimerActive = false;
  int _remainingSeconds = 0;
  Timer? _localTicker;

  @override
  void dispose() {
    _localTicker?.cancel();
    super.dispose();
  }

  void _startTimer() async {
    final userId = await EmergencyService.getUserId();
    final userName = await EmergencyService.getUserName();

    await ApiService.startGhostTimer(
      userId: userId,
      userName: userName,
      durationMinutes: _selectedMinutes,
      lat: 13.0827,
      lng: 80.2707,
    );

    setState(() {
      _isTimerActive = true;
      _remainingSeconds = _selectedMinutes * 60;
    });

    _localTicker?.cancel();
    _localTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        t.cancel();
        setState(() => _isTimerActive = false);
        // Local trigger if missed check-in
        EmergencyService.triggerFullEmergency();
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text('Ghost safety timer armed for $_selectedMinutes minutes!'),
        ),
      );
    }
  }

  void _checkinSafe() async {
    final userId = await EmergencyService.getUserId();
    await ApiService.checkinGhostTimer(userId);
    _localTicker?.cancel();

    setState(() {
      _isTimerActive = false;
      _remainingSeconds = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('✅ Checked in safely! Timer cancelled.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Operating Hours / Ghost Timer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isTimerActive ? AppColors.darkBackground : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Text(
                    _isTimerActive ? 'COUNTDOWN RUNNING' : 'SET SAFETY WINDOW',
                    style: TextStyle(
                      color: _isTimerActive ? AppColors.glowRed : AppColors.textDarkGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isTimerActive ? timeStr : '$_selectedMinutes MIN',
                    style: TextStyle(
                      color: _isTimerActive ? Colors.white : AppColors.textBlack,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isTimerActive
                        ? 'Tap "I Am Safe" before timer ends or SOS will auto-fire to your contacts'
                        : 'If you do not check in before expiration, an automatic SOS with live GPS is sent.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isTimerActive ? Colors.white70 : AppColors.textDarkGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_isTimerActive) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SELECT DURATION',
                  style: TextStyle(
                    color: AppColors.textDarkGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [10, 15, 30, 60].map((m) {
                  return ChoiceChip(
                    label: Text('$m min'),
                    selected: _selectedMinutes == m,
                    selectedColor: AppColors.softRed,
                    onSelected: (_) => setState(() => _selectedMinutes = m),
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _startTimer,
                child: const Text(
                  'START GHOST TIMER',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: const Text(
                  'I AM SAFE — CHECK IN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _checkinSafe,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

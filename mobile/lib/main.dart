import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/sos_pulse_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlleyPilotApp());
}

class AlleyPilotApp extends StatelessWidget {
  const AlleyPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlleyPilot Safety Super-App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainAppShell(),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  // 0: Full Screen Glowing SOS Pulse (Screen 1)
  // 1: Main Dashboard (Screen 2)
  int _activeScreenMode = 1; // Start on Dashboard by default

  @override
  Widget build(BuildContext context) {
    if (_activeScreenMode == 0) {
      return SosPulseScreen(
        onNavigateToDashboard: () {
          setState(() => _activeScreenMode = 1);
        },
      );
    }

    return DashboardScreen(
      onOpenPulseMode: () {
        setState(() => _activeScreenMode = 0);
      },
    );
  }
}

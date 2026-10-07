import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/offline_police_data.dart';
import '../services/api_service.dart';
import '../services/emergency_service.dart';

class PoliceFinderScreen extends StatefulWidget {
  const PoliceFinderScreen({super.key});

  @override
  State<PoliceFinderScreen> createState() => _PoliceFinderScreenState();
}

class _PoliceFinderScreenState extends State<PoliceFinderScreen> {
  // Coordinates for simulated testing
  double _currentLat = 12.8342; // Kanchipuram Taluk
  double _currentLng = 79.7036;
  String _selectedDistrict = 'Kanchipuram';

  List<PoliceStation> _stations = [];
  PoliceStation? _nearestStation;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadOfflineStations();
  }

  void _loadOfflineStations() {
    setState(() {
      _nearestStation = OfflinePoliceRepository.findNearestOffline(_currentLat, _currentLng);
      _stations = OfflinePoliceRepository.prebundledStations
          .where((s) => s.district.toLowerCase() == _selectedDistrict.toLowerCase())
          .map((s) {
        final dist = OfflinePoliceRepository.calculateDistanceKm(_currentLat, _currentLng, s.lat, s.lng);
        return PoliceStation(
          id: s.id,
          name: s.name,
          district: s.district,
          state: s.state,
          lat: s.lat,
          lng: s.lng,
          phone: s.phone,
          controlRoom: s.controlRoom,
          address: s.address,
          distanceKm: (dist * 10).round() / 10.0,
        );
      }).toList();
    });
  }

  // Simulating user moving from Chennai to Kanchipuram
  void _simulateMove(String destination) {
    setState(() {
      _selectedDistrict = destination;
      if (destination == 'Kanchipuram') {
        _currentLat = 12.8342;
        _currentLng = 79.7036;
      } else {
        _currentLat = 13.0827; // Chennai Central
        _currentLng = 80.2707;
      }
      _loadOfflineStations();
    });
  }

  Future<void> _syncFromCloud() async {
    setState(() => _isSyncing = true);
    final synced = await ApiService.syncRegionalPoliceStations(
      lat: _currentLat,
      lng: _currentLng,
      radiusKm: 30,
    );
    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (synced.isNotEmpty) {
          _stations = synced;
          _nearestStation = synced.first;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.textBlack,
          content: Text('Synced ${synced.length} verified police stations for $_selectedDistrict!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Offline Police CSP Finder'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync_rounded),
            tooltip: 'Sync District Data from Cloud',
            onPressed: _isSyncing ? null : _syncFromCloud,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Travel Simulation Pill (Chennai vs Kanchipuram)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIMULATE LOCATION (MOVING DISTRICTS)',
                    style: TextStyle(
                      color: AppColors.textDarkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Chennai City'),
                          selected: _selectedDistrict == 'Chennai',
                          selectedColor: AppColors.softRed,
                          onSelected: (_) => _simulateMove('Chennai'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Kanchipuram'),
                          selected: _selectedDistrict == 'Kanchipuram',
                          selectedColor: AppColors.softRed,
                          onSelected: (_) => _simulateMove('Kanchipuram'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Current GPS: ${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nearest Station Hero Card
            if (_nearestStation != null) ...[
              const Text(
                'NEAREST POLICE STATION (CALCULATED OFFLINE)',
                style: TextStyle(
                  color: AppColors.textDarkGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_nearestStation!.distanceKm} KM AWAY',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        const Icon(Icons.offline_bolt_rounded, color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nearestStation!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nearestStation!.address,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textBlack,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.call_rounded, size: 16),
                            label: Text('CALL ${_nearestStation!.phone}'),
                            onPressed: () => EmergencyService.callEmergencyPhone(_nearestStation!.phone),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => EmergencyService.callEmergencyPhone('112'),
                          child: const Text('CALL 112'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Stations in district list
            Text(
              'ALL STATIONS IN $_selectedDistrict.toUpperCase()',
              style: const TextStyle(
                color: AppColors.textDarkGrey,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            ..._stations.map(
              (station) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.softRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_police_rounded, color: AppColors.primaryRed, size: 20),
                    ),
                    title: Text(
                      station.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${station.distanceKm ?? 0} km • ${station.phone}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textDarkGrey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryRed),
                      onPressed: () => EmergencyService.callEmergencyPhone(station.phone),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';

class PoliceStation {
  final String id;
  final String name;
  final String district;
  final String state;
  final double lat;
  final double lng;
  final String phone;
  final String controlRoom;
  final String address;
  double? distanceKm;

  PoliceStation({
    required this.id,
    required this.name,
    required this.district,
    required this.state,
    required this.lat,
    required this.lng,
    required this.phone,
    required this.controlRoom,
    required this.address,
    this.distanceKm,
  });

  factory PoliceStation.fromJson(Map<String, dynamic> json) {
    return PoliceStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? 'Tamil Nadu',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phone: json['phone'] ?? '112',
      controlRoom: json['controlRoom'] ?? '112',
      address: json['address'] ?? '',
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'state': state,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'controlRoom': controlRoom,
      'address': address,
      'distanceKm': distanceKm,
    };
  }
}

class OfflinePoliceRepository {
  // Pre-bundled local dataset (Chennai & Kanchipuram)
  static final List<PoliceStation> prebundledStations = [
    // ── CHENNAI ───────────────────────────────────────────────
    PoliceStation(
      id: 'ps_chn_01',
      name: 'Anna Nagar Police Station (K-4)',
      district: 'Chennai',
      state: 'Tamil Nadu',
      lat: 13.0850,
      lng: 80.2101,
      phone: '044-23452601',
      controlRoom: '112',
      address: '2nd Avenue, Anna Nagar, Chennai',
    ),
    PoliceStation(
      id: 'ps_chn_02',
      name: 'T. Nagar Police Station (R-1)',
      district: 'Chennai',
      state: 'Tamil Nadu',
      lat: 13.0418,
      lng: 80.2341,
      phone: '044-23452580',
      controlRoom: '112',
      address: 'Natesan Park Rd, T. Nagar, Chennai',
    ),
    PoliceStation(
      id: 'ps_chn_03',
      name: 'Mylapore Police Station (E-1)',
      district: 'Chennai',
      state: 'Tamil Nadu',
      lat: 13.0368,
      lng: 80.2676,
      phone: '044-23452570',
      controlRoom: '112',
      address: 'Kutchery Road, Mylapore, Chennai',
    ),
    PoliceStation(
      id: 'ps_chn_04',
      name: 'Guindy Police Station (J-3)',
      district: 'Chennai',
      state: 'Tamil Nadu',
      lat: 13.0067,
      lng: 80.2025,
      phone: '044-23452595',
      controlRoom: '112',
      address: 'Race Course Rd, Guindy, Chennai',
    ),
    PoliceStation(
      id: 'ps_chn_05',
      name: 'Tambaram Police Station',
      district: 'Chennai',
      state: 'Tamil Nadu',
      lat: 12.9249,
      lng: 80.1000,
      phone: '044-22266100',
      controlRoom: '112',
      address: 'GST Road, Tambaram, Chennai',
    ),

    // ── KANCHIPURAM ───────────────────────────────────────────
    PoliceStation(
      id: 'ps_kan_01',
      name: 'Kanchipuram Taluk Police Station',
      district: 'Kanchipuram',
      state: 'Tamil Nadu',
      lat: 12.8342,
      lng: 79.7036,
      phone: '044-27222300',
      controlRoom: '112',
      address: 'Kamarajar Salai, Kanchipuram',
    ),
    PoliceStation(
      id: 'ps_kan_02',
      name: 'Kanchipuram Town Police Station (B-1)',
      district: 'Kanchipuram',
      state: 'Tamil Nadu',
      lat: 12.8385,
      lng: 79.7015,
      phone: '044-27222100',
      controlRoom: '112',
      address: 'Gandhi Road, Kanchipuram',
    ),
    PoliceStation(
      id: 'ps_kan_03',
      name: 'Sriperumbudur Police Station',
      district: 'Kanchipuram',
      state: 'Tamil Nadu',
      lat: 12.9734,
      lng: 79.9436,
      phone: '044-27162233',
      controlRoom: '112',
      address: 'Bangalore Highway, Sriperumbudur',
    ),
    PoliceStation(
      id: 'ps_kan_04',
      name: 'Walajabad Police Station',
      district: 'Kanchipuram',
      state: 'Tamil Nadu',
      lat: 12.7936,
      lng: 79.8228,
      phone: '044-27256221',
      controlRoom: '112',
      address: 'Bazaar Street, Walajabad',
    ),
    PoliceStation(
      id: 'ps_kan_05',
      name: 'Sunguvarchatram Police Station',
      district: 'Kanchipuram',
      state: 'Tamil Nadu',
      lat: 12.9348,
      lng: 79.8512,
      phone: '044-27165440',
      controlRoom: '112',
      address: 'SIPCOT Industrial Park, Sunguvarchatram',
    ),
  ];

  // Local Haversine calculation (zero internet needed)
  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (lat2 - lat1) * (pi / 180.0);
    final double dLon = (lon2 - lon1) * (pi / 180.0);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) * cos(lat2 * (pi / 180.0)) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  // Find nearest station completely offline
  static PoliceStation findNearestOffline(double currentLat, double currentLng) {
    PoliceStation nearest = prebundledStations.first;
    double minDistance = double.infinity;

    for (final station in prebundledStations) {
      final dist = calculateDistanceKm(currentLat, currentLng, station.lat, station.lng);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = PoliceStation(
          id: station.id,
          name: station.name,
          district: station.district,
          state: station.state,
          lat: station.lat,
          lng: station.lng,
          phone: station.phone,
          controlRoom: station.controlRoom,
          address: station.address,
          distanceKm: (dist * 10).round() / 10.0,
        );
      }
    }
    return nearest;
  }
}

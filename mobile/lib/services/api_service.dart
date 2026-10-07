import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/offline_police_data.dart';

class ApiService {
  // Use localhost for iOS simulator / macOS desktop, or 10.0.2.2 for Android emulator
  // Or current machine's LAN IP / tunnel
  static const String baseUrl = 'http://localhost:3000';

  // 1. Trigger SOS (Cloud Role)
  static Future<Map<String, dynamic>> triggerCloudSOS({
    required String userId,
    required String userName,
    required double lat,
    required double lng,
    required int battery,
    bool isSilent = false,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'userName': userName,
          'lat': lat,
          'lng': lng,
          'battery': battery,
          'isSilent': isSilent,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return {'success': false, 'message': 'HTTP ${res.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 2. Resolve SOS
  static Future<bool> resolveSOS(String userId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/sos/resolve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 3. Ghost Timer Start
  static Future<Map<String, dynamic>> startGhostTimer({
    required String userId,
    required String userName,
    required int durationMinutes,
    required double lat,
    required double lng,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/timer/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'userName': userName,
          'durationMinutes': durationMinutes,
          'lat': lat,
          'lng': lng,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 4. Ghost Timer Check-in
  static Future<bool> checkinGhostTimer(String userId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/timer/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 5. Police Station Dynamic Sync (Chennai -> Kanchipuram)
  static Future<List<PoliceStation>> syncRegionalPoliceStations({
    required double lat,
    required double lng,
    int radiusKm = 40,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/police/sync?lat=$lat&lng=$lng&radiusKm=$radiusKm'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['stations'] as List? ?? []);
        return list.map((item) => PoliceStation.fromJson(item)).toList();
      }
    } catch (_) {}
    // Fallback: return pre-bundled stations if network unavailable
    return OfflinePoliceRepository.prebundledStations;
  }

  // 6. Emergency Contacts
  static Future<bool> saveContacts(String userId, List<String> contacts) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/contacts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'contacts': contacts}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 7. AI Travel Plan
  static Future<Map<String, dynamic>?> getAiTravelPlan({
    required String from,
    required String to,
    String? departureTime,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/travel/ai-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': from,
          'to': to,
          'departureTime': departureTime ?? DateTime.now().hour.toString(),
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['plan'];
      }
    } catch (_) {}
    return null;
  }
}

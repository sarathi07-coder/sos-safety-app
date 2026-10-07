import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import '../data/offline_police_data.dart';

class EmergencyService {
  static const String _contactsKey = 'alleypilot_emergency_contacts';
  static const String _userNameKey = 'alleypilot_user_name';
  static const String _userIdKey = 'alleypilot_user_id';

  // 1. Save contacts locally on phone (zero internet needed)
  static Future<void> saveLocalContacts(List<String> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_contactsKey, contacts);
    // Also sync to cloud if possible
    final userId = await getUserId();
    ApiService.saveContacts(userId, contacts);
  }

  // 2. Get local contacts
  static Future<List<String>> getLocalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_contactsKey) ?? ['+919876543210'];
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) ?? 'alex_01';
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Alex';
  }

  // 3. NATIVE DEVICE TRIGGER: Direct SIM SMS (Offline Carrier SMS)
  static Future<bool> sendNativeSimSms({
    required List<String> recipients,
    required String message,
  }) async {
    if (recipients.isEmpty) return false;
    // Android/iOS SMS intent: launches native carrier SMS directly from SIM card
    final numbers = recipients.join(',');
    final uri = Uri(
      scheme: 'sms',
      path: numbers,
      queryParameters: <String, String>{'body': message},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // 4. NATIVE DEVICE TRIGGER: Direct Emergency Phone Call (112 or Police)
  static Future<bool> callEmergencyPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // 5. COMPREHENSIVE DUAL SOS TRIGGER (Cloud Server + Mobile Native SIM)
  static Future<Map<String, dynamic>> triggerFullEmergency({
    double lat = 13.0827,
    double lng = 80.2707,
    int battery = 84,
    bool isSilent = false,
  }) async {
    final userName = await getUserName();
    final userId = await getUserId();
    final contacts = await getLocalContacts();

    // Compose distress message with live GPS
    final message = '🆘 EMERGENCY ALERT! $userName has triggered SOS! '
        'Location: https://maps.google.com/?q=$lat,$lng | Battery: $battery% — AlleyPilot';

    // ── STEP A: Native Mobile SIM SMS (Works offline with ZERO data) ──
    final nativeSmsLaunched = await sendNativeSimSms(
      recipients: contacts,
      message: message,
    );

    // ── STEP B: Cloud Backend Alert (WebSockets + Responders + SMS API) ──
    final cloudResponse = await ApiService.triggerCloudSOS(
      userId: userId,
      userName: userName,
      lat: lat,
      lng: lng,
      battery: battery,
      isSilent: isSilent,
    );

    return {
      'nativeSmsLaunched': nativeSmsLaunched,
      'cloudResponse': cloudResponse,
      'contactsAlerted': contacts.length,
    };
  }

  // 6. Find Nearest Police Station (Offline Local Haversine on Phone)
  static PoliceStation getNearestPoliceOffline(double lat, double lng) {
    return OfflinePoliceRepository.findNearestOffline(lat, lng);
  }
}

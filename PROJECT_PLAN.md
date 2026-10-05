# 🛡️ AlleyPilot — Complete Project Plan

> **A personal safety super-app** combining live location, SOS, stealth streaming, travel tracking, mesh networking, and AI-powered emergency response.

---

## 🏗️ Project Architecture

```
alleypilot/
├── mobile/          → Flutter App (Android + iOS)
├── backend/         → Node.js / FastAPI Server
├── frontend/        → React Admin Dashboard (Vite)
```

---

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | Node.js + Socket.IO + FastAPI (Python) |
| Database | Firebase Firestore + PostgreSQL |
| Real-time | WebSocket / WebRTC |
| Maps | Google Maps API / OpenStreetMap |
| Messaging | Twilio (SMS) / Firebase Cloud Messaging |
| Mesh Network | Bluetooth LE + WiFi Direct |
| Auth | Firebase Auth |
| Storage | Firebase Storage |

---

## Feature 1 — AlleyPilot Core: Verified Local User Network

**What it does:**
A geo-fenced verified community of nearby users who get alerted when someone needs help.

**How to build it:**
- User registers → OTP + Aadhaar/phone KYC verification
- App sends GPS coordinates to backend → stored in Firebase GeoFirestore
- Backend queries users within X km radius using GeoQuery
- When SOS fires → all verified users in radius get FCM push notification
- Night mode: cheaper SMS fallback instead of internet push

**Existing Files:**
- mobile/lib/screens/trust_network_screen.dart
- mobile/lib/services/api_service.dart

**Needs:**
- backend/routes/network.js (NEW)

---

## Feature 2 — SOS Button + Fake Call

**What it does:**
One-tap SOS alerts contacts + nearby users. Fake call makes it look like a real phone call.

**How to build it:**

SOS Button:
- Sends SMS via Twilio to all saved contacts with GPS link
- Sends FCM push to nearby verified users
- Starts background audio/video recording
- Uploads stream to Firebase Storage in real-time

Fake Call:
- Uses flutter_phone_state or native Android TelecomManager
- Displays a fake incoming call screen with vibration
- User can "answer" it → plays pre-recorded voice audio
- Looks 100% like a real call to anyone watching

**Existing Files:**
- mobile/lib/screens/sos_screen.dart
- mobile/lib/services/native_call_service.dart
- mobile/lib/services/background_service.dart

---

## Feature 3 — Operating Hours / Ghost Timer

**What it does:**
User sets "I'll be at Place A until Time X". If they don't check in by that time, auto-alert fires.

**How to build it:**
- User inputs destination + expected arrival time
- App runs a background countdown timer
- At T-5 min → sends push: "Are you safe? Tap to confirm"
- If no response by T+0 → auto-sends SOS with last known GPS to all contacts
- Uses flutter_background_service to keep timer alive even when app is closed
- Check-in options: button tap, voice word, or geofence arrival detection

**Existing Files:**
- mobile/lib/screens/ghost_timer_screen.dart
- mobile/lib/services/background_service.dart

---

## Feature 4 — Live Audio + Video Stealth Stream

**What it does:**
Phone looks normal/locked but secretly streams camera and mic audio to a secure server.

**How to build it:**
- Uses WebRTC peer-to-peer connection or RTMP to backend
- CameraController in Flutter starts in background (no preview shown to anyone nearby)
- Audio captured via flutter_sound package
- Stream sent to backend → relayed to guardian's browser/app via WebRTC
- Guardian opens a secure link (sent via WhatsApp/SMS) to watch live
- Screen shows a fake idle/black overlay using WillPopScope + overlay widget

**Existing Files:**
- mobile/lib/screens/stealth_screen.dart
- mobile/lib/services/video_stream_service.dart

---

## Feature 5 — Pacer: Volume Auto-Up on Door Open

**What it does:**
When phone detects a door opening (accelerometer/mic spike), it automatically raises volume to max as a loud deterrent.

**How to build it:**
- Use sensors_plus package → monitor accelerometer for sudden jolt pattern (door opening)
- Alternative: monitor microphone decibel level spike (door creak sound)
- On trigger → use volume_control plugin to set volume to max
- Optionally plays a loud alarm sound via audioplayers
- Runs continuously in background via background_service
- User can set sensitivity level: low / medium / high

**Existing Files:**
- mobile/lib/services/hardware_trigger.dart

**Needs:**
- mobile/lib/screens/pacer_settings_screen.dart (NEW)

---

## Feature 6 — Mesh GPS / Mesh Chat

**What it does:**
When there is NO internet, phones in range form a local mesh network via Bluetooth LE to pass messages and location.

**How to build it:**
- Use Bluetooth Low Energy (BLE) via flutter_blue_plus package
- Each phone acts as both advertiser and scanner
- SOS message is encoded as a BLE advertisement packet
- Nearby AlleyPilot phones receive it and relay it further (hop-by-hop)
- Eventually reaches a phone WITH internet → forwards to server
- WiFi Direct as fallback using nearby_connections package (Google Nearby API)

**Existing Files:**
- mobile/lib/screens/mesh_chat_screen.dart
- mobile/lib/screens/vehicle_mesh_screen.dart

**Needs:**
- mobile/lib/services/mesh_service.dart (NEW)

---

## Feature 7 — Travel Tracker: Bus and Train

**What it does:**
Real-time tracking of bus/train journeys. Registers the trip on a live board so guardians can monitor.

**How to build it:**

Bus:
- User selects route → app fetches route via GTFS API or government transport API
- GPS tracks current position on route
- Compares with expected stops → calculates ETA
- Guardian sees live dot on map

Train:
- User enters train number → fetch from Indian Railways API (RailYatri / NTES)
- Live train position updated every 2 minutes
- Alert if train is stopped unexpectedly for more than 10 minutes

Campline Register:
- When journey starts → entry logged in backend with passenger name, route, departure time, expected arrival
- Shared link sent to guardian

**Existing Files:**
- mobile/lib/screens/bus_tracker_screen.dart
- mobile/lib/screens/train_tracker_screen.dart
- mobile/lib/screens/transit_report_screen.dart

---

## Feature 8 — Travel Planner (RAG-based AI)

**What it does:**
AI-powered travel planning that suggests safest routes, timings, and transport modes using local safety data.

**How to build it:**
- Uses RAG (Retrieval Augmented Generation) — AI that knows local safety data
- Backend stores: crime reports, user safety ratings of areas, transport schedules
- User asks: "Best way from A to B at 10pm?"
- AI searches vector database → generates safe route recommendation
- Uses Gemini API or OpenAI for language + reasoning
- Data sources: local police reports, user submitted incidents, Google Maps data

**Existing Files:**
- mobile/lib/screens/travel_rag_screen.dart

**Needs:**
- backend/services/rag_service.py (NEW)

---

## Feature 9 — Live Location Share via WhatsApp, Telegram, Call

**What it does:**
Share live GPS location link via WhatsApp, Telegram, or voice call. Works even in low/no network.

**How to build it:**
- App generates a short link: alleypilot.app/track/xyz123
- Link opens a web page showing live moving dot on map
- Backend receives GPS pings every 5 seconds from phone
- Link shared via:
  - WhatsApp: url_launcher → whatsapp://send?text=...
  - Telegram: tg://msg?text=...
  - SMS: Twilio API (for no-internet fallback)
  - Call: reads out GPS coordinates via TTS if no data available
- No network fallback: Send location via SMS with raw coordinates

**Needs:**
- mobile/lib/screens/live_location_screen.dart (NEW)
- backend/routes/location.js (NEW)
- frontend/src/pages/LiveTrackingPage.jsx (NEW)

---

## Feature 10 — Phone Switch-Off Auto Alert

**What it does:**
The moment phone is switched off or battery dies, it automatically sends last known location to all emergency contacts.

**How to build it:**
- Register Android BroadcastReceiver for ACTION_SHUTDOWN
- On shutdown signal → immediately:
  - Fire SMS via Twilio (carrier-based, no internet needed)
  - Message: "[Name]'s phone just switched off. Last location: [GPS link]"
- For battery death: monitor battery level via battery_plus
  - At 5% → send alert: "Phone battery critical, may go offline soon"
  - At 2% → send final location alert
- Uses Android foreground service to ensure this runs even when app is killed

**Existing Files:**
- mobile/lib/services/background_service.dart

**Needs:**
- android/app/src/main/.../ShutdownReceiver.kt (NEW)

---

## Feature 11 — Low Battery Auto-Message to Emergency Contact

**What it does:**
At critically low battery, automatically sends current location and a safety message to stored emergency numbers.

**How to build it:**
- battery_plus plugin monitors battery percentage continuously in background
- User sets custom threshold (default: 10%)
- When threshold hit:
  - Fetch current GPS via geolocator
  - Compose message: "Hi, [Name] here. My battery is at X%. Current location: [link]. Please check on me."
  - Send via: SMS (Twilio) + WhatsApp + FCM notification to guardian app
- User can customize the auto-message text in settings
- Can set multiple contacts with different message priorities

**Existing Files:**
- mobile/lib/screens/guardian_settings_screen.dart

**Needs:**
- mobile/lib/services/battery_alert_service.dart (NEW)

---

## Feature 12 — Saved Safe Zones

**What it does:**
User marks locations as "Safe Zones" (home, college, office). App auto-alerts on enter or exit.

**How to build it:**
- User drops a pin on map → sets radius (e.g. 100m) → saves as safe zone
- Uses Geofencing API (geofence_service flutter package)
- On ENTER: silently logs "arrived safely" → notifies guardian
- On EXIT: starts a timer — if user doesn't confirm safe within X minutes → sends alert
- Night mode: exit from safe zone after 10pm → immediate alert to contacts
- Saved zones stored in Firebase Firestore per user

**Existing Files:**
- mobile/lib/screens/guardian_settings_screen.dart

**Needs:**
- mobile/lib/services/geofence_service.dart (NEW)

---

## Feature 13 — Voice Trigger Word

**What it does:**
A secret keyword spoken by user silently activates SOS — no screen touch needed, works when phone is locked.

**How to build it:**
- Uses on-device speech recognition via speech_to_text Flutter package
- Runs as a background microphone listener (very low CPU: keyword spotting only)
- Uses lightweight model like Porcupine Wake Word (Picovoice) for offline detection
- When trigger word detected:
  - Activates full SOS sequence (contacts, stream, location)
  - Does NOT show any visible change on screen (stays in stealth mode)
- User sets custom keyword in settings
- Works even when phone is locked (Android accessibility service)

**Needs:**
- mobile/lib/services/voice_trigger_service.dart (NEW)
- mobile/lib/screens/voice_settings_screen.dart (NEW)

---

## Feature 14 — Offline Help Mode: Nearest Police CSP

**What it does:**
When completely offline, app contacts the nearest Police Common Service Point or police station via any available channel.

**How to build it:**
- App stores a local SQLite database of all police stations with coordinates (pre-downloaded at install)
- When offline SOS triggered:
  - Finds nearest police station using Haversine formula on local data (no internet needed)
  - Tries channels in order:
    1. SMS (works without data) → send location + SOS to station number
    2. BLE Mesh → propagate SOS to nearby AlleyPilot users
    3. WiFi Direct → connect to any nearby device with internet
  - Shows user: "Contacting [Station Name] - [X km away]"

**Needs:**
- mobile/lib/services/offline_sos_service.dart (NEW)
- assets/police_stations.db (NEW — pre-loaded SQLite data)

---

## Feature 15 — Live Companion Mode

**What it does:**
A trusted contact gets a live dashboard showing your real-time location, battery %, and can trigger remote SOS on your behalf.

**How to build it:**
- User invites a companion via link or code → companion opens web link (no app install needed)
- Companion dashboard shows:
  - Live GPS on map (updates every 5 seconds)
  - Battery percentage
  - Last activity timestamp
  - Movement trail (breadcrumb path)
- Companion can:
  - Send a check-in ping to user
  - Trigger SOS remotely if user is unresponsive
  - See geofence enter/exit events in real-time
- Backend: WebSocket channel between user phone and companion dashboard

**Existing Files:**
- mobile/lib/screens/live_companion_screen.dart

**Needs:**
- backend/routes/companion.js (NEW)
- frontend/src/pages/CompanionDashboard.jsx (NEW)

---

## Development Phases

| Phase | Features | Timeline |
|-------|----------|----------|
| Phase 1 — Core Safety | SOS, Fake Call, Ghost Timer, Live Location | Week 1-2 |
| Phase 2 — Stealth | Stealth Stream, Voice Trigger, Pacer | Week 3-4 |
| Phase 3 — Network | Verified Network, Safe Zones, Battery Alert | Week 5-6 |
| Phase 4 — Travel | Bus/Train Tracker, Travel Planner (RAG) | Week 7-8 |
| Phase 5 — Offline | Mesh GPS, Offline CSP Alert, Switch-Off Alert | Week 9-10 |
| Phase 6 — Companion | Live Companion Dashboard, Admin Frontend | Week 11-12 |

---

## New Files To Create

| File | Purpose |
|------|---------|
| mobile/lib/screens/live_location_screen.dart | Live location sharing UI |
| mobile/lib/screens/pacer_settings_screen.dart | Pacer sensitivity settings |
| mobile/lib/screens/voice_settings_screen.dart | Voice trigger word setup |
| mobile/lib/services/mesh_service.dart | BLE mesh network logic |
| mobile/lib/services/battery_alert_service.dart | Low battery auto-alert |
| mobile/lib/services/geofence_service.dart | Safe zone geofencing |
| mobile/lib/services/voice_trigger_service.dart | Background voice detection |
| mobile/lib/services/offline_sos_service.dart | Offline police CSP contact |
| backend/routes/location.js | Live location websocket API |
| backend/routes/companion.js | Companion dashboard API |
| backend/routes/network.js | Verified user network API |
| backend/services/rag_service.py | AI travel planner RAG engine |
| android/.../ShutdownReceiver.kt | Phone shutdown BroadcastReceiver |
| assets/police_stations.db | Offline police station database |
| frontend/src/pages/CompanionDashboard.jsx | Web companion live view |

---

## Key Challenges and Solutions

| Challenge | Solution |
|-----------|---------|
| Background process killed by OS | Android Foreground Service + Doze Mode exemption |
| No internet for SOS | SMS via Twilio (carrier-based, no data needed) |
| Stealth stream detection | Overlay service + locked screen mode |
| BLE range limit (~100m) | Multi-hop relay through chain of AlleyPilot users |
| Voice detection battery drain | Keyword spotting (Porcupine) — uses less than 1% CPU |
| Police CSP data freshness | Quarterly update via app update + local SQLite |

---

Last Updated: September 2026 | Version: 1.0

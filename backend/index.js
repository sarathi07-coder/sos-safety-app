// ============================================================
// AlleyPilot SOS Backend — index.js
// Handles: SOS alerts, Ghost Timer, Emergency Contacts, GPS streaming
// ============================================================

// 1. Import tools
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config();

// 2. Initialize Express app and HTTP server
const app = express();
const server = http.createServer(app);

// 3. Middlewares
app.use(cors({ origin: '*' }));   // Allow frontend clients from any origin
app.use(express.json());          // Parse JSON request bodies

// 4. Attach Socket.IO for real-time communication
const io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] }
});

// ============================================================
// 🗄️ IN-MEMORY DATA STORES (No database needed yet)
// ============================================================
const activeIncidents = new Map(); // { userId -> incident object }
const activeTimers = new Map();    // { userId -> { timeoutId, expiresAt, ... } }
const userContacts = new Map();    // { userId -> ['+91XXXXXXXXXX', ...] }


// ============================================================
// 🛣️ REST API ROUTES
// ============================================================

// ─── ROUTE 1: Health Check ───────────────────────────────
// Purpose: Verify the server is alive and responding
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ONLINE',
        message: 'AlleyPilot SOS Backend is running',
        activeIncidents: activeIncidents.size,
        activeTimers: activeTimers.size,
        timestamp: new Date().toISOString()
    });
});

// ─── ROUTE 2: Trigger SOS Emergency ─────────────────────
// Purpose: Receive a distress signal, store it, broadcast to all dashboards
app.post('/api/sos', (req, res) => {
    const { userId, userName, lat, lng, battery } = req.body;

    const incident = {
        id: `inc_${Date.now()}`,
        userId: userId || 'anonymous_user',
        userName: userName || 'Someone in distress',
        lat: Number(lat) || 12.9716,
        lng: Number(lng) || 77.5946,
        battery: battery !== undefined ? Number(battery) : 100,
        timestamp: new Date().toLocaleTimeString(),
        status: 'ACTIVE_EMERGENCY'
    };

    activeIncidents.set(incident.userId, incident);

    // Broadcast to all connected web dashboards instantly
    io.emit('emergency:alert', incident);

    console.log(`🚨 [SOS FIRED] ${incident.userName} | Lat: ${incident.lat}, Lng: ${incident.lng}`);

    res.status(201).json({
        success: true,
        message: 'Emergency broadcast dispatched to all responders',
        incident
    });
});

// ─── ROUTE 3: List All Active Emergencies ────────────────
// Purpose: Let the dashboard load current emergencies on page open
app.get('/api/sos/active', (req, res) => {
    const list = Array.from(activeIncidents.values());
    res.json({ success: true, count: list.length, incidents: list });
});

// ─── ROUTE 4: Resolve/Dismiss an Incident ───────────────
// Purpose: When user is safe, stop the alarm on all dashboards
app.post('/api/sos/resolve', (req, res) => {
    const { userId, resolvedBy } = req.body;

    if (!userId) {
        return res.status(400).json({ success: false, message: 'userId is required' });
    }

    if (activeIncidents.has(userId)) {
        activeIncidents.delete(userId);

        // Tell all connected dashboards to stop the alarm
        io.emit('emergency:resolved', {
            userId,
            resolvedBy: resolvedBy || 'Responder',
            resolvedAt: new Date().toLocaleTimeString()
        });

        console.log(`✅ [INCIDENT RESOLVED] User ${userId} marked safe.`);
        return res.json({ success: true, message: 'Incident resolved. Dashboards notified.' });
    }

    res.status(404).json({ success: false, message: 'No active incident found for this user.' });
});


// ─── ROUTE 5: Start Ghost Safety Timer ──────────────────
// Purpose: User sets a countdown — if they miss check-in, auto-SOS fires
app.post('/api/timer/start', (req, res) => {
    const { userId, userName, durationMinutes, lat, lng } = req.body;
    const durationMs = (Number(durationMinutes) || 10) * 60 * 1000;
    const expiresAt = new Date(Date.now() + durationMs);

    // Cancel any existing timer for this user first
    if (activeTimers.has(userId)) {
        clearTimeout(activeTimers.get(userId).timeoutId);
    }

    // Auto-escalate to SOS when the timer hits zero
    const timeoutId = setTimeout(() => {
        console.log(`⏰ [TIMER EXPIRED] ${userName || userId} missed check-in! Auto-SOS firing.`);

        const incident = {
            id: `inc_timer_${Date.now()}`,
            userId,
            userName: `${userName || 'User'} (Ghost Timer Expired)`,
            lat: Number(lat) || 12.9716,
            lng: Number(lng) || 77.5946,
            battery: 50,
            status: 'ACTIVE_EMERGENCY',
            timestamp: new Date().toLocaleTimeString()
        };

        activeIncidents.set(userId, incident);
        io.emit('emergency:alert', incident); // Auto-broadcast SOS!
        activeTimers.delete(userId);
    }, durationMs);

    activeTimers.set(userId, { timeoutId, expiresAt, userName, lat, lng });
    console.log(`⏱️ Timer started for ${userName}: ${durationMinutes} min (expires ${expiresAt.toLocaleTimeString()})`);

    res.json({
        success: true,
        message: `Safety timer active for ${durationMinutes} minutes`,
        expiresAt: expiresAt.toLocaleTimeString()
    });
});

// ─── ROUTE 6: User Checks In Safely ─────────────────────
// Purpose: Cancel the timer when user confirms they are safe
app.post('/api/timer/checkin', (req, res) => {
    const { userId } = req.body;

    if (activeTimers.has(userId)) {
        clearTimeout(activeTimers.get(userId).timeoutId);
        activeTimers.delete(userId);
        console.log(`✅ [TIMER CANCELLED] ${userId} checked in safely.`);
        return res.json({ success: true, message: 'Checked in safely! Timer cancelled.' });
    }

    res.status(404).json({ success: false, message: 'No active timer found for this user.' });
});

// ─── ROUTE 7: Get Timer Status (How much time left?) ─────
// Purpose: Frontend can display a live countdown to the user
app.get('/api/timer/:userId', (req, res) => {
    const { userId } = req.params;

    if (activeTimers.has(userId)) {
        const timer = activeTimers.get(userId);
        const remainingSeconds = Math.max(0, Math.round((timer.expiresAt.getTime() - Date.now()) / 1000));
        return res.json({
            active: true,
            expiresAt: timer.expiresAt.toLocaleTimeString(),
            remainingSeconds,
            remainingMinutes: Math.ceil(remainingSeconds / 60)
        });
    }

    res.json({ active: false, remainingSeconds: 0 });
});


// ─── ROUTE 8: Save Emergency Contacts ───────────────────
// Purpose: Store which phone numbers to alert when user triggers SOS
app.post('/api/contacts', (req, res) => {
    const { userId, contacts } = req.body; // contacts: ['+919876543210', ...]

    if (!userId || !Array.isArray(contacts)) {
        return res.status(400).json({ success: false, message: 'userId and contacts array required' });
    }

    userContacts.set(userId, contacts);
    console.log(`📞 Emergency contacts saved for ${userId}: ${contacts.join(', ')}`);

    res.json({ success: true, message: 'Emergency contacts saved', contacts });
});

// ─── ROUTE 9: Get Emergency Contacts ─────────────────────
// Purpose: Retrieve saved emergency contacts for a user
app.get('/api/contacts/:userId', (req, res) => {
    const contacts = userContacts.get(req.params.userId) || [];
    res.json({ success: true, contacts });
});


// ============================================================
// ⚡ SOCKET.IO — REAL-TIME GATEWAY (WebSockets)
// ============================================================
io.on('connection', (socket) => {
    console.log(`🔌 [CONNECTED] Socket ID: ${socket.id}`);

    // Mobile device / simulator streams live GPS coordinates
    socket.on('gps:update', (data) => {
        // data: { userId, lat, lng, battery }
        console.log(`📍 GPS from ${data.userId || 'device'}: ${data.lat}, ${data.lng}`);

        // Relay coordinates to all connected dashboards (frontend map moves!)
        io.emit('gps:live', data);
    });

    // Companion/Guardian joins a tracking room for a specific user
    socket.on('companion:join', (userId) => {
        socket.join(`user_${userId}`);
        console.log(`👁️ Companion ${socket.id} watching user_${userId}`);

        // Send them the current state immediately
        if (activeIncidents.has(userId)) {
            socket.emit('emergency:alert', activeIncidents.get(userId));
        }
    });

    socket.on('disconnect', () => {
        console.log(`❌ [DISCONNECTED] Socket ID: ${socket.id}`);
    });
});


// ============================================================
// 🚀 START SERVER
// ============================================================
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(`🛡️  AlleyPilot Backend — Port ${PORT}`);
    console.log(`📡 WebSocket: Live GPS & SOS streaming ready`);
    console.log(`🔗 Health:    http://localhost:${PORT}/api/health`);
    console.log(`📋 Routes:    /api/sos  /api/timer  /api/contacts`);
    console.log(`===============================================`);
});

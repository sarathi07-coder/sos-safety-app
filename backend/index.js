// 1. Import our tools
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
require('dotenv').config(); // Load variables from .env

// 2. Initialize Express app and HTTP server
const app = express();
const server = http.createServer(app);

// 3. Middlewares (Helpers that process incoming requests)
app.use(cors({ origin: '*' })); // Allow any frontend client to connect
app.use(express.json());        // Allows our server to read JSON bodies from POST requests

// 4. Attach Socket.IO to our HTTP server
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    }
});

// In-Memory store for active distress incidents (replaces database for now)
const activeIncidents = new Map();

// ==========================================
// 🛣️ REST API ROUTES (Standard HTTP)
// ==========================================

// Route 1: Health check (Use this to verify the server is alive)
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ONLINE',
        message: 'AlleyPilot SOS Backend is running smoothly',
        timestamp: new Date().toISOString()
    });
});

// Route 2: Trigger SOS Emergency
app.post('/api/sos', (req, res) => {
    const { userId, userName, lat, lng, battery } = req.body;

    // Validate incoming data
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

    // Store in memory
    activeIncidents.set(incident.userId, incident);

    // 🚨 BROADCAST TO FRONTEND OVER WEBSOCKET IMMEDIATELY
    io.emit('emergency:alert', incident);

    console.log(`🚨 [SOS FIRED] ${incident.userName} at Lat: ${incident.lat}, Lng: ${incident.lng}`);

    // Respond to the caller
    res.status(201).json({
        success: true,
        message: 'Emergency broadcast dispatched to all responders',
        incident
    });
});

// Route 3: List all active emergencies
app.get('/api/sos/active', (req, res) => {
    const list = Array.from(activeIncidents.values());
    res.json({ success: true, count: list.length, incidents: list });
});

// ==========================================
// ⚡ SOCKET.IO REAL-TIME GATEWAY (WebSockets)
// ==========================================

io.on('connection', (socket) => {
    console.log(`🔌 [NEW CLIENT CONNECTED] Socket ID: ${socket.id}`);

    // When a mobile phone or simulator sends updated GPS coordinates:
    socket.on('gps:update', (data) => {
        // data contains: { userId, lat, lng, battery }
        console.log(`📍 GPS ping from ${data.userId || 'device'}: ${data.lat}, ${data.lng}`);

        // Broadcast the new coordinates to your friend's frontend map!
        io.emit('gps:live', data);
    });

    // When client disconnects
    socket.on('disconnect', () => {
        console.log(`❌ [CLIENT DISCONNECTED] Socket ID: ${socket.id}`);
    });
});

// ==========================================
// 🚀 START LISTENING FOR TRAFFIC
// ==========================================
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(`🛡️  AlleyPilot Backend Server running on port ${PORT}`);
    console.log(`📡 WebSocket ready for live GPS tracking`);
    console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
    console.log(`===============================================`);
});

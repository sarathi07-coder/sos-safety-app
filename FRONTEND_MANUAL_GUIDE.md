# 🎨 Frontend Manual Setup Guide (From Scratch)

> **For:** Developer 2 (Frontend Developer)  
> **Purpose:** Build the Emergency Companion & Live Tracking Web Dashboard completely **manually**, step by step. No automated scripts required.  
> **Tech Stack:** React (Vite) + Leaflet Maps + Socket.IO Client + Lucide Icons  

---

## 📋 Overview of What You Will Do
1. Initialize a clean Vite + React app from your terminal.
2. Install the 4 essential libraries (`socket.io-client`, `leaflet`, `react-leaflet`, `lucide-react`).
3. Set up the environment configuration (`.env`).
4. Set up the WebSocket communication service (`src/services/socket.js`).
5. Configure the Leaflet map styles (`src/index.css` & `src/main.jsx`).
6. Write the Emergency Dashboard component (`src/App.jsx`).
7. Run and test the app with Developer 1's backend.

---

## 💻 STEP 1: Terminal Setup & Package Installation

Open your terminal and follow these commands one by one:

### 1.1 — Go to the project root directory
```bash
cd /Users/sarathi/Documents/sos
```

---

### 1.2 — Create the fresh Vite React app
Run this command to scaffold the React frontend:
```bash
npx -y create-vite@latest frontend --template react
```
> **What this does:** Creates a brand-new folder named `frontend` pre-configured with React and Vite.

---

### 1.3 — Enter the frontend folder
```bash
cd frontend
```

---

### 1.4 — Install default dependencies
```bash
npm install
```
> **What this does:** Installs React, React DOM, and the Vite development server into `frontend/node_modules/`.

---

### 1.5 — Install the 4 specialized packages
```bash
npm install socket.io-client leaflet react-leaflet lucide-react
```
> **What each package is for:**
> - `socket.io-client`: Connects the browser live to Developer 1's backend WebSocket.
> - `leaflet`: Interactive mapping engine (uses free OpenStreetMap, no Google API keys needed).
> - `react-leaflet`: React components for Leaflet (`<MapContainer>`, `<TileLayer>`, `<Marker>`).
> - `lucide-react`: Modern SVG icons (Radio, Battery, ShieldAlert, etc.).

---

## 🗂️ STEP 2: Create Folders and Files Manually

Inside `frontend/`, create the `services` directory:
```bash
mkdir -p src/services
```

Now you will create or edit **5 specific files**.

---

### 📄 FILE 1: `frontend/.env` (Backend Server URL)
In the `frontend` root folder, create a file named `.env`:
```bash
touch .env
```
Open `frontend/.env` and paste this exact line:
```ini
VITE_BACKEND_URL=http://localhost:3000
```
> *(Note: If Developer 1 is running on a different laptop on the same WiFi, replace `localhost` with their IP address, e.g., `http://192.168.1.15:3000`)*

---

### 📄 FILE 2: `frontend/src/services/socket.js` (WebSocket Client)
Create a new file at `src/services/socket.js`:
```bash
touch src/services/socket.js
```
Open `src/services/socket.js` and paste this code:
```javascript
import { io } from 'socket.io-client';

// Read the backend URL from .env or default to localhost:3000
const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3000';

// Create a single shared socket connection
export const socket = io(BACKEND_URL, {
  autoConnect: true,
  reconnection: true,
  reconnectionAttempts: 5,
  reconnectionDelay: 1000,
});
```

---

### 📄 FILE 3: `frontend/src/index.css` (Styles & Fullscreen Map)
Open the existing file `src/index.css`, **delete everything inside it**, and replace it with:
```css
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body, html, #root {
  height: 100%;
  width: 100%;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  background-color: #0d0f12;
  color: #f3f4f6;
  overflow: hidden;
}

/* Mandatory: Leaflet map container must have explicit height */
.leaflet-container {
  height: 100%;
  width: 100%;
  background-color: #1a1d24;
}
```

---

### 📄 FILE 4: `frontend/src/main.jsx` (Import Leaflet Styles)
Open the existing file `src/main.jsx` and replace its entire content with:
```javascript
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';

// CRITICAL: Leaflet CSS must be imported so map tiles and controls display properly
import 'leaflet/dist/leaflet.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
```

---

### 📄 FILE 5: `frontend/src/App.jsx` (The Main Dashboard UI)
Open `src/App.jsx`, **delete everything inside it**, and replace it with this complete dashboard:

```jsx
import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import { socket } from './services/socket';
import { ShieldAlert, Radio, Battery, Wifi, WifiOff, Navigation, AlertTriangle } from 'lucide-react';

// Fix for missing default marker icons in Leaflet + Vite
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

// Red marker pin for active SOS emergency
const emergencyPin = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
});

// Helper component that auto-centers map when coordinates change
function RecenterMap({ lat, lng }) {
  const map = useMap();
  useEffect(() => {
    if (lat && lng) {
      map.flyTo([lat, lng], 15, { duration: 1.2 });
    }
  }, [lat, lng, map]);
  return null;
}

export default function App() {
  const [isConnected, setIsConnected] = useState(socket.connected);
  const [coords, setCoords] = useState({ lat: 12.9716, lng: 77.5946 });
  const [battery, setBattery] = useState(88);
  const [activeSOS, setActiveSOS] = useState(null);

  // Play audio distress chime using browser Web Audio API
  const playDistressSound = () => {
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(880, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(440, ctx.currentTime + 0.4);
      gain.gain.setValueAtTime(0.25, ctx.currentTime);
      gain.gain.linearRampToValueAtTime(0, ctx.currentTime + 0.5);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 0.5);
    } catch (e) {
      console.warn('Audio feedback blocked by browser:', e);
    }
  };

  useEffect(() => {
    // 1. Connection events
    socket.on('connect', () => setIsConnected(true));
    socket.on('disconnect', () => setIsConnected(false));

    // 2. Real-time GPS stream listener
    socket.on('gps:live', (data) => {
      if (data.lat && data.lng) {
        setCoords({ lat: Number(data.lat), lng: Number(data.lng) });
      }
      if (data.battery !== undefined) setBattery(data.battery);
    });

    // 3. Incoming SOS distress alert listener
    socket.on('emergency:alert', (incident) => {
      setActiveSOS(incident);
      if (incident.lat && incident.lng) {
        setCoords({ lat: Number(incident.lat), lng: Number(incident.lng) });
      }
      playDistressSound();
    });

    // 4. Incident resolved listener
    socket.on('emergency:resolved', () => {
      setActiveSOS(null);
    });

    return () => {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('gps:live');
      socket.off('emergency:alert');
      socket.off('emergency:resolved');
    };
  }, []);

  // Simulate SOS Trigger button (sends POST to Developer 1's backend)
  const handleSimulateSOS = async () => {
    const backendUrl = import.meta.env.VITE_BACKEND_URL || 'http://localhost:3000';
    try {
      await fetch(`${backendUrl}/api/sos`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: 'test_user_01',
          userName: 'Demo User (Emergency)',
          lat: coords.lat + (Math.random() - 0.5) * 0.008,
          lng: coords.lng + (Math.random() - 0.5) * 0.008,
          battery: 18,
          emergencyContacts: ['+919876543210']
        })
      });
    } catch (err) {
      alert(`Could not reach backend at ${backendUrl}. Make sure Developer 1 is running "npm run dev" in the backend!`);
    }
  };

  // Simulate moving GPS (sends WebSocket ping to Developer 1's backend)
  const handleSimulateMove = () => {
    const nextCoords = {
      userId: 'test_user_01',
      lat: coords.lat + 0.001,
      lng: coords.lng + 0.001,
      battery: Math.max(1, battery - 1)
    };
    socket.emit('gps:update', nextCoords);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', width: '100vw' }}>
      
      {/* ── TOP HEADER ── */}
      <header style={{
        background: '#13151b',
        borderBottom: '1px solid #232733',
        padding: '12px 24px',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        zIndex: 1000
      }}>
        {/* Brand */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{
            background: activeSOS ? '#dc2626' : '#2563eb',
            padding: '8px',
            borderRadius: '8px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            transition: 'background 0.3s'
          }}>
            <Radio size={20} color="#fff" />
          </div>
          <div>
            <h1 style={{ fontSize: '1.05rem', fontWeight: 700, margin: 0 }}>
              AlleyPilot — Emergency Response Dashboard
            </h1>
            <p style={{ fontSize: '0.75rem', color: '#9ca3af', margin: 0 }}>
              Live Companion & Real-Time Tracking
            </p>
          </div>
        </div>

        {/* Telemetry & Actions */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          {/* Backend Status Badge */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '0.8rem',
            padding: '4px 10px',
            borderRadius: '12px',
            background: isConnected ? '#064e3b' : '#7f1d1d',
            color: isConnected ? '#34d399' : '#f87171',
            fontWeight: 500
          }}>
            {isConnected ? <Wifi size={14} /> : <WifiOff size={14} />}
            {isConnected ? 'Backend Online' : 'Backend Offline'}
          </div>

          {/* Battery */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '0.85rem',
            padding: '4px 10px',
            borderRadius: '12px',
            background: '#1f2430'
          }}>
            <Battery size={16} color={battery < 20 ? '#ef4444' : '#10b981'} />
            <span>{battery}%</span>
          </div>

          {/* Simulate Move Button */}
          <button
            onClick={handleSimulateMove}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 14px',
              background: '#2563eb',
              color: '#fff',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              fontWeight: 600,
              fontSize: '0.8rem'
            }}>
            <Navigation size={14} /> Move GPS
          </button>

          {/* Simulate SOS Button */}
          <button
            onClick={handleSimulateSOS}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 14px',
              background: '#dc2626',
              color: '#fff',
              border: 'none',
              borderRadius: '6px',
              cursor: 'pointer',
              fontWeight: 700,
              fontSize: '0.8rem',
              boxShadow: '0 0 10px rgba(220, 38, 38, 0.4)'
            }}>
            <ShieldAlert size={14} /> Trigger SOS Alert
          </button>
        </div>
      </header>

      {/* ── ACTIVE EMERGENCY BANNER ── */}
      {activeSOS && (
        <div style={{
          background: 'linear-gradient(90deg, #991b1b, #dc2626)',
          padding: '12px 24px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          boxShadow: '0 4px 12px rgba(0,0,0,0.4)',
          zIndex: 999
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <AlertTriangle size={24} color="#fff" />
            <div>
              <strong style={{ fontSize: '0.95rem' }}>
                🚨 DISTRESS ALERT ACTIVATED: {activeSOS.userName}
              </strong>
              <div style={{ fontSize: '0.8rem', color: '#fecaca' }}>
                Time: {activeSOS.timestamp || 'Just now'} • Battery: {activeSOS.battery}% • Lat: {Number(activeSOS.lat).toFixed(4)}, Lng: {Number(activeSOS.lng).toFixed(4)}
              </div>
            </div>
          </div>
          <button
            onClick={() => setActiveSOS(null)}
            style={{
              background: 'rgba(255,255,255,0.2)',
              border: '1px solid rgba(255,255,255,0.4)',
              color: '#fff',
              padding: '4px 12px',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '0.8rem'
            }}>
            Dismiss Alert
          </button>
        </div>
      )}

      {/* ── INTERACTIVE LEAFLET MAP ── */}
      <div style={{ flex: 1, position: 'relative' }}>
        <MapContainer
          center={[coords.lat, coords.lng]}
          zoom={14}
          zoomControl={true}
          style={{ height: '100%', width: '100%' }}>
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <Marker
            position={[coords.lat, coords.lng]}
            icon={activeSOS ? emergencyPin : new L.Icon.Default()}>
            <Popup>
              <div style={{ color: '#111', fontSize: '0.85rem' }}>
                <strong>{activeSOS ? '🚨 Emergency Location' : '👤 Tracked User'}</strong>
                <br />
                Lat: {coords.lat.toFixed(5)}
                <br />
                Lng: {coords.lng.toFixed(5)}
                <br />
                Battery: {battery}%
              </div>
            </Popup>
          </Marker>
          <RecenterMap lat={coords.lat} lng={coords.lng} />
        </MapContainer>
      </div>

    </div>
  );
}
```

---

## 🏃 STEP 3: Run and Test

### 3.1 — Start the Frontend Development Server
From inside `frontend/`, run:
```bash
npm run dev
```

You will see:
```
  VITE v6.x.x  ready in 150 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

---

### 3.2 — Open in Your Browser
Visit **`http://localhost:5173`**.

1. Look at the top badge:
   - If Developer 1 is running the backend, it will show **"Backend Online"** in green!
   - If offline, it will show "Backend Offline" in red.
2. Click **"Trigger SOS Alert"**:
   - The audio alarm sounds.
   - The top banner flashes bright red with distress details.
   - The map marker turns into a red emergency pin.
3. Click **"Move GPS"**:
   - The map marker moves to new coordinates in real time.

---

## 🤝 Summary Checklist
- [ ] `cd /Users/sarathi/Documents/sos/frontend`
- [ ] `npm install` complete
- [ ] `npm install socket.io-client leaflet react-leaflet lucide-react` complete
- [ ] `.env` created with `VITE_BACKEND_URL=http://localhost:3000`
- [ ] `src/services/socket.js` created
- [ ] `src/index.css` updated
- [ ] `src/main.jsx` updated with Leaflet CSS
- [ ] `src/App.jsx` updated with Dashboard code
- [ ] `npm run dev` running on `http://localhost:5173`

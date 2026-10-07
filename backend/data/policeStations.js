// ============================================================
// AlleyPilot — Police Station Dataset (Tamil Nadu / Regional)
// Supports offline SQLite caching and delta sync (Chennai -> Kanchipuram)
// ============================================================

const policeStations = [
    // ── CHENNAI DISTRICT ──────────────────────────────────────
    {
        id: 'ps_chn_01',
        name: 'Anna Nagar Police Station (K-4)',
        district: 'Chennai',
        state: 'Tamil Nadu',
        lat: 13.0850,
        lng: 80.2101,
        phone: '044-23452601',
        controlRoom: '112',
        address: '2nd Avenue, Anna Nagar, Chennai'
    },
    {
        id: 'ps_chn_02',
        name: 'T. Nagar Police Station (R-1)',
        district: 'Chennai',
        state: 'Tamil Nadu',
        lat: 13.0418,
        lng: 80.2341,
        phone: '044-23452580',
        controlRoom: '112',
        address: 'Natesan Park Rd, T. Nagar, Chennai'
    },
    {
        id: 'ps_chn_03',
        name: 'Mylapore Police Station (E-1)',
        district: 'Chennai',
        state: 'Tamil Nadu',
        lat: 13.0368,
        lng: 80.2676,
        phone: '044-23452570',
        controlRoom: '112',
        address: 'Kutchery Road, Mylapore, Chennai'
    },
    {
        id: 'ps_chn_04',
        name: 'Guindy Police Station (J-3)',
        district: 'Chennai',
        state: 'Tamil Nadu',
        lat: 13.0067,
        lng: 80.2025,
        phone: '044-23452595',
        controlRoom: '112',
        address: 'Race Course Rd, Guindy, Chennai'
    },
    {
        id: 'ps_chn_05',
        name: 'Tambaram Police Station',
        district: 'Chennai',
        state: 'Tamil Nadu',
        lat: 12.9249,
        lng: 80.1000,
        phone: '044-22266100',
        controlRoom: '112',
        address: 'GST Road, Tambaram, Chennai'
    },

    // ── KANCHIPURAM DISTRICT ──────────────────────────────────
    {
        id: 'ps_kan_01',
        name: 'Kanchipuram Taluk Police Station',
        district: 'Kanchipuram',
        state: 'Tamil Nadu',
        lat: 12.8342,
        lng: 79.7036,
        phone: '044-27222300',
        controlRoom: '112',
        address: 'Kamarajar Salai, Kanchipuram'
    },
    {
        id: 'ps_kan_02',
        name: 'Kanchipuram Town Police Station (B-1)',
        district: 'Kanchipuram',
        state: 'Tamil Nadu',
        lat: 12.8385,
        lng: 79.7015,
        phone: '044-27222100',
        controlRoom: '112',
        address: 'Gandhi Road, Kanchipuram'
    },
    {
        id: 'ps_kan_03',
        name: 'Sriperumbudur Police Station',
        district: 'Kanchipuram',
        state: 'Tamil Nadu',
        lat: 12.9734,
        lng: 79.9436,
        phone: '044-27162233',
        controlRoom: '112',
        address: 'Bangalore Highway, Sriperumbudur'
    },
    {
        id: 'ps_kan_04',
        name: 'Walajabad Police Station',
        district: 'Kanchipuram',
        state: 'Tamil Nadu',
        lat: 12.7936,
        lng: 79.8228,
        phone: '044-27256221',
        controlRoom: '112',
        address: 'Bazaar Street, Walajabad'
    },
    {
        id: 'ps_kan_05',
        name: 'Sunguvarchatram Police Station',
        district: 'Kanchipuram',
        state: 'Tamil Nadu',
        lat: 12.9348,
        lng: 79.8512,
        phone: '044-27165440',
        controlRoom: '112',
        address: 'SIPCOT Industrial Park, Sunguvarchatram'
    }
];

// Haversine formula to compute distance in Kilometers
function calculateDistanceKm(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

// Find nearest station
function findNearestStation(userLat, userLng) {
    let nearest = null;
    let minDistance = Infinity;

    for (const station of policeStations) {
        const dist = calculateDistanceKm(userLat, userLng, station.lat, station.lng);
        if (dist < minDistance) {
            minDistance = dist;
            nearest = { ...station, distanceKm: Math.round(dist * 10) / 10 };
        }
    }

    return nearest;
}

module.exports = {
    policeStations,
    calculateDistanceKm,
    findNearestStation
};

// ============================================================
// AlleyPilot — services/smsService.js
// Dispatches real SMS alerts via Fast2SMS (Free Indian SMS API)
// ============================================================

const axios = require('axios');

/**
 * Sends an emergency SMS to a list of phone numbers.
 *
 * @param {string[]} numbers  - Array of Indian mobile numbers WITHOUT +91 prefix
 *                              Example: ['9876543210', '9123456789']
 * @param {string}   message  - The SMS text to send (max 160 characters for single SMS)
 * @returns {Promise<object>} - Result object with success flag
 */
async function sendEmergencySMS({ numbers, message }) {
    const apiKey = process.env.FAST2SMS_API_KEY;

    // ── MOCK MODE ─────────────────────────────────────────────
    // If no API key is set, log to terminal instead of sending real SMS.
    // This lets you develop and test without spending any credits.
    if (!apiKey || apiKey === 'your_fast2sms_api_key_here') {
        console.log('');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('📡 [MOCK SMS — No API key set]');
        console.log(`📞 To: ${numbers.join(', ')}`);
        console.log(`📝 Message: "${message}"`);
        console.log('ℹ️  Add FAST2SMS_API_KEY to .env to send real SMS');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('');
        return { success: true, mode: 'mock' };
    }

    // ── REAL SMS MODE ──────────────────────────────────────────
    // Strip +91 prefix if present — Fast2SMS expects 10-digit numbers
    const cleanNumbers = numbers.map(n => String(n).replace(/^\+91/, '').trim());

    try {
        const response = await axios.get('https://www.fast2sms.com/dev/bulkV2', {
            params: {
                authorization: apiKey,
                numbers: cleanNumbers.join(','),
                message: message,
                route: 'q',        // 'q' = Quick Transactional route (fastest delivery)
                flash: '0'         // 0 = Normal SMS, 1 = Flash SMS (pops up instantly)
            },
            timeout: 8000          // 8 second timeout for SMS API
        });

        if (response.data && response.data.return === true) {
            console.log(`✅ [SMS SENT] To: ${cleanNumbers.join(', ')} | Request ID: ${response.data.request_id}`);
            return { success: true, mode: 'real', data: response.data };
        } else {
            console.warn('⚠️ Fast2SMS responded but returned failure:', response.data);
            return { success: false, mode: 'real', error: response.data?.message || 'Unknown error' };
        }

    } catch (error) {
        const errMsg = error.response?.data?.message || error.message || 'Network error';
        console.error(`❌ [SMS FAILED] Could not send to ${cleanNumbers.join(', ')}: ${errMsg}`);
        return { success: false, mode: 'real', error: errMsg };
    }
}

/**
 * Builds the standard SOS alert message text.
 *
 * @param {string} userName  - Name of the distressed user
 * @param {number} lat       - Latitude
 * @param {number} lng       - Longitude
 * @param {number} battery   - Battery percentage
 * @returns {string}         - The complete SMS text
 */
function buildSOSMessage(userName, lat, lng, battery) {
    const mapsLink = `https://maps.google.com/?q=${lat},${lng}`;
    return `🆘 EMERGENCY ALERT! ${userName} has triggered an SOS and needs immediate help!` +
           ` Location: ${mapsLink}` +
           ` | Battery: ${battery}%` +
           ` | Time: ${new Date().toLocaleTimeString()}` +
           ` — AlleyPilot Safety App`;
}

module.exports = { sendEmergencySMS, buildSOSMessage };

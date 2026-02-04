# PC Controller Audio API

WebSocket API for controlling audio devices and sessions on Windows.

## WebSocket Connection

Connect to: `ws://localhost:3000/ws`

## API Endpoints

### List Output Devices

**Request:**

```json
{
  "action": "devices_list"
}
```

**Response:**

```json
{
  "data": [
    {
      "id": "{DEVICE_ID}",
      "name": "Speakers (Realtek Audio)"
    }
  ],
  "headers": {
    "timestamp": 1737100800,
    "count": 1
  }
}
```

### List Sessions for a Device

**Request:**

```json
{
  "action": "session_list",
  "device_id": "{DEVICE_ID}"
}
```

**Response:**

```json
{
  "data": [
    {
      "id": "session-12345-75",
      "display_name": "Spotify",
      "volume_level": 75.0,
      "state": "active",
      "muted": false
    }
  ],
  "headers": {
    "timestamp": 1737100800,
    "count": 1
  }
}
t_group_volume`. Use the session `id` from the `session_list` response.```

### Get Volume

**Request:**

```json
{
  "action": "get_volume"
}
```

**Response:**

```json
{
  "data": 50.0,
  "headers": {
    "timestamp": 1737100800
  }
}
```

### Set Group Volume

**Request:**

```json
{
  "action": "set_group_volume",
  "device_id": "{DEVICE_ID}",
  "group_id": "{GROUP_ID}",
  "volume": 75.0
}
```

**Response:**

```json
{
  "data": {
    "success": true,
    "volume": 75.0
  },
  "headers": {
    "timestamp": 1737100800
  }
}
```

## Session States

- `active` - Session is currently playing audio
- `inactive` - Session is open but not playing
- `expired` - Session has been closed

## Error Responses

All errors follow this format:

```json
{
  "code": 404,
  "message": "Device not found: {device_id}",
  "details": "Additional error context if needed"
}
```

### Error Codes

- `400` - Bad Request (e.g., invalid device ID)
- `404` - Not Found (e.g., device or sessions not found)
- `500` - Internal Server Error (e.g., COM initialization failed)

## Usage Examples

### Example 1: List Devices and Sessions (JavaScript)

```javascript
const ws = new WebSocket('ws://localhost:3000/ws');

ws.onopen = () => {
  // Step 1: Get list of output devices
  ws.send(JSON.stringify({ action: 'devices_list' }));
};

ws.onmessage = (event) => {
  const response = JSON.parse(event.data);

  if (response.headers && response.headers.count !== undefined && Array.isArray(response.data)) {
    // Device list received
    console.log('Devices:', response.data);
    
    if (response.data.length > 0) {
      // Step 2: Get sessions for first device
      const deviceId = response.data[0].id;
      ws.send(JSON.stringify({
        action: 'session_list',
        device_id: deviceId
      }));
    }
  } else if (response.data && response.data[0] && response.data[0].display_name) {
    // Session list received
    console.log('Sessions:', response.data);
    response.data.forEach(session => {
      console.log(`- ${session.display_name} (State: ${session.state}, Volume: ${session.volume_level}%, Muted: ${session.muted})`);
    });
  } else if (response.code) {
    // Error response
    console.error('Error:', response.message);
  }
};
```

### Example 2: List Devices and Sessions (Python)

```python
import json
import asyncio
import websockets

async def get_audio_devices_and_sessions():
    uri = "ws://localhost:3000/ws"
    
    async with websockets.connect(uri) as websocket:
        # Get devices
        await websocket.send(json.dumps({"action": "devices_list"}))
        devices_response = await websocket.recv()
        devices = json.loads(devices_response)
        
        print("Available Devices:")
        for device in devices['data']:
            print(f"  - {device['name']} (ID: {device['id']})")
        
        if devices['data']:
            # Get sessions for first device
            device_id = devices['data'][0]['id']
            await websocket.send(json.dumps({
                "action": "session_list",
                "device_id": device_id
            }))
            sessions_response = await websocket.recv()
            sessions = json.loads(sessions_response)
            
            print(f"\nSessions for {device_id}:")
            for session in sessions['data']:
                print(f"  - {session['display_name']}")
                print(f"    Volume: {session['volume_level']}%")
                print(f"    State: {session['state']}")
                print(f"    Muted: {session['muted']}")

asyncio.run(get_audio_devices_and_sessions())
```

### Example 3: List Devices and Sessions (cURL with websocat)

```bash
# Install websocat: https://github.com/vi/websocat

# List devices
echo '{"action":"devices_list"}' | websocat ws://localhost:3000/ws

# List sessions for a device (replace {DEVICE_ID} with actual ID)
echo '{"action":"session_list","device_id":"{DEVICE_ID}"}' | websocat ws://localhost:3000/ws

# Set group volume (replace {DEVICE_ID} and {GROUP_ID} with actual IDs)
echo '{"action":"set_group_volume","device_id":"{DEVICE_ID}","group_id":"{GROUP_ID}","volume":75.0}' | websocat ws://localhost:3000/ws
```

## Notes

- **device_id**: Required for `session_list` and `set_group_volume`. Get this from the `devices_list` response.
- **group_id**: Required for `set_group_volume`. Use the session `id` from the `session_list` response.
- **volume_level**: Returned as a percentage (0-100) for easy frontend integration.
- **WebSocket**: The connection is persistent; you can send multiple requests without reconnecting.

## Development

Build the project:

```bash
cargo build
cargo run
```

Run clippy for linting:

```bash
cargo clippy
```

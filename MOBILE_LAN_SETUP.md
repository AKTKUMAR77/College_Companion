# Mobile LAN Setup (Same Wi-Fi)

## 1) Start backend so phone can reach it

From `college_companion_backend`, run:

```powershell
python app.py
```

Backend is now configured to listen on all interfaces (`0.0.0.0`) by default and prints reachable URLs, for example:

- `http://127.0.0.1:5000` (same machine)
- `http://192.168.x.x:5000` (other devices on same Wi-Fi)

Use the `192.168.x.x` URL on mobile.

## 2) Run Flutter app with backend IP

From `college_companion_frontend`, run:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5000
```

Replace `192.168.x.x` with your laptop's Wi-Fi IP shown by backend startup log.

## 3) Allow firewall access (Windows)

If mobile cannot connect, allow inbound TCP for port `5000` in Windows Defender Firewall.

## 4) Quick network test from phone browser

Open:

```text
http://192.168.x.x:5000/health
```

Expected response:

```json
{"status":"ok"}
```

## Optional backend environment variables

- `HOST` (default `0.0.0.0`)
- `PORT` (default `5000`)
- `FLASK_DEBUG` (`1` or `0`, default `0`)
- `CORS_ORIGINS` (default `*`, or comma-separated origins)

# College Companion: Global Internet Deployment

This runbook is prepared for your current codebase.

## What is already prepared in repo

- Backend production deps: `college_companion_backend/requirements.txt`
- Backend start command for PaaS: `college_companion_backend/Procfile`
- Backend env template: `college_companion_backend/.env.example`
- Render one-click blueprint: `render.yaml`
- Flutter web hosting config: `college_companion_frontend/firebase.json`
- Firebase project mapping template: `college_companion_frontend/.firebaserc.example`
- Admin credential hardening: `college_companion_backend/auth.py` now reads `ADMIN_PASSWORD` from environment.

## Part A: Deploy frontend globally (Firebase Hosting)

1. Install tools:

```powershell
npm install -g firebase-tools
```

2. Login and select your Firebase project:

```powershell
firebase login
```

3. In `college_companion_frontend`, set your project id:

- Copy `.firebaserc.example` to `.firebaserc`
- Replace `your-firebase-project-id` with your real Firebase project id.

4. Build release web app:

```powershell
cd college_companion_frontend
flutter build web --release
```

5. Deploy hosting:

```powershell
firebase deploy --only hosting
```

6. In Firebase Console -> Authentication -> Settings -> Authorized domains:

- Add your hosting domain (`<project-id>.web.app` and custom domain if any).

## Part B: Deploy backend globally (Render)

Use this only if your app paths still call Flask endpoints.

1. Push this repository to GitHub.
2. Go to Render -> New -> Blueprint and connect the repo.
3. Render will detect `render.yaml` and create `college-companion-backend` service.
4. Set environment variables in Render dashboard:

- `ADMIN_PASSWORD` = strong secret
- `ADMIN_EMPLOYEE_ID` = admin id (default is `000000`)
- `CORS_ORIGINS` = frontend domain(s), comma-separated
- `ALLOW_INSECURE_DEFAULT_ADMIN` = `0`
- `FLASK_DEBUG` = `0`

5. Deploy and verify:

- Open `https://<render-service-domain>/health`
- Must return `{ "status": "ok" }`

## Part C: Point Flutter app to production backend URL (if needed)

Your code supports a runtime override with `API_BASE_URL`.

For local run against hosted backend:

```powershell
cd college_companion_frontend
flutter run --dart-define=API_BASE_URL=https://<render-service-domain>
```

For web release build with hosted backend:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://<render-service-domain>
```

Then deploy hosting again.

## Important production notes

1. SQLite (`users.db`) on cloud instances can be ephemeral. For serious production, migrate to PostgreSQL.
2. Backend currently has no token/session auth for admin-only API calls; do not expose sensitive operations without auth hardening.
3. Keep `ALLOW_INSECURE_DEFAULT_ADMIN=0` in production.
4. Keep `CORS_ORIGINS` restricted to known frontend domains.

## Quick verification checklist

- Frontend URL opens globally (mobile data network test).
- Firebase login works from deployed domain.
- Backend `/health` is reachable publicly.
- CORS errors are absent in browser console.
- Admin login works only with env `ADMIN_PASSWORD`.

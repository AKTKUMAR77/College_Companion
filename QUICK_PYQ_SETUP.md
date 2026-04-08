# ⚡ Quick Start: Seed PYQ Data

## 🔧 Setup (One-time)

### Step 1: Install Firebase Admin
```bash
pip install firebase-admin
```

### Step 2: Get Firebase Credentials
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your **College Companion** project
3. Click **⚙️ Project Settings** (bottom-left)
4. Go to **Service Accounts** tab
5. Click **Generate New Private Key**
6. Save the JSON file to `college_companion_backend/` folder
7. Rename it to `serviceAccountKey.json` (optional but recommended)

## 🚀 Seed Data

### Option A: Quick (Current Year)
```bash
cd college_companion_backend
python3 pyq_quick_seed.py serviceAccountKey.json
```

### Option B: Multiple Years
```bash
python3 pyq_quick_seed.py serviceAccountKey.json 5  # 2024-2020
```

### Option C: Full Seed
```bash
python3 pyq_seed_firestore.py serviceAccountKey.json
```

## ✅ Verify It Works

### In Terminal:
```bash
# Check that no errors appear - script should say "✅ Success!"
```

### In App:
1. Go to **PyQ** section
2. Select any **Year**, **Branch**, **Semester**
3. Should see subjects with papers

### Expected Results:
- ~2,520+ PYQ entries for 1 year × 5 branches
- Each subject shows 2 papers
- All subjects from the course scheme included

## 🐛 Issues?

### "ModuleNotFoundError: No module named 'firebase_admin'"
→ Run: `pip install firebase-admin`

### "Credentials file not found"
→ Check Firebase credentials JSON file exists and path is correct

### "Still no data in app"
→ Try:
- Restart the app completely
- Clear app cache
- Check Firestore in Firebase Console directly

### "Permission denied"
→ Ensure service account has Firestore write permissions

## 📱 Alternative: Add Test Data Manually

Via the app (if you have admin access):

1. Open app → PyQ section
2. Click **Upload PYQ** button
3. Enter: Year (2024), Branch (CSE), Semester (1)
4. Subject: "CSBB 103 - Problem Solving & Computer Programming"
5. Drive Link: Any valid Google Drive link (or dummy: https://drive.google.com/file/d/1test/view)
6. Click Upload

This tests if upload works and lets you see one subject before full seeding.

## ✨ Done!

Once seeded, subjects will appear in the PyQ section with all available papers for filtering by year/branch/semester.

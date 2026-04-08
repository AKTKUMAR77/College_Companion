# PYQ (Previous Year Questions) Database Seeding Guide

This guide explains how to populate the College Companion app with PYQ data for all subjects from the BTech course scheme.

## 📊 Data Overview

The seed script will create:
- **56 subjects** from 6 semesters (1st to 6th)
- **5 branches**: CSE, ECE, ME, EEE, CE
- **5 academic years**: 2024, 2023, 2022, 2021, 2020
- **2 sample papers** per subject per branch per year
- **Total: 5,600 PYQ entries** added to Firestore

---

## 🚀 Quick Start

### Option 1: Using Firebase Admin SDK (Recommended)

#### Prerequisites
```bash
pip install firebase-admin
```

#### Step 1: Get Firebase Credentials
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your College Companion project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file to your project directory

#### Step 2: Run the Seeding Script
```bash
cd college_companion_backend
python3 pyq_seed_firestore.py /path/to/firebase-credentials.json
```

Or using environment variable:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/firebase-credentials.json
python3 pyq_seed_firestore.py
```

### Option 2: Manual Import via Firebase Console

#### Step 1: Convert JSON to Firestore Format
The script can generate a JSON file compatible with Firebase bulk import:

```bash
python3 pyq_generate_json.py > pyq_data.json
```

#### Step 2: Import via Firebase Console
1. Go to Firebase Console → Firestore Database
2. Click **Start Collection** (if pyq doesn't exist)
3. Use the **Bulk Loader** extension or CLI:
```bash
firebase firestore:delete pyq --recursive  # Clear existing data (optional)
firebase firestore:import pyq_data.json
```

### Option 3: Import via Flutter App (Admin Only)

If you want to populate via the app:

1. Modify `api_service.dart` to create a bulk upload function
2. Call it from an admin panel

---

## 📋 Data Structure

Each PYQ document contains:
```json
{
  "year": "2024",
  "branch": "CSE",
  "semester": "1",
  "subject": "CSBB 103 - Problem Solving & Computer Programming",
  "subject_code": "CSBB 103",
  "subject_name": "Problem Solving & Computer Programming",
  "drive_link": "https://drive.google.com/file/d/1...",
  "uploaded_by": "admin",
  "paper_number": 1,
  "created_at": "2024-05-20T10:00:00Z"
}
```

---

## 🔧 Customization

### Modify Available Subjects

Edit `SUBJECTS_BY_SEMESTER` in `pyq_seed_firestore.py`:

```python
SUBJECTS_BY_SEMESTER = {
    "1": [
        ("CSBB 103", "Problem Solving & Computer Programming"),
        # Add more subjects here
    ],
    # Add more semesters (7, 8, etc.)
}
```

### Change Years
```python
YEARS = ["2024", "2023", "2022", "2021", "2020", "2019"]
```

### Change Branches
```python
BRANCHES = ["CSE", "ECE", "ME", "EEE", "CE", "BT"]
```

---

## ✅ Verification

After seeding, verify in Firebase Console:

```bash
# Count total PYQ documents
firebase firestore:delete pyq --count-only

# Or check in Firestore console:
# Firestore → pyq collection → see document count
```

Expected count:
```
Semesters: 6
Subjects per semester: ~5
Branches: 5
Years: 5
Papers per subject: 2

Total = 6 × 5 × 5 × 5 × 2 = 5,600 documents
```

---

## 📱 App Verification

1. Open the app
2. Go to **PyQ** section
3. Select any **Year**, **Branch**, **Semester**
4. Should display all seeded subjects with their papers

---

## 🗑️ Clear Data (if needed)

To remove all PYQ data and start fresh:

```bash
firebase firestore:delete pyq --recursive
```

Or in Firebase Console:
1. Firestore Database → pyq collection → Delete collection

---

## 🐛 Troubleshooting

### "Firebase credentials not found"
- Make sure the JSON file path is correct
- Check file exists: `ls /path/to/credentials.json`

### "Permission denied" error
- Ensure your Firebase service account has Firestore write permissions
- In Firebase Console → IAM & Admin → Grant roles if needed

### "Collection not created"
- Firestore automatically creates collections when you add first document
- No manual creation needed

### "Data not appearing in app"
- Clear app cache: Settings → Apps → College Companion → Clear Cache
- Restart the app
- Check that year/branch/semester filters match your data

---

## 📝 Notes

- Drive links in the sample data are placeholders
- Replace with actual Google Drive links before production use
- Admin can update links via the app's upload feature
- Data is immutable once created; modify via admin panel if needed

---

## 🔒 Security

- Only admin (employee ID: 000000) can upload PYQ
- Remove dummy data before deploying to production
- Keep Firebase credentials secure; never commit to Git

---

Need help? Check logs in Firebase Console → Firestore → Logs/Monitoring

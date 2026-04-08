#!/usr/bin/env python3
"""
Simplified PYQ Seeding Script
Requires: firebase-admin library and Firebase credentials JSON file

Installation:
  pip install firebase-admin

Usage:
  python3 pyq_quick_seed.py <credentials.json> [num_years]

Examples:
  python3 pyq_quick_seed.py serviceAccountKey.json
  python3 pyq_quick_seed.py serviceAccountKey.json 3
"""

import sys
import json
from datetime import datetime, timedelta

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ firebase-admin not installed!")
    print("   Install with: pip install firebase-admin")
    sys.exit(1)

# Subject data from course scheme
SUBJECTS = {
    "1": [("CSBB 103", "Problem Solving & Computer Programming"), 
          ("CSBB 102", "Introduction to Computer Systems"),
          ("MALB 101", "Advanced Calculus"),
          ("HMBB 101", "Theory and Practices of Human Ethics"),
          ("MEBB 162", "Engineering Visualization"),
          ("HMPB 102", "Communication Skills"),
          ("HSPB 150", "Holistic Health and Sports")],
    
    "2": [("CSBB 151", "Data Structures"),
          ("CSLB 152", "Discrete Structures"),
          ("CSLB 154", "System Programming"),
          ("MALB 152", "Applied Linear Algebra"),
          ("CSPB 154", "Introduction to Hardware"),
          ("CELB 101", "Environmental Sciences"),
          ("CSPB 100", "Project I")],
    
    "3": [("CSBB 202", "Design and Analysis of Algorithms"),
          ("CSBB 203", "Operating System"),
          ("CSBB 204", "Database Management Systems"),
          ("MALB 202", "Probability and Statistics"),
          ("ECBB 206", "Digital Electronics and Logic Design")],
    
    "4": [("CSBB 251", "Computer Architecture and Organization"),
          ("CSBB 252", "Artificial Intelligence"),
          ("CSBB 254", "Software Engineering"),
          ("HMBB 251", "Professional Communication"),
          ("ECBB 254", "Communication Systems"),
          ("CSPB 200", "Project II")],
    
    "5": [("CSBB 301", "Computer Networks"),
          ("CSLB 302", "Theory of Computation"),
          ("CSBB 303", "Data Mining"),
          ("CSBB 304", "Quantum Computing")],
    
    "6": [("CSBB 351", "Compiler Design"),
          ("CSBB 352", "Theory of App Development")],
}

BRANCHES = ["CSE", "ECE", "ME", "EEE", "CE"]


def seed_data(creds_json, num_years=5):
    """Seed PYQ data to Firestore."""
    try:
        # Initialize Firebase
        cred = credentials.Certificate(creds_json)
        if not firebase_admin.get_app():
            firebase_admin.initialize_app(cred)
        db = firestore.client()
        
        print(f"\n✅ Connected to Firebase")
        print(f"📚 Seeding {num_years} years of data...\n")
        
        years = [str(2024 - i) for i in range(num_years)]
        count = 0
        
        for semester, subjects in sorted(SUBJECTS.items()):
            for code, name in subjects:
                for branch in BRANCHES:
                    for paper_num in range(1, 3):  # 2 papers per subject
                        for year_idx, year in enumerate(years):
                            doc = {
                                "year": year,
                                "branch": branch,
                                "semester": semester,
                                "subject": f"{code} - {name}",
                                "drive_link": f"https://drive.google.com/file/d/1sample_{code.replace(' ', '')}_{year}_p{paper_num}/view",
                                "uploaded_by": "admin",
                                "paper_number": paper_num,
                                "created_at": datetime.now() - timedelta(days=365 * year_idx),
                            }
                            db.collection("pyq").add(doc)
                            count += 1
            
            print(f"✓ Semester {semester}: Added {len(subjects)} subjects")
        
        print(f"\n✅ Success! Added {count} PYQ entries to Firestore")
        print(f"\n   Semesters: 6")
        print(f"   Subjects: {sum(len(s) for s in SUBJECTS.values())}")
        print(f"   Branches: {len(BRANCHES)}")
        print(f"   Years: {num_years}")
        print(f"   Papers/subject: 2")
        return True
        
    except FileNotFoundError:
        print(f"❌ Credentials file not found: {creds_json}")
        print("   Download from Firebase Console > Project Settings > Service Accounts > Generate New Private Key")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 pyq_quick_seed.py <credentials.json> [num_years]")
        print("Example: python3 pyq_quick_seed.py serviceAccountKey.json 5")
        sys.exit(1)
    
    creds_file = sys.argv[1]
    num_years = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    
    success = seed_data(creds_file, num_years)
    sys.exit(0 if success else 1)

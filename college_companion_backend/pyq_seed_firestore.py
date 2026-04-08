#!/usr/bin/env python3
"""
Complete PYQ Seeding Script for Firestore
Populates all subjects from the course scheme with 2 sample papers each for all branches and years.

Usage:
    python3 pyq_seed_firestore.py <path-to-firebase-credentials.json>

Or set GOOGLE_APPLICATION_CREDENTIALS environment variable:
    export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
    python3 pyq_seed_firestore.py
"""

import sys
import os
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import credentials, firestore

# Subject Data from Course Scheme
SUBJECTS_BY_SEMESTER = {
    "1": [
        ("CSBB 103", "Problem Solving & Computer Programming"),
        ("CSBB 102", "Introduction to Computer Systems"),
        ("MALB 101", "Advanced Calculus"),
        ("HMBB 101", "Theory and Practices of Human Ethics"),
        ("MEBB 162", "Engineering Visualization"),
        ("HMPB 102", "Communication Skills"),
        ("HSPB 150", "Holistic Health and Sports"),
    ],
    "2": [
        ("CSBB 151", "Data Structures"),
        ("CSLB 152", "Discrete Structures"),
        ("CSLB 154", "System Programming"),
        ("MALB 152", "Applied Linear Algebra"),
        ("CSPB 154", "Introduction to Hardware"),
        ("CELB 101", "Environmental Sciences"),
        ("CSPB 100", "Project I"),
    ],
    "3": [
        ("CSBB 202", "Design and Analysis of Algorithms"),
        ("CSBB 203", "Operating System"),
        ("CSBB 204", "Database Management Systems"),
        ("MALB 202", "Probability and Statistics"),
        ("ECBB 206", "Digital Electronics and Logic Design"),
    ],
    "4": [
        ("CSBB 251", "Computer Architecture and Organization"),
        ("CSBB 252", "Artificial Intelligence"),
        ("CSBB 254", "Software Engineering"),
        ("HMBB 251", "Professional Communication"),
        ("ECBB 254", "Communication Systems"),
        ("CSPB 200", "Project II"),
    ],
    "5": [
        ("CSBB 301", "Computer Networks"),
        ("CSLB 302", "Theory of Computation"),
        ("CSBB 303", "Data Mining"),
        ("CSBB 304", "Quantum Computing"),
    ],
    "6": [
        ("CSBB 351", "Compiler Design"),
        ("CSBB 352", "Theory of App Development"),
    ],
}

BRANCHES = ["CSE", "ECE", "ME", "EEE", "CE"]
YEARS = ["2024", "2023", "2022", "2021", "2020"]


def initialize_firebase(creds_path=None):
    """Initialize Firebase Admin SDK."""
    try:
        if creds_path:
            cred = credentials.Certificate(creds_path)
            app = firebase_admin.initialize_app(cred, name='college_companion')
        else:
            # Use GOOGLE_APPLICATION_CREDENTIALS environment variable
            app = firebase_admin.initialize_app(name='college_companion')
        return firestore.client(app=app)
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        print("\nMake sure:")
        print("  1. Firebase credentials JSON file exists")
        print("  2. Path is correct: python3 pyq_seed_firestore.py <path-to-credentials.json>")
        print("  3. Or set GOOGLE_APPLICATION_CREDENTIALS environment variable")
        sys.exit(1)


def seed_pyq_data(db):
    """Seed all PYQ data to Firestore."""
    total_count = 0
    
    print("\n📚 Starting PYQ Database Seeding...")
    print(f"  Semesters: {len(SUBJECTS_BY_SEMESTER)} (1-6)")
    print(f"  Branches: {len(BRANCHES)} ({', '.join(BRANCHES)})")
    print(f"  Years: {len(YEARS)} ({', '.join(YEARS)})")
    
    for semester in sorted(SUBJECTS_BY_SEMESTER.keys()):
        subjects = SUBJECTS_BY_SEMESTER[semester]
        print(f"\n📖 Semester {semester} ({len(subjects)} subjects)")
        
        for subject_code, subject_name in subjects:
            subject_full = f"{subject_code} - {subject_name}"
            
            for branch in BRANCHES:
                # Add 2 papers per subject per branch per year
                for year_offset, year in enumerate(YEARS):
                    for paper_num in range(1, 3):  # 2 papers per subject
                        # Create document
                        doc_data = {
                            "year": year,
                            "branch": branch,
                            "semester": semester,
                            "subject": subject_full,
                            "subject_code": subject_code,
                            "subject_name": subject_name,
                            "drive_link": f"https://drive.google.com/file/d/1pyq_{subject_code.replace(' ', '')}_{branch}_{year}_paper{paper_num}/view",
                            "uploaded_by": "admin",
                            "paper_number": paper_num,
                            "created_at": datetime.now() - timedelta(
                                days=365 * year_offset + 30 * (paper_num - 1)
                            ),
                        }
                        
                        try:
                            db.collection("pyq").add(doc_data)
                            total_count += 1
                        except Exception as e:
                            print(f"  ⚠️ Error adding PYQ: {e}")
            
            print(f"  ✓ {subject_code}: {len(BRANCHES)} branches × {len(YEARS)} years × 2 papers = {len(BRANCHES) * len(YEARS) * 2} entries")
    
    return total_count


def main():
    """Main seeding function."""
    creds_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    print("=" * 60)
    print("🔧 College Companion - PYQ Database Seeder")
    print("=" * 60)
    
    # Initialize Firebase
    db = initialize_firebase(creds_path)
    print("✅ Firebase initialized successfully")
    
    # Seed data
    try:
        total = seed_pyq_data(db)
        print("\n" + "=" * 60)
        print(f"✅ Seeding completed successfully!")
        print(f"   Total PYQ entries added: {total}")
        print("=" * 60)
    except Exception as e:
        print(f"\n❌ Error during seeding: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()

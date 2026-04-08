"""
Seed PYQ data to Firestore for all subjects with 2 sample papers per subject per branch.
"""
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta

# Initialize Firebase (adjust path if needed)
try:
    cred = credentials.Certificate('firebase_config.json')
    firebase_admin.initialize_app(cred)
except:
    firebase_admin.initialize_app()

db = firestore.client()

# Course Scheme Data - All subjects extracted from course scheme
SUBJECTS_BY_SEMESTER = {
    "1": [
        {"code": "CSBB 103", "name": "Problem Solving & Computer Programming"},
        {"code": "CSBB 102", "name": "Introduction to Computer Systems"},
        {"code": "MALB 101", "name": "Advanced Calculus"},
        {"code": "HMBB 101", "name": "Theory and Practices of Human Ethics"},
        {"code": "MEBB 162", "name": "Engineering Visualization"},
        {"code": "HMPB 102", "name": "Communication Skills"},
        {"code": "HSPB 150", "name": "Holistic Health and Sports"},
    ],
    "2": [
        {"code": "CSBB 151", "name": "Data Structures"},
        {"code": "CSLB 152", "name": "Discrete Structures"},
        {"code": "CSLB 154", "name": "System Programming"},
        {"code": "MALB 152", "name": "Applied Linear Algebra"},
        {"code": "CSPB 154", "name": "Introduction to Hardware"},
        {"code": "CELB 101", "name": "Environmental Sciences"},
        {"code": "CSPB 100", "name": "Project I"},
    ],
    "3": [
        {"code": "CSBB 202", "name": "Design and Analysis of Algorithms"},
        {"code": "CSBB 203", "name": "Operating System"},
        {"code": "CSBB 204", "name": "Database Management Systems"},
        {"code": "MALB 202", "name": "Probability and Statistics"},
        {"code": "ECBB 206", "name": "Digital Electronics and Logic Design"},
    ],
    "4": [
        {"code": "CSBB 251", "name": "Computer Architecture and Organization"},
        {"code": "CSBB 252", "name": "Artificial Intelligence"},
        {"code": "CSBB 254", "name": "Software Engineering"},
        {"code": "HMBB 251", "name": "Professional Communication"},
        {"code": "ECBB 254", "name": "Communication Systems"},
        {"code": "CSPB 200", "name": "Project II"},
    ],
    "5": [
        {"code": "CSBB 301", "name": "Computer Networks"},
        {"code": "CSLB 302", "name": "Theory of Computation"},
        {"code": "CSBB 303", "name": "Data Mining"},
        {"code": "CSBB 304", "name": "Quantum Computing"},
    ],
    "6": [
        {"code": "CSBB 351", "name": "Compiler Design"},
        {"code": "CSBB 352", "name": "Theory of App Development"},
    ],
}

BRANCHES = ["CSE", "ECE", "ME", "EEE", "CE"]
YEARS = ["2024", "2023", "2022", "2021"]

# Dummy sample paper links (you can replace with real Google Drive links)
DUMMY_DRIVE_LINKS = [
    "https://drive.google.com/file/d/1dummylink101/view?usp=sharing",
    "https://drive.google.com/file/d/1dummylink102/view?usp=sharing",
]


def seed_pyq_data():
    """Populate Firestore with PYQ data for all subjects."""
    count = 0
    
    for semester, subjects in SUBJECTS_BY_SEMESTER.items():
        for subject in subjects:
            for branch in BRANCHES:
                # Add 2 sample papers per subject per branch per year
                for year_idx, year in enumerate(YEARS):
                    for paper_idx in range(2):  # 2 papers per subject
                        # Create document
                        doc_data = {
                            "year": year,
                            "branch": branch,
                            "semester": semester,
                            "subject": f"{subject['code']} - {subject['name']}",
                            "subject_code": subject['code'],
                            "subject_name": subject['name'],
                            "drive_link": DUMMY_DRIVE_LINKS[paper_idx],
                            "uploaded_by": "admin",
                            "created_at": datetime.now() - timedelta(days=365 - (year_idx * 365) - (paper_idx * 10)),
                            "paper_number": paper_idx + 1,
                        }
                        
                        # Add to Firestore
                        db.collection("pyq").add(doc_data)
                        count += 1
                        print(f"✓ Added: {branch} - Sem {semester} - {subject['code']} - Paper {paper_idx + 1} ({year})")
    
    print(f"\n✅ Total PYQ papers added: {count}")


if __name__ == "__main__":
    print("🔄 Starting PYQ data seeding...")
    try:
        seed_pyq_data()
        print("✅ Seeding completed successfully!")
    except Exception as e:
        print(f"❌ Error during seeding: {e}")
    finally:
        firebase_admin.delete_app(firebase_admin.get_app())

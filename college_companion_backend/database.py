import sqlite3
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
UPLOAD_DIR = BASE_DIR / "uploads" / "pyq"
DEFAULT_PYQ_LINK = "https://drive.google.com/drive/folders/1tdq8ala07Av2hxIIYSypwjDT1vkRZSbf"

def get_db():
    conn = sqlite3.connect("users.db")
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

    db = get_db()
    db.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT,
        name TEXT,
        roll TEXT UNIQUE,
        password TEXT
    )
    """)
    db.execute("""
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_name TEXT NOT NULL,
        sender TEXT NOT NULL,
        text TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)
    db.execute("""
    CREATE TABLE IF NOT EXISTS pyq (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year TEXT NOT NULL,
        branch TEXT NOT NULL,
        semester TEXT NOT NULL,
        subject TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        drive_link TEXT NOT NULL,
        uploaded_by TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # Lightweight migration path from old file-based PYQ schema to drive-link schema.
    pyq_cols = {
        row[1] for row in db.execute("PRAGMA table_info(pyq)").fetchall()
    }

    if "drive_link" not in pyq_cols:
        db.execute("ALTER TABLE pyq ADD COLUMN drive_link TEXT")

    db.execute(
        """
        UPDATE pyq
        SET drive_link = ?
        WHERE drive_link IS NULL OR drive_link = ''
        """,
        (DEFAULT_PYQ_LINK,),
    )

    db.execute(
        """
        CREATE UNIQUE INDEX IF NOT EXISTS idx_pyq_unique_drive
        ON pyq (year, branch, semester, subject, drive_link)
        """
    )

    db.execute(
        """
        INSERT OR IGNORE INTO pyq (
            year, branch, semester, subject, file_name, file_path, drive_link, uploaded_by
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            "2025",
            "CSE",
            "1",
            "PYQ Drive Folder",
            "PYQ Drive Folder",
            "drive_link",
            DEFAULT_PYQ_LINK,
            "000000",
        ),
    )
    db.execute("""
    CREATE TABLE IF NOT EXISTS club_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        club_name TEXT NOT NULL,
        student_roll TEXT NOT NULL,
        student_name TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        reviewed_by TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(club_name, student_roll)
    )
    """)
    db.execute("""
    CREATE TABLE IF NOT EXISTS club_memberships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        club_name TEXT NOT NULL,
        student_roll TEXT NOT NULL,
        student_name TEXT,
        can_send_message INTEGER NOT NULL DEFAULT 0,
        approved_by TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(club_name, student_roll)
    )
    """)
    db.commit()

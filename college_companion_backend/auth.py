from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from database import get_db
from models import decode_roll

auth_bp = Blueprint("auth", __name__)

ADMIN_NAME = "admin"
ADMIN_EMPLOYEE_ID = "000000"
ADMIN_PASSWORD = "000000"
CLUBS = {
    "Altius Sports Club",
    "Clairvoyance Photography Club",
    "Think India Club",
    "Technical Club",
    "Literature Club",
    "Yoga Club",
    "BIS Club",
}


def get_all_accessible_groups(db):
    groups = {"Faculty Lounge", "Department Announcements"}

    students = db.execute(
        "SELECT roll FROM users WHERE role = ?", ("student",)
    ).fetchall()

    for student in students:
        roll = student["roll"]
        decoded = decode_roll(roll)
        if "error" in decoded:
            continue

        groups.add(f"{decoded['year']} Batch")
        groups.add(decoded["branch"])
        if decoded["section"]:
            groups.add(decoded["section"])
        if decoded["group"]:
            groups.add(f"{decoded['section']}-{decoded['group']}")

    return sorted(groups)


def _is_admin_user(roll):
    return roll == ADMIN_EMPLOYEE_ID


def _is_valid_club(club_name):
    return club_name in CLUBS


def _is_club_member(db, club_name, student_roll):
    row = db.execute(
        """
        SELECT can_send_message
        FROM club_memberships
        WHERE club_name = ? AND student_roll = ?
        """,
        (club_name, student_roll),
    ).fetchone()
    return row


def _club_access_status(db, club_name, student_roll):
    member = _is_club_member(db, club_name, student_roll)
    if member:
        return {
            "status": "approved",
            "can_send_message": bool(member["can_send_message"]),
        }

    req = db.execute(
        """
        SELECT status
        FROM club_requests
        WHERE club_name = ? AND student_roll = ?
        """,
        (club_name, student_roll),
    ).fetchone()

    if req:
        return {
            "status": req["status"],
            "can_send_message": False,
        }

    return {
        "status": "not_requested",
        "can_send_message": False,
    }

# ---------- SIGN UP ----------
@auth_bp.route("/signup", methods=["POST"])
def signup():
    data = request.json
    role = data["role"]
    name = data["name"]
    roll = data.get("roll")
    password = generate_password_hash(data["password"])

    if role == "student":
        decoded = decode_roll(roll)
        if "error" in decoded:
            return jsonify({"error": "Invalid roll"}), 400

    db = get_db()
    try:
        db.execute(
            "INSERT INTO users (role, name, roll, password) VALUES (?, ?, ?, ?)",
            (role, name, roll, password)
        )
        db.commit()
    except:
        return jsonify({"error": "User already exists"}), 409

    return jsonify({"message": "Account created"}), 201


# ---------- SIGN IN ----------
@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.json
    role = data.get("role")
    roll = data["roll"]
    password = data["password"]

    db = get_db()

    # Faculty-only admin login with fixed credentials.
    if role == "faculty" and roll == ADMIN_EMPLOYEE_ID and password == ADMIN_PASSWORD:
        return jsonify({
            "name": ADMIN_NAME,
            "roll": ADMIN_EMPLOYEE_ID,
            "role": "faculty",
            "is_admin": True,
            "groups": get_all_accessible_groups(db),
        })

    user = db.execute(
        "SELECT * FROM users WHERE roll = ?", (roll,)
    ).fetchone()

    if not user or not check_password_hash(user["password"], password):
        return jsonify({"error": "Invalid credentials"}), 401

    if role and user["role"] != role:
        return jsonify({"error": "Role mismatch for this account"}), 401

    # Build group list for each role.
    groups = []
    if user["role"] == "student":
        decoded = decode_roll(roll)
        groups.append(f"{decoded['year']} Batch")
        groups.append(decoded["branch"])
        if decoded["section"]:
            groups.append(decoded["section"])
        if decoded["group"]:
            groups.append(f"{decoded['section']}-{decoded['group']}")
    elif user["role"] == "faculty":
        groups.extend(["Faculty Lounge", "Department Announcements"])

    return jsonify({
        "name": user["name"],
        "roll": roll,
        "role": user["role"],
        "is_admin": False,
        "groups": groups
    })


@auth_bp.route("/pyq/options", methods=["GET"])
def pyq_options():
    years = [str(year) for year in range(2025, 2015, -1)]
    branches = ["CSE", "ECE", "ME", "EEE", "CE"]
    semesters = [str(i) for i in range(1, 9)]

    return jsonify({
        "years": years,
        "branches": branches,
        "semesters": semesters,
    })


@auth_bp.route("/pyq", methods=["GET"])
def list_pyq():
    year = (request.args.get("year") or "").strip()
    branch = (request.args.get("branch") or "").strip()
    semester = (request.args.get("semester") or "").strip()

    if not year or not branch or not semester:
        return jsonify({"error": "year, branch and semester are required"}), 400

    db = get_db()
    rows = db.execute(
        """
        SELECT id, year, branch, semester, subject, drive_link, uploaded_by, created_at
        FROM pyq
        WHERE year = ? AND branch = ? AND semester = ?
        ORDER BY id DESC
        """,
        (year, branch, semester),
    ).fetchall()

    papers = []
    for row in rows:
        papers.append({
            "id": row["id"],
            "year": row["year"],
            "branch": row["branch"],
            "semester": row["semester"],
            "subject": row["subject"],
            "drive_link": row["drive_link"],
            "uploaded_by": row["uploaded_by"],
            "created_at": row["created_at"],
        })

    return jsonify(papers)


@auth_bp.route("/pyq", methods=["POST"])
def upload_pyq():
    uploader_roll = (request.form.get("uploader_roll") or "").strip()
    year = (request.form.get("year") or "").strip()
    branch = (request.form.get("branch") or "").strip()
    semester = (request.form.get("semester") or "").strip()
    subject = (request.form.get("subject") or "").strip()
    drive_link = (request.form.get("drive_link") or "").strip()

    if not _is_admin_user(uploader_roll):
        return jsonify({"error": "Only admin can upload PYQ"}), 403

    if not year or not branch or not semester or not subject:
        return jsonify({"error": "year, branch, semester and subject are required"}), 400

    if not drive_link or not (drive_link.startswith("http://") or drive_link.startswith("https://")):
        return jsonify({"error": "valid drive_link is required"}), 400

    db = get_db()
    cursor = db.execute(
        """
        INSERT INTO pyq (
            year, branch, semester, subject, file_name, file_path, drive_link, uploaded_by
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            year,
            branch,
            semester,
            subject,
            "PYQ Drive Link",
            "drive_link",
            drive_link,
            uploader_roll,
        ),
    )
    db.commit()

    return jsonify({
        "message": "PYQ link added successfully",
        "id": cursor.lastrowid,
    }), 201


@auth_bp.route("/clubs", methods=["GET"])
def list_clubs():
    return jsonify(sorted(CLUBS))


@auth_bp.route("/clubs/<club_name>/access", methods=["GET"])
def club_access(club_name):
    club_name = club_name.strip()
    student_roll = (request.args.get("student_roll") or "").strip()

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not student_roll:
        return jsonify({"error": "student_roll is required"}), 400

    db = get_db()
    if _is_admin_user(student_roll):
        return jsonify({
            "status": "approved",
            "can_send_message": True,
            "is_admin": True,
        })

    status = _club_access_status(db, club_name, student_roll)
    status["is_admin"] = False
    return jsonify(status)


@auth_bp.route("/clubs/<club_name>/request", methods=["POST"])
def request_club_access(club_name):
    club_name = club_name.strip()
    data = request.get_json(silent=True) or {}
    student_roll = (data.get("student_roll") or "").strip()
    student_name = (data.get("student_name") or "").strip()

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not student_roll:
        return jsonify({"error": "student_roll is required"}), 400

    if _is_admin_user(student_roll):
        return jsonify({"message": "Admin already has access"}), 200

    db = get_db()
    member = _is_club_member(db, club_name, student_roll)
    if member:
        return jsonify({"message": "Already approved member"}), 200

    existing = db.execute(
        """
        SELECT id, status
        FROM club_requests
        WHERE club_name = ? AND student_roll = ?
        """,
        (club_name, student_roll),
    ).fetchone()

    if existing and existing["status"] == "pending":
        return jsonify({"message": "Request already pending"}), 200

    if existing:
        db.execute(
            """
            UPDATE club_requests
            SET status = 'pending', student_name = ?, reviewed_by = NULL, updated_at = CURRENT_TIMESTAMP
            WHERE id = ?
            """,
            (student_name, existing["id"]),
        )
    else:
        db.execute(
            """
            INSERT INTO club_requests (club_name, student_roll, student_name, status)
            VALUES (?, ?, ?, 'pending')
            """,
            (club_name, student_roll, student_name),
        )
    db.commit()
    return jsonify({"message": "Request submitted"}), 201


@auth_bp.route("/clubs/<club_name>/requests", methods=["GET"])
def list_club_requests(club_name):
    club_name = club_name.strip()
    admin_roll = (request.args.get("admin_roll") or "").strip()

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not _is_admin_user(admin_roll):
        return jsonify({"error": "Only admin can view requests"}), 403

    db = get_db()
    rows = db.execute(
        """
        SELECT id, student_roll, student_name, status, created_at, updated_at
        FROM club_requests
        WHERE club_name = ? AND status = 'pending'
        ORDER BY id ASC
        """,
        (club_name,),
    ).fetchall()

    return jsonify([
        {
            "id": row["id"],
            "student_roll": row["student_roll"],
            "student_name": row["student_name"] or "",
            "status": row["status"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
        }
        for row in rows
    ])


@auth_bp.route("/clubs/<club_name>/requests/<int:request_id>/decision", methods=["POST"])
def decide_club_request(club_name, request_id):
    club_name = club_name.strip()
    data = request.get_json(silent=True) or {}
    admin_roll = (data.get("admin_roll") or "").strip()
    action = (data.get("action") or "").strip().lower()
    can_send_message = bool(data.get("can_send_message", False))

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not _is_admin_user(admin_roll):
        return jsonify({"error": "Only admin can decide requests"}), 403

    if action not in {"approve", "reject"}:
        return jsonify({"error": "action must be approve or reject"}), 400

    db = get_db()
    req = db.execute(
        """
        SELECT id, student_roll, student_name, status
        FROM club_requests
        WHERE id = ? AND club_name = ?
        """,
        (request_id, club_name),
    ).fetchone()

    if not req:
        return jsonify({"error": "Request not found"}), 404

    next_status = "approved" if action == "approve" else "rejected"
    db.execute(
        """
        UPDATE club_requests
        SET status = ?, reviewed_by = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
        """,
        (next_status, admin_roll, request_id),
    )

    if action == "approve":
        db.execute(
            """
            INSERT INTO club_memberships (club_name, student_roll, student_name, can_send_message, approved_by)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(club_name, student_roll)
            DO UPDATE SET
              student_name = excluded.student_name,
              can_send_message = excluded.can_send_message,
              approved_by = excluded.approved_by,
              updated_at = CURRENT_TIMESTAMP
            """,
            (
                club_name,
                req["student_roll"],
                req["student_name"] or "",
                1 if can_send_message else 0,
                admin_roll,
            ),
        )

    db.commit()
    return jsonify({"message": f"Request {next_status}"})


@auth_bp.route("/clubs/<club_name>/members", methods=["GET"])
def list_club_members(club_name):
    club_name = club_name.strip()
    admin_roll = (request.args.get("admin_roll") or "").strip()

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not _is_admin_user(admin_roll):
        return jsonify({"error": "Only admin can view members"}), 403

    db = get_db()
    rows = db.execute(
        """
        SELECT student_roll, student_name, can_send_message, approved_by, created_at, updated_at
        FROM club_memberships
        WHERE club_name = ?
        ORDER BY student_roll ASC
        """,
        (club_name,),
    ).fetchall()

    return jsonify([
        {
            "student_roll": row["student_roll"],
            "student_name": row["student_name"] or "",
            "can_send_message": bool(row["can_send_message"]),
            "approved_by": row["approved_by"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
        }
        for row in rows
    ])


@auth_bp.route("/clubs/<club_name>/members/<student_roll>/message-permission", methods=["POST"])
def update_member_message_permission(club_name, student_roll):
    club_name = club_name.strip()
    student_roll = student_roll.strip()
    data = request.get_json(silent=True) or {}
    admin_roll = (data.get("admin_roll") or "").strip()
    can_send_message = bool(data.get("can_send_message", False))

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not _is_admin_user(admin_roll):
        return jsonify({"error": "Only admin can update permission"}), 403

    db = get_db()
    exists = db.execute(
        """
        SELECT id
        FROM club_memberships
        WHERE club_name = ? AND student_roll = ?
        """,
        (club_name, student_roll),
    ).fetchone()

    if not exists:
        return jsonify({"error": "Member not found"}), 404

    db.execute(
        """
        UPDATE club_memberships
        SET can_send_message = ?, approved_by = ?, updated_at = CURRENT_TIMESTAMP
        WHERE club_name = ? AND student_roll = ?
        """,
        (1 if can_send_message else 0, admin_roll, club_name, student_roll),
    )
    db.commit()

    return jsonify({"message": "Permission updated"})


@auth_bp.route("/clubs/<club_name>/messages", methods=["GET"])
def get_club_messages(club_name):
    club_name = club_name.strip()
    student_roll = (request.args.get("student_roll") or "").strip()

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not student_roll:
        return jsonify({"error": "student_roll is required"}), 400

    db = get_db()
    if not _is_admin_user(student_roll):
        member = _is_club_member(db, club_name, student_roll)
        if not member:
            return jsonify({"error": "Club access not approved"}), 403

    rows = db.execute(
        """
        SELECT id, sender, text, created_at
        FROM messages
        WHERE group_name = ?
        ORDER BY id ASC
        """,
        (f"CLUB::{club_name}",),
    ).fetchall()

    return jsonify([
        {
            "id": row["id"],
            "sender": row["sender"],
            "text": row["text"],
            "timestamp": row["created_at"],
        }
        for row in rows
    ])


@auth_bp.route("/clubs/<club_name>/messages", methods=["POST"])
def post_club_message(club_name):
    club_name = club_name.strip()
    data = request.get_json(silent=True) or {}
    student_roll = (data.get("student_roll") or "").strip()
    sender = (data.get("sender") or "").strip()
    text = (data.get("text") or "").strip()

    if not _is_valid_club(club_name):
        return jsonify({"error": "Invalid club"}), 400

    if not student_roll or not sender or not text:
        return jsonify({"error": "student_roll, sender and text are required"}), 400

    db = get_db()
    if not _is_admin_user(student_roll):
        member = _is_club_member(db, club_name, student_roll)
        if not member:
            return jsonify({"error": "Club access not approved"}), 403
        if not bool(member["can_send_message"]):
            return jsonify({"error": "Message permission is disabled for this club"}), 403

    cursor = db.execute(
        """
        INSERT INTO messages (group_name, sender, text)
        VALUES (?, ?, ?)
        """,
        (f"CLUB::{club_name}", sender, text),
    )
    db.commit()

    created = db.execute(
        """
        SELECT id, sender, text, created_at
        FROM messages
        WHERE id = ?
        """,
        (cursor.lastrowid,),
    ).fetchone()

    return jsonify({
        "id": created["id"],
        "sender": created["sender"],
        "text": created["text"],
        "timestamp": created["created_at"],
    }), 201


# ---------- CHAT MESSAGES ----------
@auth_bp.route("/messages/<group_name>", methods=["GET"])
def get_messages(group_name):
    db = get_db()
    rows = db.execute(
        """
        SELECT id, sender, text, created_at
        FROM messages
        WHERE group_name = ?
        ORDER BY id ASC
        """,
        (group_name,),
    ).fetchall()

    return jsonify([
        {
            "id": row["id"],
            "sender": row["sender"],
            "text": row["text"],
            "timestamp": row["created_at"],
        }
        for row in rows
    ])


@auth_bp.route("/messages/<group_name>", methods=["POST"])
def post_message(group_name):
    data = request.get_json(silent=True) or {}
    sender = (data.get("sender") or "").strip()
    text = (data.get("text") or data.get("message") or "").strip()

    if not sender or not text:
        return jsonify({"error": "sender and text are required"}), 400

    db = get_db()
    cursor = db.execute(
        """
        INSERT INTO messages (group_name, sender, text)
        VALUES (?, ?, ?)
        """,
        (group_name, sender, text),
    )
    db.commit()

    created = db.execute(
        """
        SELECT id, sender, text, created_at
        FROM messages
        WHERE id = ?
        """,
        (cursor.lastrowid,),
    ).fetchone()

    return jsonify({
        "id": created["id"],
        "sender": created["sender"],
        "text": created["text"],
        "timestamp": created["created_at"],
    }), 201

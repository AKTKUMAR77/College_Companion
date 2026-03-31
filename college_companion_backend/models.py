def decode_roll(roll):
    year = "20" + roll[:2]

    branch_map = {
        "1212": "AI-DS",
        "1221": "VLSI",
        "121": "CSE",
        "132": "CE",
        "131": "ME",
        "122": "ECE",
        "123": "EEE",
    }

    branch = None
    branch_code = None

    roll_body = roll[2:]

    # 🔥 Match LONGEST code first
    for code in sorted(branch_map.keys(), key=len, reverse=True):
        if roll_body.startswith(code):
            branch = branch_map[code]
            branch_code = code
            break

    if branch is None:
        return {"error": "Invalid branch code"}

    roll_no = int(roll_body[len(branch_code):])

    section = None
    group = None

    # Section/group ONLY for CSE
    if branch == "CSE":
        section = "CS1" if roll_no <= 65 else "CS2"
        group = "G1" if roll_no <= 33 else "G2"
    # For ECE/EEE/CE/ME: do not split into section names like ME1/ME2.
    # Keep a single section per branch and map roll numbers into 4 groups.
    elif branch in {"ECE", "EEE", "CE", "ME"}:
        section = branch
        if 1 <= roll_no <= 25:
            group = "G1"
        elif 26 <= roll_no <= 50:
            group = "G2"
        elif 51 <= roll_no <= 75:
            group = "G3"
        elif 76 <= roll_no <= 99:
            group = "G4"

    return {
        "year": year,
        "branch": branch,
        "section": section,
        "group": group
    }

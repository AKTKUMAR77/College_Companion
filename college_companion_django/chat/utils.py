def decode_roll_number(roll):
    year = "20" + roll[:2]

    branch_map = {
        "1212": "AI-DS",
        "1221": "VLSI",
        "121": "CSE",
        "132": "Civil",
        "131": "Mechanical",
        "122": "ECE",
        "123": "EEE",
    }

    branch = None
    branch_code = None

    roll_body = roll[2:]

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

    if branch == "CSE":
        section = "CS1" if roll_no <= 65 else "CS2"
        group = "G1" if roll_no <= 33 else "G2"

    return {
        "year": year,
        "branch": branch,
        "section": section,
        "group": group
    }

"""Enforce expand/contract-safe Flyway migrations used by automatic deploys."""

from __future__ import annotations

import re
import sys
from pathlib import Path


FILENAME = re.compile(r"^V[0-9]+__[A-Za-z0-9_]+\.sql$")
BLOCK_COMMENT = re.compile(r"/\*.*?\*/", re.DOTALL)
LINE_COMMENT = re.compile(r"--[^\n]*")

UNSAFE = (
    (re.compile(r"\b(?:DROP|TRUNCATE)\b"), "DROP/TRUNCATE requires a later contract release"),
    (re.compile(r"\bDELETE\s+FROM\b"), "bulk DELETE is not allowed during automatic deploy"),
    (
        re.compile(r"\bALTER\s+TABLE\b.*\b(?:DROP|RENAME)\b"),
        "column/table removal or rename requires a later contract release",
    ),
    (
        re.compile(
            r"\bALTER\s+TABLE\b.*\bALTER\s+(?:COLUMN\s+)?[^\s]+\s+"
            r"(?:TYPE|SET\s+DATA\s+TYPE|SET\s+NOT\s+NULL)\b"
        ),
        "type or NOT NULL changes require a separately verified contract release",
    ),
    (
        re.compile(
            r"\bALTER\s+TABLE\b.*\bADD\s+(?:CONSTRAINT|FOREIGN\s+KEY|PRIMARY\s+KEY|UNIQUE|CHECK)\b"
        ),
        "immediate constraint addition is unsafe for an automatic deploy",
    ),
    (
        re.compile(r"\bCREATE\s+UNIQUE\s+INDEX\b"),
        "unique index creation requires a separately verified migration",
    ),
)


def normalize(sql: str) -> str:
    without_comments = LINE_COMMENT.sub(" ", BLOCK_COMMENT.sub(" ", sql))
    return " ".join(without_comments.upper().split())


def problems_for_sql(sql: str) -> list[str]:
    normalized = normalize(sql)
    return [message for pattern, message in UNSAFE if pattern.search(normalized)]


def check_directory(root: Path) -> list[str]:
    problems: list[str] = []
    if not root.is_dir():
        return problems
    for migration in sorted(root.glob("*.sql")):
        if not FILENAME.fullmatch(migration.name):
            problems.append(f"{migration}: invalid Flyway migration filename")
        for problem in problems_for_sql(migration.read_text(encoding="utf-8")):
            problems.append(f"{migration}: {problem}")
    return problems


def self_test() -> None:
    assert problems_for_sql("ALTER TABLE users ADD COLUMN display_name text") == []
    assert problems_for_sql("-- DROP TABLE ignored_comment\nALTER TABLE users ADD COLUMN age int") == []
    assert problems_for_sql("ALTER TABLE users DROP COLUMN name")
    assert problems_for_sql("ALTER TABLE users ALTER COLUMN name SET NOT NULL")
    assert problems_for_sql("ALTER TABLE child ADD CONSTRAINT fk FOREIGN KEY (id) REFERENCES parent(id)")
    assert problems_for_sql("CREATE UNIQUE INDEX users_email_key ON users(email)")


def main() -> int:
    if len(sys.argv) == 2 and sys.argv[1] == "--self-test":
        self_test()
        return 0
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "src/main/resources/db/migration")
    problems = check_directory(root)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

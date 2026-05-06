# pyright: reportMissingModuleSource=false
import os
import psycopg2
from flask import Flask

app = Flask(__name__)

# ─── Read all credentials from environment variables ─────────
# Never hardcode credentials in source code
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
SERVER_NAME = os.getenv("SERVER_NAME", "Unknown Server")


def get_db_connection():
    """Open a new database connection."""
    return psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )


# ─── Route: / ────────────────────────────────────────────────
@app.route("/")
def hello():
    return f"Hello from {SERVER_NAME}!"


# ─── Route: /secret ──────────────────────────────────────────
# Shows which environment variables are loaded
# Useful for verifying that .env file is read correctly
@app.route("/secret")
def secret():
    return (
        f"SERVER_NAME={SERVER_NAME}<br>"
        f"DB_HOST={DB_HOST}<br>"
        f"DB_NAME={DB_NAME}<br>"
        f"DB_USER={DB_USER}<br>"
    )


# ─── Route: /visit ───────────────────────────────────────────
# Writes server_name to database and shows last 5 visits
# This proves that load balancing and database work correctly
@app.route("/visit")
def visit():
    conn = get_db_connection()
    cur = conn.cursor()

    # Insert this visit into the database
    cur.execute(
        "INSERT INTO visits (server_name) VALUES (%s)",
        (SERVER_NAME,)
    )
    conn.commit()

    # Fetch the 5 most recent visits
    cur.execute(
        "SELECT server_name, visited_at FROM visits ORDER BY visited_at DESC LIMIT 5"
    )
    rows = cur.fetchall()

    cur.close()
    conn.close()

    # Build HTML response
    result = f"<h2>Visit registered from {SERVER_NAME}</h2>"
    result += "<h3>Last 5 visits:</h3><ul>"
    for row in rows:
        result += f"<li>{row[0]} — {row[1]}</li>"
    result += "</ul>"

    return result


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
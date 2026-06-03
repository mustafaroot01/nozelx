import sqlite3
import os

def run_migration():
    db_path = "admin_dashboard.db"
    if not os.path.exists(db_path):
        return
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    try:
        c.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in c.fetchall()]
        if "avatar_url" not in columns:
            c.execute("ALTER TABLE users ADD COLUMN avatar_url VARCHAR")
            conn.commit()
            print("avatar_url added successfully!")
        else:
            print("avatar_url already exists in users table.")
    except Exception as e:
        print("Migration failed:", e)
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

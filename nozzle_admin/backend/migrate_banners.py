import sqlite3
import os

def run_migration():
    db_path = "admin_dashboard.db"
    if not os.path.exists(db_path):
        print(f"Database not found at {db_path}")
        return

    print("Connecting to database...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        cursor.execute("PRAGMA table_info(banners)")
        columns = [row[1] for row in cursor.fetchall()]

        if "subtitle" not in columns:
            print("Adding subtitle column to banners...")
            cursor.execute("ALTER TABLE banners ADD COLUMN subtitle VARCHAR")
        if "text_alignment" not in columns:
            print("Adding text_alignment column to banners...")
            cursor.execute("ALTER TABLE banners ADD COLUMN text_alignment VARCHAR DEFAULT 'center' NOT NULL")
        if "text_color" not in columns:
            print("Adding text_color column to banners...")
            cursor.execute("ALTER TABLE banners ADD COLUMN text_color VARCHAR DEFAULT '#ffffff' NOT NULL")
        if "overlay_color" not in columns:
            print("Adding overlay_color column to banners...")
            cursor.execute("ALTER TABLE banners ADD COLUMN overlay_color VARCHAR DEFAULT '#000000' NOT NULL")
        if "overlay_opacity" not in columns:
            print("Adding overlay_opacity column to banners...")
            cursor.execute("ALTER TABLE banners ADD COLUMN overlay_opacity FLOAT DEFAULT 0.4 NOT NULL")
        if "button_text" not in columns:
            print("Adding button_text column to banners...")
            cursor.execute("ALTER TABLE banners ADD COLUMN button_text VARCHAR")

        conn.commit()
        print("Banners migration completed successfully!")
    except Exception as e:
        conn.rollback()
        print(f"Migration failed: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

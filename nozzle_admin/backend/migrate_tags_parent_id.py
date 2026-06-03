import sqlite3
import os

def migrate_tags():
    db_path = "admin_dashboard.db"
    if not os.path.exists(db_path):
        print("Database not found")
        return
        
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        cursor.execute("PRAGMA table_info(product_tags)")
        columns = [row[1] for row in cursor.fetchall()]
        
        if "parent_id" not in columns:
            print("Adding parent_id column to product_tags...")
            cursor.execute("ALTER TABLE product_tags ADD COLUMN parent_id INTEGER REFERENCES product_tags(id) ON DELETE CASCADE;")
            conn.commit()
            print("Column added successfully!")
        else:
            print("parent_id column already exists in product_tags.")
    except Exception as e:
        print(f"Migration failed: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    migrate_tags()

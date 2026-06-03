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
        # Check columns of products table
        cursor.execute("PRAGMA table_info(products)")
        columns = [row[1] for row in cursor.fetchall()]

        # Add missing columns to products
        if "reorder_point" not in columns:
            print("Adding reorder_point column to products table...")
            cursor.execute("ALTER TABLE products ADD COLUMN reorder_point INTEGER DEFAULT 20")
        if "max_stock" not in columns:
            print("Adding max_stock column to products table...")
            cursor.execute("ALTER TABLE products ADD COLUMN max_stock INTEGER DEFAULT 100")

        # Create stock_movements table
        print("Creating stock_movements table if not exists...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS stock_movements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                product_id INTEGER NOT NULL,
                type VARCHAR NOT NULL,
                quantity_change INTEGER NOT NULL,
                quantity_before INTEGER NOT NULL,
                quantity_after INTEGER NOT NULL,
                reason VARCHAR,
                invoice_number VARCHAR,
                created_by INTEGER,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
            )
        """)

        conn.commit()
        print("Inventory migration completed successfully!")
    except Exception as e:
        conn.rollback()
        print(f"Migration failed: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

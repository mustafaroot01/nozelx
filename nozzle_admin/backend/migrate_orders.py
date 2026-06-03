import sqlite3
import os

def run_migration():
    db_path = "admin_dashboard.db"
    if not os.path.exists(db_path):
        print(f"Database file not found at {db_path}")
        return

    print("Connecting to database...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        # Check orders table
        cursor.execute("PRAGMA table_info(orders)")
        order_columns = [row[1] for row in cursor.fetchall()]
        
        # Check order_items table
        cursor.execute("PRAGMA table_info(order_items)")
        item_columns = [row[1] for row in cursor.fetchall()]

        print("Starting migrations...")

        # Add columns to orders
        new_order_cols = {
            "address": "VARCHAR",
            "notes": "VARCHAR",
            "payment_method": "VARCHAR DEFAULT 'cash'",
            "subtotal": "FLOAT",
            "delivery_fee": "FLOAT DEFAULT 3000.0",
            "coupon_code": "VARCHAR",
            "coupon_discount": "FLOAT DEFAULT 0.0",
            "invoice_number": "VARCHAR",
            "status_history": "JSON DEFAULT '[]'"
        }

        for col, col_type in new_order_cols.items():
            if col not in order_columns:
                print(f"Adding column '{col}' to 'orders' table...")
                cursor.execute(f"ALTER TABLE orders ADD COLUMN {col} {col_type}")

        # Add columns to order_items
        new_item_cols = {
            "selected_size": "VARCHAR",
            "selected_color": "VARCHAR"
        }

        for col, col_type in new_item_cols.items():
            if col not in item_columns:
                print(f"Adding column '{col}' to 'order_items' table...")
                cursor.execute(f"ALTER TABLE order_items ADD COLUMN {col} {col_type}")

        conn.commit()
        print("Database migration completed successfully!")
    except Exception as e:
        conn.rollback()
        print(f"Migration failed: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

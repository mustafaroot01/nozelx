import sqlite3
import os

def run_migration():
    db_path = "/Users/ahmdfars/Desktop/nozzleapp/nozzle_admin/backend/admin_dashboard.db"
    if not os.path.exists(db_path):
        print(f"Database file not found at {db_path}")
        return

    print("Connecting to database...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        print("Starting migrations...")

        # 1. Create user_tokens table
        print("Creating user_tokens table...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_tokens (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                token VARCHAR(500) UNIQUE NOT NULL,
                device_info VARCHAR(255),
                expires_at DATETIME NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        """)

        # 2. Create otp_codes table
        print("Creating otp_codes table...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS otp_codes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                phone VARCHAR(20) NOT NULL,
                code VARCHAR(10) NOT NULL,
                expires_at DATETIME NOT NULL,
                is_used BOOLEAN DEFAULT 0,
                attempts INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # 3. Alter orders table
        print("Checking columns in orders table...")
        cursor.execute("PRAGMA table_info(orders)")
        order_columns = [row[1] for row in cursor.fetchall()]

        if "user_id" not in order_columns:
            print("Adding user_id to orders table...")
            cursor.execute("ALTER TABLE orders ADD COLUMN user_id INTEGER REFERENCES users(id) ON DELETE SET NULL")

        if "order_number" not in order_columns:
            print("Adding order_number to orders table...")
            cursor.execute("ALTER TABLE orders ADD COLUMN order_number VARCHAR(20)")
            conn.commit()  # commit to make sure columns exist
            
            # Populate order_number for existing orders
            cursor.execute("SELECT id FROM orders")
            order_ids = [r[0] for r in cursor.fetchall()]
            for o_id in order_ids:
                cursor.execute("UPDATE orders SET order_number = ? WHERE id = ?", (f"ORD-{o_id:06d}", o_id))
            
            # Make it unique by creating index
            print("Creating unique index idx_orders_order_number...")
            cursor.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number)")

        # 4. Alter service_requests table
        print("Checking columns in service_requests table...")
        cursor.execute("PRAGMA table_info(service_requests)")
        sr_columns = [row[1] for row in cursor.fetchall()]

        if "user_id" not in sr_columns:
            print("Adding user_id to service_requests table...")
            cursor.execute("ALTER TABLE service_requests ADD COLUMN user_id INTEGER REFERENCES users(id) ON DELETE SET NULL")

        # 5. Alter cart_items table
        print("Checking columns in cart_items table...")
        cursor.execute("PRAGMA table_info(cart_items)")
        cart_columns = [row[1] for row in cursor.fetchall()]

        if "selected_size" not in cart_columns:
            print("Adding selected_size to cart_items table...")
            cursor.execute("ALTER TABLE cart_items ADD COLUMN selected_size VARCHAR(50)")
        
        if "selected_color" not in cart_columns:
            print("Adding selected_color to cart_items table...")
            cursor.execute("ALTER TABLE cart_items ADD COLUMN selected_color VARCHAR(50)")
            
        if "updated_at" not in cart_columns:
            print("Adding updated_at to cart_items table...")
            cursor.execute("ALTER TABLE cart_items ADD COLUMN updated_at DATETIME")
            cursor.execute("UPDATE cart_items SET updated_at = CURRENT_TIMESTAMP")

        print("Creating unique index idx_cart_user_product_size_color...")
        cursor.execute("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_cart_user_product_size_color 
            ON cart_items(user_id, product_id, selected_size, selected_color)
        """)

        # 6. Alter favorites table
        print("Checking columns in favorites table...")
        cursor.execute("PRAGMA table_info(favorites)")
        fav_columns = [row[1] for row in cursor.fetchall()]

        # We can drop phone_number from favorites or keep it. Let's make sure unique index on user_id, product_id is created
        print("Creating unique index idx_favorites_user_product...")
        cursor.execute("""
            CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_user_product 
            ON favorites(user_id, product_id)
        """)

        # 7. Create indexes for performance
        print("Creating performance indexes...")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_service_requests_user ON service_requests(user_id)")

        conn.commit()
        print("Migrations completed successfully!")

    except Exception as e:
        conn.rollback()
        print(f"Migration failed: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

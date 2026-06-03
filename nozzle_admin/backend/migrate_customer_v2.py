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
        print("Starting v2 migrations...")

        # 1. Alter users table
        print("Checking columns in users table...")
        cursor.execute("PRAGMA table_info(users)")
        user_columns = [row[1] for row in cursor.fetchall()]

        if "name" not in user_columns:
            print("Adding name column to users table...")
            cursor.execute("ALTER TABLE users ADD COLUMN name VARCHAR(255)")
            cursor.execute("UPDATE users SET name = full_name")

        if "total_orders" not in user_columns:
            print("Adding total_orders column to users table...")
            cursor.execute("ALTER TABLE users ADD COLUMN total_orders INTEGER DEFAULT 0")

        if "total_spent" not in user_columns:
            print("Adding total_spent column to users table...")
            cursor.execute("ALTER TABLE users ADD COLUMN total_spent REAL DEFAULT 0.0")

        if "last_login_at" not in user_columns:
            print("Adding last_login_at column to users table...")
            cursor.execute("ALTER TABLE users ADD COLUMN last_login_at DATETIME")

        if "updated_at" not in user_columns:
            print("Adding updated_at column to users table...")
            cursor.execute("ALTER TABLE users ADD COLUMN updated_at DATETIME")
            cursor.execute("UPDATE users SET updated_at = created_at")

        # 2. Create user_coupon_usage table
        print("Creating user_coupon_usage table...")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user_coupon_usage (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                coupon_id INTEGER NOT NULL,
                coupon_code VARCHAR(50) NOT NULL,
                order_id INTEGER,
                discount_amount REAL NOT NULL,
                used_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY(coupon_id) REFERENCES coupons(id),
                FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE SET NULL
            )
        """)
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_coupon_user ON user_coupon_usage(user_id)")

        # Sync existing users' total_orders and total_spent
        cursor.execute("SELECT id FROM users")
        user_ids = [r[0] for r in cursor.fetchall()]
        for u_id in user_ids:
            cursor.execute("SELECT COUNT(*) FROM orders WHERE user_id = ? AND status != 'cancelled'", (u_id,))
            orders_count = cursor.fetchone()[0]
            cursor.execute("SELECT SUM(total_amount) FROM orders WHERE user_id = ? AND status = 'completed'", (u_id,))
            total_spent = cursor.fetchone()[0] or 0.0
            cursor.execute("UPDATE users SET total_orders = ?, total_spent = ? WHERE id = ?", (orders_count, total_spent, u_id))

        conn.commit()
        print("V2 migrations completed successfully!")

    except Exception as e:
        conn.rollback()
        print(f"Migration failed: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

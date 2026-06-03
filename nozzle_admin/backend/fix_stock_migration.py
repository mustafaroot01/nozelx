import sqlite3
import os

def fix_database_stock():
    db_path = "admin_dashboard.db"
    if not os.path.exists(db_path):
        print(f"❌ Database not found at {db_path}")
        return

    print("🔌 Connecting to database...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        # Check table columns
        cursor.execute("PRAGMA table_info(products)")
        columns = {row[1]: row for row in cursor.fetchall()}
        
        if "stock_quantity" not in columns:
            print("❌ stock_quantity column is missing! Please run migrate.py first.")
            conn.close()
            return

        print("🔍 Checking products for invalid or negative stock values...")
        cursor.execute("SELECT id, name, stock_quantity, status, is_active FROM products")
        products = cursor.fetchall()
        
        updated_count = 0
        for p_id, name, qty, status, is_active in products:
            needs_update = False
            new_qty = qty
            new_status = status
            
            # Clean null/none values
            if qty is None:
                new_qty = 0
                needs_update = True
                print(f"⚠️ Product '{name}' (ID: {p_id}) had NULL stock_quantity. Setting to 0.")
                
            # Clean negative stock values
            elif qty < 0:
                new_qty = 0
                needs_update = True
                print(f"⚠️ Product '{name}' (ID: {p_id}) had negative stock_quantity: {qty}. Setting to 0.")
            
            # Make sure status matches stock_quantity if out of stock
            if new_qty <= 0 and status == "active":
                # Some business logic might want to keep status as 'active' but set is_available = False.
                # However, if stock is 0, let's keep status 'active' but ensure frontend shows out of stock properly.
                pass
            
            if needs_update:
                cursor.execute(
                    "UPDATE products SET stock_quantity = ? WHERE id = ?",
                    (new_qty, p_id)
                )
                updated_count += 1
                
        if updated_count > 0:
            conn.commit()
            print(f"✅ Successfully updated {updated_count} products.")
        else:
            print("✨ No invalid stock values found. Database is healthy!")

        # Verify Index existence
        cursor.execute("PRAGMA index_list(products)")
        indexes = [row[1] for row in cursor.fetchall()]
        if "idx_product_stock_active" not in indexes:
            print("🔧 Index idx_product_stock_active is missing. Creating index...")
            cursor.execute("CREATE INDEX idx_product_stock_active ON products (stock_quantity, is_active)")
            conn.commit()
            print("✅ Created index idx_product_stock_active.")
        else:
            print("✨ Index idx_product_stock_active already exists.")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error during database fix: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    fix_database_stock()

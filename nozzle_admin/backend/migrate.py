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
        # Check if products table already has stock_quantity
        cursor.execute("PRAGMA table_info(products)")
        columns = [row[1] for row in cursor.fetchall()]
        
        if "stock_quantity" in columns and "is_active" in columns:
            print("Database is already up to date. No migration needed.")
            conn.close()
            return
            
        print("Starting migration inside transaction...")
        cursor.execute("BEGIN TRANSACTION;")

        # Create new table with updated columns, types, and constraints
        cursor.execute("""
            CREATE TABLE products_new (
                id INTEGER NOT NULL PRIMARY KEY,
                name VARCHAR NOT NULL,
                description TEXT,
                price FLOAT NOT NULL,
                sale_price FLOAT,
                tax_rate FLOAT NOT NULL DEFAULT 15.0,
                stock_quantity INTEGER NOT NULL DEFAULT 0,
                low_stock_threshold INTEGER NOT NULL DEFAULT 10,
                sku VARCHAR,
                category_id INTEGER NOT NULL,
                subcategory_id INTEGER,
                image_url VARCHAR,
                images JSON DEFAULT '[]',
                variants JSON DEFAULT '[]',
                features JSON DEFAULT '[]',
                specifications JSON DEFAULT '{}',
                tags JSON DEFAULT '[]',
                seo_title VARCHAR,
                seo_description TEXT,
                slug VARCHAR,
                status VARCHAR NOT NULL DEFAULT 'active',
                is_deleted BOOLEAN NOT NULL DEFAULT 0,
                is_active BOOLEAN NOT NULL DEFAULT 1,
                created_at DATETIME,
                FOREIGN KEY(category_id) REFERENCES categories (id) ON DELETE CASCADE,
                FOREIGN KEY(subcategory_id) REFERENCES categories (id) ON DELETE SET NULL,
                CHECK(stock_quantity >= 0)
            )
        """)

        # Determine which column to copy from (stock or stock_quantity)
        stock_col = "stock" if "stock" in columns else "stock_quantity"
        
        # Build insert query with column names dynamically
        source_cols = [c for c in columns if c != stock_col and c != "is_active"]
        dest_cols = list(source_cols)
        
        # Add stock_quantity and is_active to destination
        dest_cols.append("stock_quantity")
        dest_cols.append("is_active")
        
        # Map source columns
        select_source_cols = [c for c in source_cols]
        select_source_cols.append(stock_col) # Map stock to stock_quantity
        # If is_active exists in source, map it, otherwise default to 1
        if "is_active" in columns:
            select_source_cols.append("is_active")
        else:
            select_source_cols.append("1")

        insert_sql = f"""
            INSERT INTO products_new ({", ".join(dest_cols)})
            SELECT {", ".join(select_source_cols)} FROM products
        """
        print(f"Executing: {insert_sql}")
        cursor.execute(insert_sql)

        # Drop old table and rename the new one
        print("Dropping old products table and renaming new table...")
        cursor.execute("DROP TABLE products")
        cursor.execute("ALTER TABLE products_new RENAME TO products")

        # Recreate indexes
        print("Recreating indexes...")
        cursor.execute("CREATE INDEX ix_products_id ON products (id)")
        cursor.execute("CREATE INDEX ix_products_name ON products (name)")
        cursor.execute("CREATE UNIQUE INDEX ix_products_slug ON products (slug)")
        cursor.execute("CREATE UNIQUE INDEX ix_products_sku ON products (sku)")
        cursor.execute("CREATE INDEX idx_product_stock_active ON products (stock_quantity, is_active)")

        conn.commit()
        print("Migration completed successfully!")
    except Exception as e:
        conn.rollback()
        print(f"Migration failed: {e}")
        raise e
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()

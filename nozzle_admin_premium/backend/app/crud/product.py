from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate

def get_product(db: Session, product_id: int) -> Optional[Product]:
    """
    Retrieves a single active product by ID.
    """
    return db.query(Product).filter(Product.id == product_id, Product.is_deleted == False).first()

def get_product_by_slug(db: Session, slug: str) -> Optional[Product]:
    """
    Retrieves a single active product by slug.
    """
    return db.query(Product).filter(Product.slug == slug, Product.is_deleted == False).first()

def get_product_by_sku(db: Session, sku: str) -> Optional[Product]:
    """
    Retrieves a single active product by SKU.
    """
    return db.query(Product).filter(Product.sku == sku, Product.is_deleted == False).first()

def get_products(
    db: Session,
    *,
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None,
    category_id: Optional[int] = None,
    subcategory_id: Optional[int] = None,
    status: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None
) -> List[Product]:
    """
    Queries and returns a list of products matching search, category, status, and price constraints.
    """
    query = db.query(Product).filter(Product.is_deleted == False)
    
    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            or_(
                Product.name.ilike(search_filter),
                Product.description.ilike(search_filter),
                Product.sku.ilike(search_filter)
            )
        )
        
    if category_id is not None:
        query = query.filter(Product.category_id == category_id)
        
    if subcategory_id is not None:
        query = query.filter(Product.subcategory_id == subcategory_id)
        
    if status:
        query = query.filter(Product.status == status)
        
    if min_price is not None:
        query = query.filter(Product.price >= min_price)
        
    if max_price is not None:
        query = query.filter(Product.price <= max_price)
        
    return query.order_by(Product.created_at.desc()).offset(skip).limit(limit).all()

def count_products(
    db: Session,
    *,
    search: Optional[str] = None,
    category_id: Optional[int] = None,
    subcategory_id: Optional[int] = None,
    status: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None
) -> int:
    """
    Counts total active products matching the specified filters.
    Useful for frontend pagination controls.
    """
    query = db.query(Product).filter(Product.is_deleted == False)
    
    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            or_(
                Product.name.ilike(search_filter),
                Product.description.ilike(search_filter),
                Product.sku.ilike(search_filter)
            )
        )
        
    if category_id is not None:
        query = query.filter(Product.category_id == category_id)
        
    if subcategory_id is not None:
        query = query.filter(Product.subcategory_id == subcategory_id)
        
    if status:
        query = query.filter(Product.status == status)
        
    if min_price is not None:
        query = query.filter(Product.price >= min_price)
        
    if max_price is not None:
        query = query.filter(Product.price <= max_price)
        
    return query.count()

def create_product(db: Session, *, obj_in: ProductCreate) -> Product:
    """
    Creates and persists a new product record.
    """
    # Convert schemas in variants list to raw dicts for JSON storage
    variants_data = [v.dict() for v in obj_in.variants]
    
    db_obj = Product(
        name=obj_in.name,
        description=obj_in.description,
        price=obj_in.price,
        sale_price=obj_in.sale_price,
        tax_rate=obj_in.tax_rate,
        stock=obj_in.stock,
        low_stock_threshold=obj_in.low_stock_threshold,
        sku=obj_in.sku,
        category_id=obj_in.category_id,
        subcategory_id=obj_in.subcategory_id,
        images=obj_in.images,
        variants=variants_data,
        seo_title=obj_in.seo_title,
        seo_description=obj_in.seo_description,
        slug=obj_in.slug,
        status=obj_in.status
    )
    
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def update_product(db: Session, *, db_obj: Product, obj_in: ProductUpdate) -> Product:
    """
    Updates an existing product record with delta modifications.
    """
    update_data = obj_in.dict(exclude_unset=True)
    
    # Process variants if explicitly provided
    if "variants" in update_data and update_data["variants"] is not None:
        update_data["variants"] = [v.dict() for v in obj_in.variants]
        
    for field in update_data:
        setattr(db_obj, field, update_data[field])
        
    db.commit()
    db.refresh(db_obj)
    return db_obj

def soft_delete_product(db: Session, *, product_id: int) -> Optional[Product]:
    """
    Soft-deletes a product by settings is_deleted=True and updating status.
    """
    db_obj = db.query(Product).filter(Product.id == product_id, Product.is_deleted == False).first()
    if db_obj:
        db_obj.is_deleted = True
        db_obj.status = "hidden"
        db.commit()
        db.refresh(db_obj)
    return db_obj

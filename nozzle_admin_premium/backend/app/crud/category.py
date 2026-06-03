from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Optional, Dict
from app.models.category import Category
from app.models.product import Product
from app.schemas.category import CategoryCreate, CategoryUpdate

def get_category(db: Session, category_id: int) -> Optional[Category]:
    """
    Retrieves a single category by ID.
    """
    return db.query(Category).filter(Category.id == category_id).first()

def get_category_by_slug(db: Session, slug: str) -> Optional[Category]:
    """
    Retrieves a single category by slug string.
    """
    return db.query(Category).filter(Category.slug == slug).first()

def get_main_categories(db: Session) -> List[Category]:
    """
    Retrieves all primary categories (parent_id is null) ordered by sort_order.
    """
    return db.query(Category).filter(Category.parent_id == None).order_by(Category.sort_order.asc()).all()

def get_categories(
    db: Session,
    *,
    skip: int = 0,
    limit: int = 100,
    parent_id: Optional[int] = None
) -> List[Category]:
    """
    Fetches categories with optional parent_id filtering.
    """
    query = db.query(Category)
    if parent_id is not None:
        query = query.filter(Category.parent_id == parent_id)
    return query.order_by(Category.sort_order.asc()).offset(skip).limit(limit).all()

def get_category_product_count(db: Session, category_id: int, is_parent: bool = False) -> int:
    """
    Calculates the count of active products under a given category or subcategory.
    """
    if is_parent:
        return db.query(Product).filter(
            Product.category_id == category_id,
            Product.is_deleted == False
        ).count()
    else:
        return db.query(Product).filter(
            or_(Product.category_id == category_id, Product.subcategory_id == category_id),
            Product.is_deleted == False
        ).count()

def slugify(text: str) -> str:
    import re
    text = text.lower()
    text = re.sub(r'[^a-z0-9\u0600-\u06ff]+', '-', text)
    text = text.strip('-')
    return text

def generate_unique_slug(db: Session, name: str, category_id: Optional[int] = None) -> str:
    base_slug = slugify(name)
    if not base_slug:
        base_slug = "category"
    
    slug = base_slug
    count = 1
    
    while True:
        query = db.query(Category).filter(Category.slug == slug)
        if category_id is not None:
            query = query.filter(Category.id != category_id)
        existing = query.first()
        if not existing:
            break
        slug = f"{base_slug}-{count}"
        count += 1
            
    return slug

def create_category(db: Session, *, obj_in: CategoryCreate) -> Category:
    """
    Creates and persists a new category record.
    """
    slug = obj_in.slug
    if not slug or slug.strip() == "":
        slug = generate_unique_slug(db, obj_in.name)
    else:
        slug = generate_unique_slug(db, slug)

    db_obj = Category(
        name=obj_in.name,
        description=obj_in.description,
        parent_id=obj_in.parent_id,
        icon_url=obj_in.icon_url,
        image_url=obj_in.image_url,
        sort_order=obj_in.sort_order,
        seo_title=obj_in.seo_title,
        seo_description=obj_in.seo_description,
        slug=slug,
        is_active=obj_in.is_active
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def update_category(db: Session, *, db_obj: Category, obj_in: CategoryUpdate) -> Category:
    """
    Updates an existing category record with delta modifications.
    """
    update_data = obj_in.dict(exclude_unset=True)
    
    if 'slug' in update_data:
        new_slug = update_data['slug']
        if not new_slug or new_slug.strip() == "":
            update_data['slug'] = generate_unique_slug(db, update_data.get('name', db_obj.name), db_obj.id)
        else:
            update_data['slug'] = generate_unique_slug(db, new_slug, db_obj.id)
    elif 'name' in update_data and db_obj.name != update_data['name']:
        update_data['slug'] = generate_unique_slug(db, update_data['name'], db_obj.id)

    for field in update_data:
        setattr(db_obj, field, update_data[field])
    db.commit()
    db.refresh(db_obj)
    return db_obj

def delete_category(db: Session, *, category_id: int) -> bool:
    """
    Deletes a category from the database.
    Self-referencing cascade setup handles subcategory deletion automatically.
    """
    db_obj = db.query(Category).filter(Category.id == category_id).first()
    if db_obj:
        db.delete(db_obj)
        db.commit()
        return True
    return False

def update_sort_orders(db: Session, *, sort_data: List[Dict[str, int]]) -> bool:
    """
    Updates the sort_order of multiple categories for drag-and-drop resequencing.
    sort_data expected: [{"id": 1, "sort_order": 0}, {"id": 2, "sort_order": 1}]
    """
    try:
        for item in sort_data:
            cat_id = item.get("id")
            new_order = item.get("sort_order")
            if cat_id is not None and new_order is not None:
                db.query(Category).filter(Category.id == cat_id).update({"sort_order": new_order})
        db.commit()
        return True
    except Exception:
        db.rollback()
        return False

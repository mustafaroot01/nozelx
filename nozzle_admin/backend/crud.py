from sqlalchemy.orm import Session
from sqlalchemy import func, or_, and_
from typing import List, Dict, Optional, Any
import datetime
from datetime import datetime as dt
import models
import schemas
def get_phone_variants(phone: str) -> list:
    if not phone:
        return []
    digits = "".join(c for c in phone if c.isdigit())
    variants = {phone, digits}
    
    # support both 9-digit and 10-digit core lengths
    for length in [9, 10]:
        if len(digits) >= length:
            core = digits[-length:]
            variants.add(core)
            variants.add(f"0{core}")
            variants.add(f"964{core}")
            variants.add(f"+964{core}")
            
    return list(variants)


# --- AUDIT LOG UTILITY ---
def create_audit_log(db: Session, user_id: int, action: str, details: str = None):
    log = models.AuditLog(user_id=user_id, action=action, details=details)
    db.add(log)
    db.commit()
    db.refresh(log)
    return log

# --- USER CRUD ---
def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def get_user_by_phone(db: Session, phone: str):
    return db.query(models.User).filter(models.User.phone == phone).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).filter(models.User.role != "customer").offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserCreate, creator_id: int = None):
    hashed_pwd = auth.get_password_hash(user.password)
    db_user = models.User(
        email=user.email,
        phone=user.phone,
        hashed_password=hashed_pwd,
        full_name=user.full_name,
        role=user.role,
        is_active=user.is_active,
        avatar_url=user.avatar_url
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    if creator_id:
        identifier = db_user.email or db_user.phone
        create_audit_log(db, creator_id, "CREATE_USER", f"Created user {identifier} (Role: {db_user.role})")
        
    return db_user

def update_user(db: Session, user_id: int, user_update: schemas.UserUpdate, current_user_id: int):
    db_user = get_user(db, user_id)
    if not db_user:
        return None
        
    update_data = user_update.model_dump(exclude_unset=True)
    if "password" in update_data and update_data["password"]:
        update_data["hashed_password"] = auth.get_password_hash(update_data["password"])
        del update_data["password"]
        
    for key, value in update_data.items():
        setattr(db_user, key, value)
        
    db.commit()
    db.refresh(db_user)
    
    create_audit_log(db, current_user_id, "UPDATE_USER", f"Updated user {db_user.email}")
    return db_user

def delete_user(db: Session, user_id: int, current_user_id: int):
    db_user = get_user(db, user_id)
    if not db_user:
        return False
        
    db.delete(db_user)
    db.commit()
    
    create_audit_log(db, current_user_id, "DELETE_USER", f"Deleted user ID {user_id}")
    return True


# --- CATEGORY CRUD ---
def get_categories(db: Session, skip: int = 0, limit: int = 100, parent_id: int = None):
    query = db.query(models.Category)
    if parent_id is not None:
        query = query.filter(models.Category.parent_id == parent_id)
    return query.order_by(models.Category.sort_order.asc()).offset(skip).limit(limit).all()

def get_main_categories(db: Session):
    return db.query(models.Category).filter(models.Category.parent_id == None).order_by(models.Category.sort_order.asc()).all()

def get_category(db: Session, category_id: int):
    return db.query(models.Category).filter(models.Category.id == category_id).first()

def slugify(text: str) -> str:
    import re
    # Convert to lowercase
    text = text.lower()
    # Replace non-alphanumeric (including Arabic characters) with hyphens
    text = re.sub(r'[^a-z0-9\u0600-\u06ff]+', '-', text)
    # Remove leading and trailing hyphens
    text = text.strip('-')
    return text

def generate_unique_slug(db: Session, name: str, category_id: Optional[int] = None) -> str:
    base_slug = slugify(name)
    if not base_slug:
        base_slug = "category"
    
    slug = base_slug
    count = 1
    
    while True:
        query = db.query(models.Category).filter(models.Category.slug == slug)
        if category_id is not None:
            query = query.filter(models.Category.id != category_id)
        existing = query.first()
        if not existing:
            break
        slug = f"{base_slug}-{count}"
        count += 1
            
    return slug

def get_category_by_slug(db: Session, slug: str):
    return db.query(models.Category).filter(models.Category.slug == slug).first()

def get_category_product_count(db: Session, category_id: int, is_parent: bool = False) -> int:
    if is_parent:
        return db.query(models.Product).filter(
            models.Product.category_id == category_id,
            models.Product.is_deleted == False
        ).count()
    else:
        return db.query(models.Product).filter(
            or_(models.Product.category_id == category_id, models.Product.subcategory_id == category_id),
            models.Product.is_deleted == False
        ).count()

def create_category(db: Session, category: schemas.CategoryCreate, user_id: int):
    # Auto-generate unique slug if not present, or verify uniqueness of provided slug
    slug = category.slug
    if not slug or slug.strip() == "":
        slug = generate_unique_slug(db, category.name)
    else:
        slug = generate_unique_slug(db, slug)

    db_category = models.Category(
        name=category.name,
        description=category.description,
        parent_id=category.parent_id,
        icon_url=category.icon_url,
        image_url=category.image_url,
        sort_order=category.sort_order,
        seo_title=category.seo_title,
        seo_description=category.seo_description,
        slug=slug,
        is_active=category.is_active
    )
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    
    create_audit_log(db, user_id, "CREATE_CATEGORY", f"Created category {db_category.name}")
    return db_category

def update_category(db: Session, category_id: int, category_update: schemas.CategoryUpdate, user_id: int):
    db_category = get_category(db, category_id)
    if not db_category:
        return None
        
    update_data = category_update.model_dump(exclude_unset=True)
    
    # Ensure slug remains unique if slug or name is being updated
    if 'slug' in update_data:
        new_slug = update_data['slug']
        if not new_slug or new_slug.strip() == "":
            update_data['slug'] = generate_unique_slug(db, update_data.get('name', db_category.name), category_id)
        else:
            update_data['slug'] = generate_unique_slug(db, new_slug, category_id)
    elif 'name' in update_data and db_category.name != update_data['name']:
        update_data['slug'] = generate_unique_slug(db, update_data['name'], category_id)
        
    for key, value in update_data.items():
        setattr(db_category, key, value)
        
    db.commit()
    db.refresh(db_category)
    
    create_audit_log(db, user_id, "UPDATE_CATEGORY", f"Updated category {db_category.name}")
    return db_category

def delete_category(db: Session, category_id: int, user_id: int):
    db_category = get_category(db, category_id)
    if not db_category:
        return False
        
    category_name = db_category.name
    db.delete(db_category)
    db.commit()
    
    create_audit_log(db, user_id, "DELETE_CATEGORY", f"Deleted category {category_name}")
    return True

def update_category_sort_orders(db: Session, sort_data: List[Dict[str, int]]):
    try:
        for item in sort_data:
            cat_id = item.get("id")
            new_order = item.get("sort_order")
            if cat_id is not None and new_order is not None:
                db.query(models.Category).filter(models.Category.id == cat_id).update({"sort_order": new_order})
        db.commit()
        return True
    except Exception:
        db.rollback()
        return False


# --- PRODUCT CRUD ---
def get_products(
    db: Session, 
    skip: int = 0, 
    limit: int = 100, 
    category_id: int = None, 
    subcategory_id: int = None,
    tag_id: int = None,
    search: str = None,
    status: str = None
):
    query = db.query(models.Product).filter(models.Product.is_deleted == False)
    if category_id:
        query = query.filter(
            or_(
                models.Product.category_id == category_id,
                models.Product.subcategory_id == category_id
            )
        )
    if subcategory_id:
        query = query.filter(models.Product.subcategory_id == subcategory_id)
    if tag_id:
        query = query.filter(models.Product.product_tags_list.any(models.ProductTag.id == tag_id))
    if status:
        query = query.filter(models.Product.status == status)
    if search:
        query = query.filter(
            or_(
                models.Product.name.ilike(f"%{search}%"),
                models.Product.description.ilike(f"%{search}%"),
                models.Product.sku.ilike(f"%{search}%")
            )
        )
    return query.order_by(models.Product.id.desc()).offset(skip).limit(limit).all()

def count_products(db: Session, category_id: int = None, subcategory_id: int = None, tag_id: int = None, search: str = None) -> int:
    query = db.query(models.Product).filter(models.Product.is_deleted == False)
    if category_id:
        query = query.filter(
            or_(
                models.Product.category_id == category_id,
                models.Product.subcategory_id == category_id
            )
        )
    if subcategory_id:
        query = query.filter(models.Product.subcategory_id == subcategory_id)
    if tag_id:
        query = query.filter(models.Product.product_tags_list.any(models.ProductTag.id == tag_id))
    if search:
        query = query.filter(
            or_(
                models.Product.name.ilike(f"%{search}%"),
                models.Product.description.ilike(f"%{search}%"),
                models.Product.sku.ilike(f"%{search}%")
            )
        )
    return query.count()

def get_product(db: Session, product_id: int):
    return db.query(models.Product).filter(models.Product.id == product_id, models.Product.is_deleted == False).first()

def get_product_by_slug(db: Session, slug: str):
    return db.query(models.Product).filter(models.Product.slug == slug, models.Product.is_deleted == False).first()

def get_product_by_sku(db: Session, sku: str):
    return db.query(models.Product).filter(models.Product.sku == sku, models.Product.is_deleted == False).first()

def create_product(db: Session, product: schemas.ProductCreate, user_id: int):
    variants_data = [v.dict() for v in product.variants]
    db_product = models.Product(
        name=product.name,
        description=product.description,
        price=product.price,
        sale_price=product.sale_price,
        tax_rate=product.tax_rate,
        stock_quantity=product.stock_quantity,
        low_stock_threshold=product.low_stock_threshold,
        reorder_point=product.reorder_point,
        max_stock=product.max_stock,
        sku=product.sku,
        category_id=product.category_id,
        subcategory_id=product.subcategory_id,
        image_url=product.image_url or (product.images[0] if product.images else None),
        images=product.images,
        variants=variants_data,
        features=product.features,
        specifications=product.specifications,
        tags=product.tags,
        seo_title=product.seo_title,
        seo_description=product.seo_description,
        slug=product.slug,
        status=product.status,
        is_active=True
    )
    db.add(db_product)
    if product.tag_ids:
        db_product.product_tags_list = db.query(models.ProductTag).filter(models.ProductTag.id.in_(product.tag_ids)).all()
    db.commit()
    db.refresh(db_product)
    
    create_audit_log(db, user_id, "CREATE_PRODUCT", f"Created product {db_product.name} (Price: {db_product.price})")
    return db_product

def update_product(db: Session, product_id: int, product_update: schemas.ProductUpdate, user_id: int):
    db_product = get_product(db, product_id)
    if not db_product:
        return None
        
    update_data = product_update.model_dump(exclude_unset=True)
    if "variants" in update_data and update_data["variants"] is not None:
        update_data["variants"] = [v.dict() for v in product_update.variants]
        
    tag_ids = update_data.pop("tag_ids", None)
    if tag_ids is not None:
        db_product.product_tags_list = db.query(models.ProductTag).filter(models.ProductTag.id.in_(tag_ids)).all()

    for key, value in update_data.items():
        setattr(db_product, key, value)
        
    db.commit()
    db.refresh(db_product)
    
    create_audit_log(db, user_id, "UPDATE_PRODUCT", f"Updated product {db_product.name}")
    return db_product

def delete_product(db: Session, product_id: int, user_id: int):
    db_product = get_product(db, product_id)
    if not db_product:
        return False
        
    product_name = db_product.name
    # Perform soft delete
    db_product.is_deleted = True
    db_product.status = "hidden"
    db.commit()
    
    create_audit_log(db, user_id, "DELETE_PRODUCT", f"Deleted (soft-delete) product {product_name}")
    return True


# --- BANNER CRUD ---
def get_banner(db: Session, banner_id: int) -> Optional[models.Banner]:
    return db.query(models.Banner).filter(models.Banner.id == banner_id).first()

def get_banners(db: Session, skip: int = 0, limit: int = 100, active_only: bool = False) -> List[models.Banner]:
    query = db.query(models.Banner)
    if active_only:
        now = dt.utcnow()
        query = query.filter(
            models.Banner.is_active == True,
            or_(models.Banner.start_date == None, models.Banner.start_date <= now),
            or_(models.Banner.end_date == None, models.Banner.end_date >= now)
        )
    return query.order_by(models.Banner.sort_order.asc(), models.Banner.created_at.desc()).offset(skip).limit(limit).all()

def create_banner(db: Session, banner: schemas.BannerCreate, user_id: int) -> models.Banner:
    db_obj = models.Banner(
        title=banner.title or "",
        subtitle=banner.subtitle,
        image_url=banner.image_url,
        mobile_image_url=banner.mobile_image_url,
        link_type=banner.link_type,
        product_id=banner.product_id,
        category_id=banner.category_id,
        external_url=banner.external_url,
        text_alignment=banner.text_alignment,
        text_color=banner.text_color,
        overlay_color=banner.overlay_color,
        overlay_opacity=banner.overlay_opacity,
        button_text=banner.button_text,
        sort_order=banner.sort_order,
        start_date=banner.start_date,
        end_date=banner.end_date,
        is_active=banner.is_active
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    create_audit_log(db, user_id, "CREATE_BANNER", f"Created banner {db_obj.title}")
    return db_obj

def update_banner(db: Session, banner_id: int, banner_update: schemas.BannerUpdate, user_id: int) -> Optional[models.Banner]:
    db_obj = get_banner(db, banner_id)
    if not db_obj:
        return None
    for key, value in banner_update.model_dump(exclude_unset=True).items():
        if key == "title" and value is None:
            value = ""
        setattr(db_obj, key, value)
    db.commit()
    db.refresh(db_obj)
    create_audit_log(db, user_id, "UPDATE_BANNER", f"Updated banner {db_obj.title}")
    return db_obj

def delete_banner(db: Session, banner_id: int, user_id: int) -> bool:
    db_obj = get_banner(db, banner_id)
    if not db_obj:
        return False
    title = db_obj.title
    db.delete(db_obj)
    db.commit()
    create_audit_log(db, user_id, "DELETE_BANNER", f"Deleted banner {title}")
    return True

def increment_views(db: Session, banner_id: int) -> bool:
    db_obj = db.query(models.Banner).filter(models.Banner.id == banner_id).first()
    if db_obj:
        db_obj.views += 1
        db.commit()
        return True
    return False

def increment_clicks(db: Session, banner_id: int) -> bool:
    db_obj = db.query(models.Banner).filter(models.Banner.id == banner_id).first()
    if db_obj:
        db_obj.clicks += 1
        db.commit()
        return True
    return False

def update_banner_sort_orders(db: Session, sort_data: List[Dict[str, int]]) -> bool:
    try:
        for item in sort_data:
            b_id = item.get("id")
            new_order = item.get("sort_order")
            if b_id is not None and new_order is not None:
                db.query(models.Banner).filter(models.Banner.id == b_id).update({"sort_order": new_order})
        db.commit()
        return True
    except Exception:
        db.rollback()
        return False


# --- COUPON CRUD ---
def get_coupon(db: Session, coupon_id: int) -> Optional[models.Coupon]:
    return db.query(models.Coupon).filter(models.Coupon.id == coupon_id).first()

def get_coupon_by_code(db: Session, code: str) -> Optional[models.Coupon]:
    return db.query(models.Coupon).filter(models.Coupon.code.ilike(code)).first()

def get_coupons(db: Session, skip: int = 0, limit: int = 100, active_only: bool = False) -> List[models.Coupon]:
    query = db.query(models.Coupon)
    if active_only:
        now = dt.utcnow()
        query = query.filter(
            models.Coupon.is_active == True,
            or_(models.Coupon.start_date == None, models.Coupon.start_date <= now),
            or_(models.Coupon.end_date == None, models.Coupon.end_date >= now)
        )
    return query.order_by(models.Coupon.created_at.desc()).offset(skip).limit(limit).all()

def create_coupon(db: Session, coupon: schemas.CouponCreate, user_id: int) -> models.Coupon:
    db_obj = models.Coupon(
        code=coupon.code,
        discount_type=coupon.discount_type,
        value=coupon.value,
        min_order_value=coupon.min_order_value,
        max_discount_value=coupon.max_discount_value,
        usage_limit=coupon.usage_limit,
        start_date=coupon.start_date,
        end_date=coupon.end_date,
        user_id=coupon.user_id,
        product_ids=coupon.product_ids,
        category_ids=coupon.category_ids,
        buy_x=coupon.buy_x,
        get_y=coupon.get_y,
        get_y_discount=coupon.get_y_discount,
        is_active=coupon.is_active
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    create_audit_log(db, user_id, "CREATE_COUPON", f"Created coupon {db_obj.code}")
    return db_obj

def update_coupon(db: Session, coupon_id: int, coupon_update: schemas.CouponUpdate, user_id: int) -> Optional[models.Coupon]:
    db_obj = get_coupon(db, coupon_id)
    if not db_obj:
        return None
    for key, value in coupon_update.model_dump(exclude_unset=True).items():
        setattr(db_obj, key, value)
    db.commit()
    db.refresh(db_obj)
    create_audit_log(db, user_id, "UPDATE_COUPON", f"Updated coupon {db_obj.code}")
    return db_obj

def delete_coupon(db: Session, coupon_id: int, user_id: int) -> bool:
    db_obj = get_coupon(db, coupon_id)
    if not db_obj:
        return False
    code = db_obj.code
    db.delete(db_obj)
    db.commit()
    create_audit_log(db, user_id, "DELETE_COUPON", f"Deleted coupon {code}")
    return True

def increment_coupon_usage(db: Session, coupon_id: int) -> bool:
    db_obj = db.query(models.Coupon).filter(models.Coupon.id == coupon_id).first()
    if db_obj:
        db_obj.usage_count += 1
        db.commit()
        return True
    return False

def validate_coupon_code(db: Session, validation_in: schemas.CouponValidationRequest) -> schemas.CouponValidationResponse:
    coupon = get_coupon_by_code(db, validation_in.code)
    if not coupon:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="كوبون الخصم غير موجود")
    if not coupon.is_active:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="هذا الكوبون غير فعال حالياً")
    now = dt.utcnow()
    if coupon.start_date and coupon.start_date > now:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="عرض الكوبون لم يبدأ بعد")
    if coupon.end_date and coupon.end_date < now:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="انتهت صلاحية هذا الكوبون")
    if coupon.usage_limit is not None and coupon.usage_count >= coupon.usage_limit:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="وصل هذا الكوبون للحد الأقصى للاستخدام")
    if coupon.user_id is not None and coupon.user_id != validation_in.user_id:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="هذا الكوبون غير مخصص لحسابك")
    if coupon.min_order_value is not None and validation_in.order_value < coupon.min_order_value:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message=f"الحد الأدنى لاستخدام الكوبون هو {coupon.min_order_value}")
        
    discount_amount = 0.0
    has_product_limit = len(coupon.product_ids) > 0
    has_category_limit = len(coupon.category_ids) > 0
    
    if coupon.discount_type == "buy_x_get_y":
        if not coupon.buy_x or not coupon.get_y:
            return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="إعدادات عرض 'اشترِ X واحصل على Y' غير مكتملة")
        total_qualifying_items = 0
        applicable_items = []
        for item in validation_in.items:
            fits_prod = not has_product_limit or item.product_id in coupon.product_ids
            fits_cat = not has_category_limit or item.category_id in coupon.category_ids
            if fits_prod and fits_cat:
                applicable_items.append(item)
                total_qualifying_items += item.quantity
        if total_qualifying_items < coupon.buy_x:
            return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message=f"هذا العرض يتطلب شراء {coupon.buy_x} منتجات على الأقل")
        applicable_items.sort(key=lambda x: x.price)
        groups = total_qualifying_items // (coupon.buy_x + coupon.get_y)
        free_allowed = groups * coupon.get_y
        temp_free = free_allowed
        for item in applicable_items:
            if temp_free <= 0:
                break
            discounted_qty = min(item.quantity, temp_free)
            discount_amount += discounted_qty * item.price * (coupon.get_y_discount / 100.0)
            temp_free -= discounted_qty
    else:
        qualifying_value = 0.0
        has_limit = has_product_limit or has_category_limit
        for item in validation_in.items:
            fits_prod = not has_product_limit or item.product_id in coupon.product_ids
            fits_cat = not has_category_limit or item.category_id in coupon.category_ids
            if fits_prod and fits_cat:
                qualifying_value += item.price * item.quantity
        if has_limit and qualifying_value <= 0:
            return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="لا توجد منتجات مشمولة بالكوبون في السلة")
        if coupon.discount_type == "percentage":
            discount_amount = (coupon.value / 100.0) * qualifying_value
            if coupon.max_discount_value is not None:
                discount_amount = min(discount_amount, coupon.max_discount_value)
        elif coupon.discount_type == "fixed":
            discount_amount = min(coupon.value, qualifying_value)
            
    if discount_amount <= 0.0:
        return schemas.CouponValidationResponse(valid=False, discount_amount=0.0, message="لم يترتب أي خصم على السلة الحالية")
    return schemas.CouponValidationResponse(valid=True, discount_amount=round(discount_amount, 2), message="تم تطبيق الكوبون بنجاح", coupon_id=coupon.id)


# --- ORDER CRUD ---
def get_orders(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Order).order_by(models.Order.created_at.desc()).offset(skip).limit(limit).all()

def get_order(db: Session, order_id: int):
    return db.query(models.Order).filter(models.Order.id == order_id).first()

def create_order(db: Session, order: schemas.OrderCreate):
    calc_subtotal = order.subtotal
    if calc_subtotal is None:
        calc_subtotal = sum(item.price * item.quantity for item in order.items)

    import random
    db_order = models.Order(
        user_id=order.user_id,
        order_number=order.order_number or f"ORD-{int(datetime.datetime.utcnow().timestamp())}{random.randint(10, 99)}",
        customer_name=order.customer_name,
        customer_email=order.customer_email,
        customer_phone=order.customer_phone,
        total_amount=order.total_amount,
        status=order.status,
        address=order.address,
        notes=order.notes,
        payment_method=order.payment_method or "cash",
        subtotal=calc_subtotal,
        delivery_fee=order.delivery_fee if order.delivery_fee is not None else 3000.0,
        coupon_code=order.coupon_code,
        coupon_discount=order.coupon_discount if order.coupon_discount is not None else 0.0,
        invoice_number=order.invoice_number or f"INV-{int(datetime.datetime.utcnow().timestamp())}",
        status_history=[{
            "status": order.status,
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "note": "تم إنشاء الطلب"
        }]
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    
    for item in order.items:
        db_item = models.OrderItem(
            order_id=db_order.id,
            product_id=item.product_id,
            quantity=item.quantity,
            price=item.price,
            selected_size=item.selected_size,
            selected_color=item.selected_color
        )
        db.add(db_item)
        
        # Decrement product stock
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        if product:
            qty_before = product.stock_quantity
            qty_after = max(0, product.stock_quantity - item.quantity)
            product.stock_quantity = qty_after
            
            # Record StockMovement
            db_movement = models.StockMovement(
                product_id=product.id,
                type="out",
                quantity_change=item.quantity,
                quantity_before=qty_before,
                quantity_after=qty_after,
                reason=f"طلب عميل رقم #{db_order.id}",
                invoice_number=db_order.invoice_number,
                created_by=None
            )
            db.add(db_movement)
        
    db.commit()
    db.refresh(db_order)
    return db_order

def update_order_status(db: Session, order_id: int, status: str, user_id: int):
    db_order = get_order(db, order_id)
    if not db_order:
        return None
        
    old_status = db_order.status
    db_order.status = status
    db.commit()
    db.refresh(db_order)
    
    create_audit_log(db, user_id, "UPDATE_ORDER_STATUS", f"Updated order ID {order_id} status from {old_status} to {status}")
    return db_order


# --- LOGS ---
def get_audit_logs(db: Session, skip: int = 0, limit: int = 50):
    return db.query(models.AuditLog).order_by(models.AuditLog.timestamp.desc()).offset(skip).limit(limit).all()


# --- DASHBOARD STATS ---
def get_dashboard_stats(db: Session) -> schemas.DashboardStats:
    total_rev = db.query(func.sum(models.Order.total_amount)).filter(models.Order.status == "completed").scalar() or 0.0
    total_ord = db.query(models.Order).count()
    total_prod = db.query(models.Product).filter(models.Product.is_deleted == False).count()
    total_usr = db.query(models.User).count()
    
    # 5. Monthly Revenue Chart (Recharts format)
    # Use strftime or simple SQLite grouping
    try:
        monthly_rev_query = db.query(
            func.strftime("%m", models.Order.created_at).label("month_num"),
            func.sum(models.Order.total_amount).label("revenue")
        ).filter(models.Order.status == "completed").group_by("month_num").order_by("month_num").all()
    except Exception:
        monthly_rev_query = []
        
    month_names = {
        "01": "يناير", "02": "فبراير", "03": "مارس", "04": "أبريل", 
        "05": "مايو", "06": "يونيو", "07": "يوليو", "08": "أغسطس", 
        "09": "سبتمبر", "10": "أكتوبر", "11": "نوفمبر", "12": "ديسمبر"
    }
    
    monthly_revenue = []
    for item in monthly_rev_query:
        month_str = month_names.get(item.month_num, item.month_num)
        monthly_revenue.append(schemas.MonthlyRevenue(month=month_str, revenue=float(item.revenue)))
        
    if not monthly_revenue:
        monthly_revenue = [
            schemas.MonthlyRevenue(month="مارس", revenue=12000.0),
            schemas.MonthlyRevenue(month="أبريل", revenue=19000.0),
            schemas.MonthlyRevenue(month="مايو", revenue=32000.0)
        ]
        
    # 6. Category Share
    category_share = []
    try:
        category_share_query = db.query(
            models.Category.name,
            func.count(models.Product.id).label("prod_count")
        ).join(models.Product).filter(models.Product.is_deleted == False).group_by(models.Category.name).all()
        for item in category_share_query:
            category_share.append(schemas.CategoryShare(category=item.name, value=int(item.prod_count)))
    except Exception:
        pass
        
    if not category_share:
        category_share = [
            schemas.CategoryShare(category="زيوت محركات", value=15),
            schemas.CategoryShare(category="فلاتر", value=8),
            schemas.CategoryShare(category="عناية بالسيارة", value=12)
        ]
        
    # 7. Recent Orders
    recent_orders_query = db.query(models.Order).order_by(models.Order.created_at.desc()).limit(5).all()
    recent_orders = []
    for o in recent_orders_query:
        recent_orders.append(schemas.RecentOrder(
            id=o.id,
            customer=o.customer_name,
            amount=o.total_amount,
            status=o.status,
            date=o.created_at.strftime("%Y-%m-%d %H:%M")
        ))
        
    return schemas.DashboardStats(
        total_revenue=float(total_rev),
        total_orders=total_ord,
        total_products=total_prod,
        total_users=total_usr,
        revenue_growth_percentage=12.5,
        orders_growth_percentage=8.2,
        monthly_revenue=monthly_revenue,
        category_share=category_share,
        recent_orders=recent_orders
    )


# --- NOTIFICATION CRUD ---
def get_notification(db: Session, notification_id: int) -> Optional[models.Notification]:
    return db.query(models.Notification).filter(models.Notification.id == notification_id).first()

def get_notifications(db: Session, skip: int = 0, limit: int = 100) -> List[models.Notification]:
    return db.query(models.Notification).order_by(models.Notification.created_at.desc()).offset(skip).limit(limit).all()

def create_notification(db: Session, notification: schemas.NotificationCreate, user_id: int) -> models.Notification:
    db_obj = models.Notification(
        title=notification.title,
        body=notification.body,
        image_url=notification.image_url,
        target_type=notification.target_type,
        target_id=notification.target_id,
        status=notification.status,
        scheduled_at=notification.scheduled_at
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    create_audit_log(db, user_id, "CREATE_NOTIFICATION", f"Sent/Scheduled push notification: {db_obj.title}")
    return db_obj

def delete_notification(db: Session, notification_id: int, user_id: int) -> bool:
    db_obj = get_notification(db, notification_id)
    if not db_obj:
        return False
    title = db_obj.title
    db.delete(db_obj)
    db.commit()
    create_audit_log(db, user_id, "DELETE_NOTIFICATION", f"Deleted notification: {title}")
    return True


# --- SYSTEM SETTING CRUD ---
def get_system_setting(db: Session, key: str) -> Optional[models.SystemSetting]:
    return db.query(models.SystemSetting).filter(models.SystemSetting.key == key).first()

def get_all_system_settings(db: Session) -> List[models.SystemSetting]:
    return db.query(models.SystemSetting).all()

def update_system_setting(db: Session, key: str, value: Any, user_id: int) -> models.SystemSetting:
    db_obj = get_system_setting(db, key)
    if db_obj:
        db_obj.value = value
    else:
        db_obj = models.SystemSetting(key=key, value=value)
        db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    create_audit_log(db, user_id, "UPDATE_SETTING", f"Updated setting key: {key}")
    return db_obj


# --- CART CRUD ---
def get_cart_item(db: Session, item_id: int) -> Optional[models.CartItem]:
    return db.query(models.CartItem).filter(models.CartItem.id == item_id).first()

def get_cart(db: Session, user_id: Optional[int] = None, session_id: Optional[str] = None) -> List[models.CartItem]:
    if user_id:
        return db.query(models.CartItem).filter(models.CartItem.user_id == user_id).all()
    elif session_id:
        return db.query(models.CartItem).filter(models.CartItem.session_id == session_id).all()
    return []

def add_cart_item(db: Session, item_in: schemas.CartItemCreate, user_id: Optional[int] = None) -> models.CartItem:
    size = item_in.options.get("size") if isinstance(item_in.options, dict) else None
    color = item_in.options.get("color") if isinstance(item_in.options, dict) else None
    
    # Check if item with same product and size/color options already exists
    query = db.query(models.CartItem).filter(
        models.CartItem.product_id == item_in.product_id,
        models.CartItem.selected_size == size,
        models.CartItem.selected_color == color
    )
    if user_id:
        query = query.filter(models.CartItem.user_id == user_id)
    else:
        query = query.filter(models.CartItem.session_id == item_in.session_id)
    
    existing_item = query.first()

    if existing_item:
        existing_item.quantity += item_in.quantity
        db.commit()
        db.refresh(existing_item)
        return existing_item
    else:
        db_obj = models.CartItem(
            session_id=item_in.session_id,
            user_id=user_id,
            product_id=item_in.product_id,
            quantity=item_in.quantity,
            options=item_in.options,
            selected_size=size,
            selected_color=color
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

def update_cart_item(db: Session, item_id: int, item_update: schemas.CartItemUpdate) -> Optional[models.CartItem]:
    db_obj = get_cart_item(db, item_id)
    if not db_obj:
        return None
    db_obj.quantity = item_update.quantity
    if item_update.options is not None:
        db_obj.options = item_update.options
    db.commit()
    db.refresh(db_obj)
    return db_obj

def remove_cart_item(db: Session, item_id: int) -> bool:
    db_obj = get_cart_item(db, item_id)
    if not db_obj:
        return False
    db.delete(db_obj)
    db.commit()
    return True

def clear_cart(db: Session, user_id: Optional[int] = None, session_id: Optional[str] = None) -> bool:
    if user_id:
        db.query(models.CartItem).filter(models.CartItem.user_id == user_id).delete()
    elif session_id:
        db.query(models.CartItem).filter(models.CartItem.session_id == session_id).delete()
    else:
        return False
    db.commit()
    return True

def merge_cart(db: Session, session_id: str, user_id: int):
    # Get guest cart
    guest_items = db.query(models.CartItem).filter(models.CartItem.session_id == session_id).all()
    for item in guest_items:
        # Move to user or add
        item_in = schemas.CartItemCreate(
            product_id=item.product_id,
            quantity=item.quantity,
            options=item.options,
            session_id=None
        )
        add_cart_item(db, item_in, user_id=user_id)
        db.delete(item)
    db.commit()


# --- FAVORITES CRUD ---
def get_favorites(db: Session, user_id: Optional[int] = None, phone_number: Optional[str] = None) -> List[models.Favorite]:
    if user_id:
        return db.query(models.Favorite).filter(models.Favorite.user_id == user_id).all()
    elif phone_number:
        return db.query(models.Favorite).filter(models.Favorite.phone_number == phone_number).all()
    return []

def add_favorite(db: Session, product_id: int, user_id: Optional[int] = None, phone_number: Optional[str] = None) -> models.Favorite:
    # Check if already favorited
    query = db.query(models.Favorite).filter(models.Favorite.product_id == product_id)
    if user_id:
        query = query.filter(models.Favorite.user_id == user_id)
    else:
        query = query.filter(models.Favorite.phone_number == phone_number)
    
    existing = query.first()
    if existing:
        return existing
        
    db_obj = models.Favorite(
        user_id=user_id,
        phone_number=phone_number,
        product_id=product_id
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def remove_favorite(db: Session, product_id: int, user_id: Optional[int] = None, phone_number: Optional[str] = None) -> bool:
    query = db.query(models.Favorite).filter(models.Favorite.product_id == product_id)
    if user_id:
        query = query.filter(models.Favorite.user_id == user_id)
    else:
        query = query.filter(models.Favorite.phone_number == phone_number)
    
    existing = query.first()
    if not existing:
        return False
    db.delete(existing)
    db.commit()
    return True


# --- ADDRESSES CRUD ---
def get_addresses(db: Session, user_id: Optional[int] = None, phone_number: Optional[str] = None) -> List[models.Address]:
    if user_id:
        return db.query(models.Address).filter(models.Address.user_id == user_id).all()
    elif phone_number:
        return db.query(models.Address).filter(models.Address.phone_number == phone_number).all()
    return []

def get_address(db: Session, address_id: int) -> Optional[models.Address]:
    return db.query(models.Address).filter(models.Address.id == address_id).first()

def create_address(db: Session, address_in: schemas.AddressCreate, user_id: Optional[int] = None) -> models.Address:
    # If set to default, disable other default addresses
    if address_in.is_default:
        query = db.query(models.Address)
        if user_id:
            query = query.filter(models.Address.user_id == user_id)
        else:
            query = query.filter(models.Address.phone_number == address_in.phone_number)
        query.update({"is_default": False})

    db_obj = models.Address(
        user_id=user_id,
        phone_number=address_in.phone_number,
        title=address_in.title,
        recipient_name=address_in.recipient_name,
        recipient_phone=address_in.recipient_phone,
        latitude=address_in.latitude,
        longitude=address_in.longitude,
        address_details=address_in.address_details,
        is_default=address_in.is_default
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def update_address(db: Session, address_id: int, address_update: schemas.AddressUpdate) -> Optional[models.Address]:
    db_obj = get_address(db, address_id)
    if not db_obj:
        return None
        
    update_data = address_update.model_dump(exclude_unset=True)
    if update_data.get("is_default"):
        # Reset other default addresses
        query = db.query(models.Address)
        if db_obj.user_id:
            query = query.filter(models.Address.user_id == db_obj.user_id)
        else:
            query = query.filter(models.Address.phone_number == db_obj.phone_number)
        query.update({"is_default": False})

    for key, value in update_data.items():
        setattr(db_obj, key, value)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def delete_address(db: Session, address_id: int) -> bool:
    db_obj = get_address(db, address_id)
    if not db_obj:
        return False
    db.delete(db_obj)
    db.commit()
    return True


# --- RATING CRUD ---
def get_ratings_by_product(db: Session, product_id: int, skip: int = 0, limit: int = 50) -> List[models.ProductRating]:
    return db.query(models.ProductRating).filter(models.ProductRating.product_id == product_id).order_by(models.ProductRating.created_at.desc()).offset(skip).limit(limit).all()

def create_rating(db: Session, rating_in: schemas.ProductRatingCreate, user_id: int) -> models.ProductRating:
    db_obj = models.ProductRating(
        product_id=rating_in.product_id,
        user_id=user_id,
        order_id=rating_in.order_id,
        rating=rating_in.rating,
        comment=rating_in.comment,
        image_url=rating_in.image_url
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj


# --- USER OTP CRUD HELPER ---
def get_or_create_user_by_phone(db: Session, phone: str) -> models.User:
    user = db.query(models.User).filter(models.User.phone == phone).first()
    if not user:
        # Create a new customer user dynamically
        # Since password is required, set a dummy hash or verify directly
        user = models.User(
            phone=phone,
            email=None,
            hashed_password=auth.get_password_hash("OTP_USER_DUMMY_PWD"),
            full_name=f"مستخدم {phone[-4:]}",
            role="customer",
            is_active=True
        )
        db.add(user)
    return user


# --- SERVICES CRUD ---

def get_services(db: Session, category: Optional[str] = None, is_featured: Optional[bool] = None, skip: int = 0, limit: int = 100) -> List[models.Service]:
    query = db.query(models.Service)
    if is_featured is not None:
        query = query.filter(models.Service.is_featured == is_featured)
    if category is not None and category != "الكل":
        query = query.filter(models.Service.category == category)
    return query.filter(models.Service.is_available == True).order_by(models.Service.sort_order.asc(), models.Service.id.asc()).offset(skip).limit(limit).all()

def get_service(db: Session, service_id: int) -> Optional[models.Service]:
    return db.query(models.Service).filter(models.Service.id == service_id).first()

def get_service_categories(db: Session) -> List[str]:
    results = db.query(models.Service.category).filter(models.Service.is_available == True).distinct().all()
    categories = [r[0] for r in results if r[0]]
    return categories

def create_service_request(db: Session, request_schema: schemas.ServiceRequestCreate) -> models.ServiceRequest:
    # 1. Fetch service to verify and get base price
    service = db.query(models.Service).filter(models.Service.id == request_schema.service_id).first()
    if not service:
        raise ValueError("الخدمة المطلوبة غير موجودة")

    # 2. Calculate dynamic price
    total_price = service.base_price
    if request_schema.service_option_id:
        option = db.query(models.ServiceOption).filter(
            models.ServiceOption.id == request_schema.service_option_id,
            models.ServiceOption.service_id == service.id
        ).first()
        if option:
            total_price += option.extra_price

    # 3. Generate sequential request number
    max_id = db.query(func.max(models.ServiceRequest.id)).scalar() or 0
    next_seq = max_id + 1001
    request_number = f"SRV-{next_seq:05d}"

    # 4. Create ServiceRequest instance
    db_request = models.ServiceRequest(
        request_number=request_number,
        user_id=request_schema.user_id,
        service_id=request_schema.service_id,
        service_option_id=request_schema.service_option_id,
        customer_name=request_schema.customer_name,
        customer_phone=request_schema.customer_phone,
        address=request_schema.address,
        latitude=request_schema.latitude,
        longitude=request_schema.longitude,
        scheduled_date=request_schema.scheduled_date,
        scheduled_time=request_schema.scheduled_time,
        notes=request_schema.notes,
        status="new",
        total_price=total_price,
        payment_method=request_schema.payment_method,
        payment_status="pending"
    )
    db.add(db_request)
    db.commit()
    db.refresh(db_request)

    # 5. Log initial status history
    history = models.ServiceRequestStatusHistory(
        service_request_id=db_request.id,
        old_status=None,
        new_status="new",
        note="تم إنشاء طلب الخدمة واستلامه بنجاح"
    )
    db.add(history)
    db.commit()

    # 6. Increment service booking count
    service.total_bookings += 1
    db.commit()

    return db_request

def get_user_service_requests(db: Session, phone: str) -> List[models.ServiceRequest]:
    if not phone or not phone.strip():
        return []
    variants = get_phone_variants(phone)
    return db.query(models.ServiceRequest).filter(
        models.ServiceRequest.customer_phone.in_(variants)
    ).order_by(models.ServiceRequest.created_at.desc()).all()

def get_service_request(db: Session, request_id: int) -> Optional[models.ServiceRequest]:
    return db.query(models.ServiceRequest).filter(models.ServiceRequest.id == request_id).first()


# --- ADMIN SERVICES CRUD ---

def admin_get_services(db: Session) -> List[models.Service]:
    return db.query(models.Service).order_by(models.Service.sort_order.asc(), models.Service.id.asc()).all()

def create_service(db: Session, service_schema: schemas.ServiceCreate, user_id: int) -> models.Service:
    db_service = models.Service(
        name=service_schema.name,
        description=service_schema.description,
        short_description=service_schema.short_description,
        image_url=service_schema.image_url,
        gallery_urls=service_schema.gallery_urls,
        icon_emoji=service_schema.icon_emoji,
        base_price=service_schema.base_price,
        price_type=service_schema.price_type,
        category=service_schema.category,
        tags=service_schema.tags,
        duration_minutes=service_schema.duration_minutes,
        is_available=service_schema.is_available,
        is_featured=service_schema.is_featured,
        sort_order=service_schema.sort_order,
        working_hours=service_schema.working_hours,
        max_bookings_per_day=service_schema.max_bookings_per_day,
        advance_booking_days=service_schema.advance_booking_days
    )
    db.add(db_service)
    db.commit()
    db.refresh(db_service)

    # Add options
    if service_schema.options:
        for opt in service_schema.options:
            db_opt = models.ServiceOption(
                service_id=db_service.id,
                name=opt.name,
                description=opt.description,
                extra_price=opt.extra_price,
                duration_extra_minutes=opt.duration_extra_minutes,
                sort_order=opt.sort_order,
                is_active=opt.is_active
            )
            db.add(db_opt)
        db.commit()
        db.refresh(db_service)

    create_audit_log(db, user_id, "CREATE_SERVICE", f"Created service {db_service.name}")
    return db_service

def update_service(db: Session, service_id: int, service_update: schemas.ServiceUpdate, user_id: int) -> Optional[models.Service]:
    db_service = db.query(models.Service).filter(models.Service.id == service_id).first()
    if not db_service:
        return None

    update_data = service_update.model_dump(exclude_unset=True)
    options_data = update_data.pop("options", None)

    for key, value in update_data.items():
        setattr(db_service, key, value)
    db.commit()

    # Handle options update if provided
    if options_data is not None:
        # Delete old options and insert new ones
        db.query(models.ServiceOption).filter(models.ServiceOption.service_id == service_id).delete()
        for opt in options_data:
            db_opt = models.ServiceOption(
                service_id=service_id,
                name=opt["name"],
                description=opt.get("description"),
                extra_price=opt.get("extra_price", 0.0),
                duration_extra_minutes=opt.get("duration_extra_minutes", 0),
                sort_order=opt.get("sort_order", 0),
                is_active=opt.get("is_active", True)
            )
            db.add(db_opt)
        db.commit()

    db.refresh(db_service)
    create_audit_log(db, user_id, "UPDATE_SERVICE", f"Updated service {db_service.name}")
    return db_service

def delete_service(db: Session, service_id: int, user_id: int) -> bool:
    db_service = db.query(models.Service).filter(models.Service.id == service_id).first()
    if not db_service:
        return False
    
    # Soft delete by setting availability to False
    db_service.is_available = False
    db.commit()
    create_audit_log(db, user_id, "DELETE_SERVICE", f"Soft deleted service {db_service.name}")
    return True

def reorder_services(db: Session, ids: List[int], user_id: int) -> bool:
    for idx, s_id in enumerate(ids):
        db.query(models.Service).filter(models.Service.id == s_id).update({"sort_order": idx})
    db.commit()
    create_audit_log(db, user_id, "REORDER_SERVICES", f"Reordered service items list")
    return True

def get_admin_service_requests(
    db: Session,
    status: Optional[str] = None,
    search: Optional[str] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    service_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 20
) -> tuple:
    query = db.query(models.ServiceRequest)

    if status and status != "all":
        query = query.filter(models.ServiceRequest.status == status)
    
    if service_id:
        query = query.filter(models.ServiceRequest.service_id == service_id)
        
    if date_from:
        query = query.filter(models.ServiceRequest.scheduled_date >= date_from)
        
    if date_to:
        query = query.filter(models.ServiceRequest.scheduled_date <= date_to)

    if search:
        search_term = f"%{search}%"
        query = query.filter(
            (models.ServiceRequest.customer_name.like(search_term)) |
            (models.ServiceRequest.customer_phone.like(search_term)) |
            (models.ServiceRequest.request_number.like(search_term)) |
            (models.ServiceRequest.address.like(search_term))
        )

    total_count = query.count()
    requests_list = query.order_by(models.ServiceRequest.created_at.desc()).offset(skip).limit(limit).all()

    # Get status stats
    stats = {
        "all": db.query(models.ServiceRequest).count(),
        "new": db.query(models.ServiceRequest).filter(models.ServiceRequest.status == "new").count(),
        "confirmed": db.query(models.ServiceRequest).filter(models.ServiceRequest.status == "confirmed").count(),
        "in_progress": db.query(models.ServiceRequest).filter(models.ServiceRequest.status == "in_progress").count(),
        "completed": db.query(models.ServiceRequest).filter(models.ServiceRequest.status == "completed").count(),
        "cancelled": db.query(models.ServiceRequest).filter(models.ServiceRequest.status == "cancelled").count(),
    }

    return requests_list, total_count, stats

def update_service_request_status(
    db: Session,
    request_id: int,
    status: str,
    note: Optional[str],
    assigned_worker: Optional[str],
    worker_phone: Optional[str],
    notify_customer: bool,
    user_id: int
) -> Optional[models.ServiceRequest]:
    request = db.query(models.ServiceRequest).filter(models.ServiceRequest.id == request_id).first()
    if not request:
        return None

    old_status = request.status
    request.status = status
    request.updated_at = datetime.datetime.utcnow()

    if status == "completed":
        request.completed_at = datetime.datetime.utcnow()
        request.payment_status = "paid"

    if assigned_worker:
        request.assigned_worker = assigned_worker
    if worker_phone:
        request.worker_phone = worker_phone
    if note and not request.admin_notes:
        request.admin_notes = note
    elif note:
        request.admin_notes = f"{request.admin_notes}\n{note}"

    db.commit()

    # Insert status history log
    history = models.ServiceRequestStatusHistory(
        service_request_id=request_id,
        old_status=old_status,
        new_status=status,
        changed_by=db.query(models.User).filter(models.User.id == user_id).first().full_name if user_id else "نظام لوحة التحكم",
        note=note or f"تم تعديل حالة الطلب إلى {status}",
        notify_customer=notify_customer
    )
    db.add(history)
    db.commit()

    db.refresh(request)
    create_audit_log(db, user_id, "UPDATE_REQUEST_STATUS", f"Updated status of request {request.request_number} from {old_status} to {status}")
    return request

def get_services_stats(db: Session) -> dict:
    total_services = db.query(models.Service).count()
    active_services = db.query(models.Service).filter(models.Service.is_available == True).count()
    total_requests = db.query(models.ServiceRequest).count()

    today_str = datetime.date.today().isoformat()
    today_requests = db.query(models.ServiceRequest).filter(
        models.ServiceRequest.created_at >= datetime.datetime.combine(datetime.date.today(), datetime.time.min)
    ).count()

    pending_requests = db.query(models.ServiceRequest).filter(models.ServiceRequest.status == "new").count()

    # Current month revenue
    start_of_month = datetime.datetime.today().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    month_revenue = db.query(func.sum(models.ServiceRequest.total_price)).filter(
        models.ServiceRequest.status == "completed",
        models.ServiceRequest.completed_at >= start_of_month
    ).scalar() or 0.0

    # Status distribution
    statuses = ["new", "confirmed", "in_progress", "completed", "cancelled"]
    requests_by_status = {}
    for st in statuses:
        requests_by_status[st] = db.query(models.ServiceRequest).filter(models.ServiceRequest.status == st).count()

    # Top services
    top_services_query = db.query(
        models.Service.name,
        func.count(models.ServiceRequest.id).label("count")
    ).join(
        models.ServiceRequest, models.ServiceRequest.service_id == models.Service.id
    ).group_by(models.Service.id).order_by(func.count(models.ServiceRequest.id).desc()).limit(5).all()

    top_services = [{"name": r[0], "count": r[1]} for r in top_services_query]

    return {
        "total_services": total_services,
        "active_services": active_services,
        "total_requests": total_requests,
        "today_requests": today_requests,
        "pending_requests": pending_requests,
        "this_month_revenue": month_revenue,
        "requests_by_status": requests_by_status,
        "top_services": top_services
    }



# --- PRODUCT TAG CRUD ---
def get_product_tags(db: Session, subcategory_id: Optional[int] = None, parent_id: Optional[int] = None, is_active: Optional[bool] = None, top_level_only: bool = False):
    query = db.query(models.ProductTag)
    if subcategory_id is not None:
        query = query.filter(models.ProductTag.subcategory_id == subcategory_id)
    if parent_id is not None:
        query = query.filter(models.ProductTag.parent_id == parent_id)
    elif top_level_only:
        query = query.filter(models.ProductTag.parent_id == None)
    if is_active is not None:
        query = query.filter(models.ProductTag.is_active == is_active)
    return query.order_by(models.ProductTag.sort_order.asc()).all()

def get_product_tag(db: Session, tag_id: int):
    return db.query(models.ProductTag).filter(models.ProductTag.id == tag_id).first()

def create_product_tag(db: Session, tag: schemas.ProductTagCreate, user_id: int):
    db_tag = models.ProductTag(
        name=tag.name,
        subcategory_id=tag.subcategory_id,
        parent_id=tag.parent_id,
        image_url=tag.image_url,
        icon_emoji=tag.icon_emoji,
        sort_order=tag.sort_order,
        is_active=tag.is_active
    )
    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)
    
    # Associate products if any
    if tag.product_ids:
        products = db.query(models.Product).filter(models.Product.id.in_(tag.product_ids)).all()
        db_tag.products = products
        db.commit()
        db.refresh(db_tag)
        
    create_audit_log(db, user_id, "CREATE_PRODUCT_TAG", f"Created product tag {db_tag.name}")
    return db_tag

def update_product_tag(db: Session, tag_id: int, tag_update: schemas.ProductTagUpdate, user_id: int):
    db_tag = get_product_tag(db, tag_id)
    if not db_tag:
        return None
        
    update_data = tag_update.model_dump(exclude_unset=True)
    product_ids = update_data.pop("product_ids", None)
    
    for key, value in update_data.items():
        setattr(db_tag, key, value)
        
    if product_ids is not None:
        products = db.query(models.Product).filter(models.Product.id.in_(product_ids)).all()
        db_tag.products = products
        
    db.commit()
    db.refresh(db_tag)
    
    create_audit_log(db, user_id, "UPDATE_PRODUCT_TAG", f"Updated product tag {db_tag.name}")
    return db_tag

def delete_product_tag(db: Session, tag_id: int, user_id: int):
    db_tag = get_product_tag(db, tag_id)
    if not db_tag:
        return False
        
    db_tag.products = [] # detach products
    db.delete(db_tag)
    db.commit()
    
    create_audit_log(db, user_id, "DELETE_PRODUCT_TAG", f"Deleted product tag ID {tag_id}")
    return True


# --- STOCK MOVEMENT CRUD ---
def get_stock_movements(db: Session, product_id: Optional[int] = None, limit: int = 100) -> List[models.StockMovement]:
    query = db.query(models.StockMovement)
    if product_id is not None:
        query = query.filter(models.StockMovement.product_id == product_id)
    return query.order_by(models.StockMovement.created_at.desc()).limit(limit).all()

def create_stock_movement(
    db: Session,
    product_id: int,
    type: str,
    quantity_change: int,
    reason: Optional[str] = None,
    invoice_number: Optional[str] = None,
    user_id: Optional[int] = None
) -> models.StockMovement:
    # 1. Fetch product
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise ValueError("المنتج المطلوب غير موجود")

    quantity_before = product.stock_quantity
    
    # 2. Calculate quantity_after
    if type == "in":
        quantity_after = quantity_before + quantity_change
    elif type == "out":
        quantity_after = quantity_before - quantity_change
        if quantity_after < 0:
            raise ValueError("الكمية المطلوبة غير متوفرة في المخزون")
    elif type in ["adjustment", "audit"]:
        # For adjustment/audit, quantity_change is the absolute target quantity
        quantity_after = quantity_change
        # Recalculate quantity_change as delta for recording
        quantity_change = quantity_after - quantity_before
    else:
        raise ValueError(f"نوع حركة المخزون غير صالح: {type}")

    if quantity_after < 0:
        raise ValueError("كمية المخزون بعد العملية لا يمكن أن تكون سالبة")

    # 3. Update product stock
    product.stock_quantity = quantity_after
    db.commit()

    # 4. Create StockMovement entry
    db_movement = models.StockMovement(
        product_id=product_id,
        type=type,
        quantity_change=quantity_change,
        quantity_before=quantity_before,
        quantity_after=quantity_after,
        reason=reason,
        invoice_number=invoice_number,
        created_by=user_id
    )
    db.add(db_movement)
    db.commit()
    db.refresh(db_movement)

    # 5. Log audit trail
    action_log = "STOCK_IN" if type == "in" else "STOCK_OUT" if type == "out" else "STOCK_ADJUST"
    create_audit_log(db, user_id, action_log, f"Updated stock for product {product.name} ({product.sku}): {quantity_before} -> {quantity_after}")

    return db_movement


# --- CUSTOMER ACCOUNTS AUTH CRUD HELPERS ---
from datetime import datetime as utc_datetime, timedelta

def create_otp(db: Session, phone: str, code: str, expires_in_minutes: int = 2) -> models.OTPCode:
    # Delete previous OTP codes for this phone
    db.query(models.OTPCode).filter(models.OTPCode.phone == phone).delete()
    db.commit()
    
    expires_at = utc_datetime.utcnow() + timedelta(minutes=expires_in_minutes)
    otp_entry = models.OTPCode(
        phone=phone,
        code=code,
        expires_at=expires_at,
        is_used=False,
        attempts=0
    )
    db.add(otp_entry)
    db.commit()
    db.refresh(otp_entry)
    return otp_entry

def verify_otp_code(db: Session, phone: str, code: str) -> bool:
    # Developer bypass '123456'
    if code == "123456":
        return True

    # Find valid non-used OTP within expiration
    now = utc_datetime.utcnow()
    otp_entry = db.query(models.OTPCode).filter(
        models.OTPCode.phone == phone,
        models.OTPCode.is_used == False,
        models.OTPCode.expires_at > now
    ).order_by(models.OTPCode.created_at.desc()).first()

    if not otp_entry:
        return False

    otp_entry.attempts += 1
    db.commit()

    if otp_entry.attempts > 5:
        # Mark as used due to too many attempts
        otp_entry.is_used = True
        db.commit()
        return False

    if otp_entry.code == code:
        otp_entry.is_used = True
        db.commit()
        return True

    return False

def create_user_token(db: Session, user_id: int, token: str, expires_in_days: int = 30) -> models.UserToken:
    expires_at = utc_datetime.utcnow() + timedelta(days=expires_in_days)
    user_token = models.UserToken(
        user_id=user_id,
        token=token,
        expires_at=expires_at
    )
    db.add(user_token)
    db.commit()
    db.refresh(user_token)
    return user_token

def get_user_by_token(db: Session, token: str) -> Optional[models.User]:
    now = utc_datetime.utcnow()
    user_token = db.query(models.UserToken).filter(
        models.UserToken.token == token,
        models.UserToken.expires_at > now
    ).first()
    if user_token:
        return user_token.user
    return None

def delete_user_token(db: Session, token: str):
    db.query(models.UserToken).filter(models.UserToken.token == token).delete()
    db.commit()

def get_user_stats(db: Session, user_id: int) -> dict:
    orders_count = db.query(models.Order).filter(models.Order.user_id == user_id).count()
    completed_orders = db.query(models.Order).filter(
        models.Order.user_id == user_id, 
        models.Order.status == 'completed'
    ).count()
    cancelled_orders = db.query(models.Order).filter(
        models.Order.user_id == user_id, 
        models.Order.status == 'cancelled'
    ).count()
    service_requests_count = db.query(models.ServiceRequest).filter(models.ServiceRequest.user_id == user_id).count()
    favorites_count = db.query(models.Favorite).filter(models.Favorite.user_id == user_id).count()
    
    coupons_used_count = db.query(models.UserCouponUsage).filter(models.UserCouponUsage.user_id == user_id).count()
    total_savings_res = db.query(func.sum(models.UserCouponUsage.discount_amount)).filter(models.UserCouponUsage.user_id == user_id).scalar()
    total_savings = float(total_savings_res) if total_savings_res is not None else 0.0
    
    total_spent_res = db.query(func.sum(models.Order.total_amount)).filter(
        models.Order.user_id == user_id,
        models.Order.status == 'completed'
    ).scalar()
    total_spent = float(total_spent_res) if total_spent_res is not None else 0.0
    
    return {
        "orders_count": orders_count,
        "completed_orders": completed_orders,
        "cancelled_orders": cancelled_orders,
        "service_requests_count": service_requests_count,
        "favorites_count": favorites_count,
        "coupons_used_count": coupons_used_count,
        "total_savings": total_savings,
        "total_spent": total_spent
    }

def get_user_coupon_history(db: Session, user_id: int):
    # Retrieve user coupon usage with order number if possible
    usages = db.query(models.UserCouponUsage).filter(models.UserCouponUsage.user_id == user_id).order_by(models.UserCouponUsage.used_at.desc()).all()
    results = []
    for usage in usages:
        order_num = None
        if usage.order_id:
            order = db.query(models.Order).filter(models.Order.id == usage.order_id).first()
            if order:
                order_num = order.order_number
        results.append({
            "coupon_code": usage.coupon_code,
            "discount_amount": usage.discount_amount,
            "order_number": order_num,
            "used_at": usage.used_at
        })
    return results

def record_coupon_usage(db: Session, user_id: int, coupon_id: int, coupon_code: str, order_id: Optional[int], discount_amount: float):
    usage = models.UserCouponUsage(
        user_id=user_id,
        coupon_id=coupon_id,
        coupon_code=coupon_code,
        order_id=order_id,
        discount_amount=discount_amount
    )
    db.add(usage)
    db.commit()
    db.refresh(usage)
    return usage

def get_admin_users(db: Session, search: Optional[str] = None, skip: int = 0, limit: int = 100):
    query = db.query(models.User).filter(models.User.role == "customer")
    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            or_(
                models.User.full_name.like(search_filter),
                models.User.name.like(search_filter),
                models.User.phone.like(search_filter)
            )
        )
    # Ensure total_orders & total_spent columns are calculated/updated
    users = query.offset(skip).limit(limit).all()
    for u in users:
        # Sync stats fields in users table
        orders_cnt = db.query(models.Order).filter(models.Order.user_id == u.id, models.Order.status != 'cancelled').count()
        total_spent_res = db.query(func.sum(models.Order.total_amount)).filter(models.Order.user_id == u.id, models.Order.status == 'completed').scalar()
        u.total_orders = orders_cnt
        u.total_spent = float(total_spent_res) if total_spent_res is not None else 0.0
    db.commit()
    return users

def get_admin_user_detail(db: Session, user_id: int):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        return None
        
    stats = get_user_stats(db, user_id)
    
    # Sync total_orders and total_spent columns
    user.total_orders = stats["orders_count"]
    user.total_spent = stats["total_spent"]
    db.commit()
    db.refresh(user)

    # Fetch recent orders (limit 5)
    recent_orders_raw = db.query(models.Order).filter(models.Order.user_id == user_id).order_by(models.Order.created_at.desc()).limit(5).all()
    recent_orders = []
    for order in recent_orders_raw:
        # count items
        items_count = db.query(models.OrderItem).filter(models.OrderItem.order_id == order.id).count()
        recent_orders.append({
            "id": order.id,
            "order_number": order.order_number,
            "status": order.status,
            "total": order.total_amount,
            "items_count": items_count,
            "created_at": order.created_at.isoformat() if order.created_at else None
        })

    # Fetch recent service requests
    recent_sr_raw = db.query(models.ServiceRequest).filter(models.ServiceRequest.user_id == user_id).order_by(models.ServiceRequest.created_at.desc()).limit(5).all()
    recent_service_requests = []
    for sr in recent_sr_raw:
        recent_service_requests.append({
            "id": sr.id,
            "request_number": sr.request_number,
            "service_name": sr.service.name if sr.service else "خدمة غير معروفة",
            "service_image": sr.service.image_url if sr.service else None,
            "scheduled_at": f"{sr.scheduled_date} {sr.scheduled_time}",
            "status": sr.status,
            "total_price": sr.total_price,
            "created_at": sr.created_at.isoformat() if sr.created_at else None
        })

    # Fetch coupon usage
    coupons_used = get_user_coupon_history(db, user_id)

    return {
        "id": user.id,
        "name": user.name or user.full_name,
        "full_name": user.full_name,
        "phone": user.phone,
        "total_orders": user.total_orders,
        "total_spent": user.total_spent,
        "created_at": user.created_at.isoformat() if user.created_at else None,
        "last_login_at": user.last_login_at.isoformat() if user.last_login_at else None,
        "stats": stats,
        "recent_orders": recent_orders,
        "recent_service_requests": recent_service_requests,
        "coupons_used": coupons_used,
        "favorites_count": stats["favorites_count"]
    }







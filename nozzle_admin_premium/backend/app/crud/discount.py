from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from datetime import datetime
from typing import List, Optional, Tuple
from app.models.discount import Coupon
from app.schemas.discount import CouponCreate, CouponUpdate, CouponValidationRequest, CouponValidationResponse

def get_coupon(db: Session, coupon_id: int) -> Optional[Coupon]:
    """
    Retrieves a single coupon by its integer ID.
    """
    return db.query(Coupon).filter(Coupon.id == coupon_id).first()

def get_coupon_by_code(db: Session, code: str) -> Optional[Coupon]:
    """
    Retrieves a single coupon by its code string (case-insensitive).
    """
    return db.query(Coupon).filter(Coupon.code.ilike(code)).first()

def get_coupons(
    db: Session,
    *,
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False
) -> List[Coupon]:
    """
    Retrieves a list of coupons. If active_only is True, filters out inactive or out-of-schedule coupons.
    """
    query = db.query(Coupon)
    
    if active_only:
        now = datetime.utcnow()
        query = query.filter(
            Coupon.is_active == True,
            or_(Coupon.start_date == None, Coupon.start_date <= now),
            or_(Coupon.end_date == None, Coupon.end_date >= now)
        )
        
    return query.order_by(Coupon.created_at.desc()).offset(skip).limit(limit).all()

def create_coupon(db: Session, *, obj_in: CouponCreate) -> Coupon:
    """
    Creates and persists a new coupon.
    """
    db_obj = Coupon(
        code=obj_in.code,
        discount_type=obj_in.discount_type,
        value=obj_in.value,
        min_order_value=obj_in.min_order_value,
        max_discount_value=obj_in.max_discount_value,
        usage_limit=obj_in.usage_limit,
        start_date=obj_in.start_date,
        end_date=obj_in.end_date,
        user_id=obj_in.user_id,
        product_ids=obj_in.product_ids,
        category_ids=obj_in.category_ids,
        buy_x=obj_in.buy_x,
        get_y=obj_in.get_y,
        get_y_discount=obj_in.get_y_discount,
        is_active=obj_in.is_active
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def update_coupon(db: Session, *, db_obj: Coupon, obj_in: CouponUpdate) -> Coupon:
    """
    Selectively updates coupon fields.
    """
    update_data = obj_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(db_obj, field, update_data[field])
    db.commit()
    db.refresh(db_obj)
    return db_obj

def delete_coupon(db: Session, *, coupon_id: int) -> bool:
    """
    Deletes a coupon record.
    """
    db_obj = db.query(Coupon).filter(Coupon.id == coupon_id).first()
    if db_obj:
        db.delete(db_obj)
        db.commit()
        return True
    return False

def increment_coupon_usage(db: Session, *, coupon_id: int) -> bool:
    """
    Increments the usage count of a coupon when a checkout order completes.
    """
    db_obj = db.query(Coupon).filter(Coupon.id == coupon_id).first()
    if db_obj:
        db_obj.usage_count += 1
        db.commit()
        db.refresh(db_obj)
        return True
    return False

def validate_coupon_code(db: Session, *, validation_in: CouponValidationRequest) -> CouponValidationResponse:
    """
    Core validation and calculation engine for checking coupon applicability against checkout carts.
    """
    coupon = get_coupon_by_code(db, validation_in.code)
    
    # 1. Check existence
    if not coupon:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="كوبون الخصم غير موجود")
        
    # 2. Check active flag
    if not coupon.is_active:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="هذا الكوبون غير فعال حالياً")
        
    # 3. Check start/end dates
    now = datetime.utcnow()
    if coupon.start_date and coupon.start_date > now:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="عرض الكوبون لم يبدأ بعد")
    if coupon.end_date and coupon.end_date < now:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="انتهت صلاحية هذا الكوبون")
        
    # 4. Check global usage limit
    if coupon.usage_limit is not None and coupon.usage_count >= coupon.usage_limit:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="وصل هذا الكوبون للحد الأقصى للاستخدام")
        
    # 5. Check user restriction
    if coupon.user_id is not None and coupon.user_id != validation_in.user_id:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="هذا الكوبون غير مخصص لحسابك")
        
    # 6. Check minimum order value
    if coupon.min_order_value is not None and validation_in.order_value < coupon.min_order_value:
        return CouponValidationResponse(
            valid=False, 
            discount_amount=0.0, 
            message=f"الحد الأدنى لاستخدام هذا الكوبون هو {coupon.min_order_value}"
        )
        
    # 7. Check product/category scoping and calculate discount
    discount_amount = 0.0
    
    # Scope flags
    has_product_limit = len(coupon.product_ids) > 0
    has_category_limit = len(coupon.category_ids) > 0
    
    if coupon.discount_type == "buy_x_get_y":
        # Check Buy X Get Y deals
        if not coupon.buy_x or not coupon.get_y:
            return CouponValidationResponse(valid=False, discount_amount=0.0, message="إعدادات عرض 'اشترِ X واحصل على Y' غير مكتملة")
            
        total_qualifying_items = 0
        applicable_items = []
        
        for item in validation_in.items:
            # Check if item product or category fits restrictions
            fits_prod = not has_product_limit or item.product_id in coupon.product_ids
            fits_cat = not has_category_limit or item.category_id in coupon.category_ids
            
            if fits_prod and fits_cat:
                applicable_items.append(item)
                total_qualifying_items += item.quantity
                
        # Must meet the minimum buy criteria
        if total_qualifying_items < coupon.buy_x:
            return CouponValidationResponse(
                valid=False,
                discount_amount=0.0,
                message=f"هذا العرض يتطلب شراء {coupon.buy_x} منتجات على الأقل"
            )
            
        # Buy X Get Y logic applied to cart items (starting from cheapest item for strict safety)
        # Sort items by price ascending
        applicable_items.sort(key=lambda x: x.price)
        
        # Calculate how many Y items can be discounted
        # Formula: total groups of (X + Y) items
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
        # Standard percentage / fixed coupons
        qualifying_value = 0.0
        has_limit = has_product_limit or has_category_limit
        
        for item in validation_in.items:
            fits_prod = not has_product_limit or item.product_id in coupon.product_ids
            fits_cat = not has_category_limit or item.category_id in coupon.category_ids
            
            if fits_prod and fits_cat:
                qualifying_value += item.price * item.quantity
                
        if has_limit and qualifying_value <= 0:
            return CouponValidationResponse(valid=False, discount_amount=0.0, message="لا توجد منتجات مشمولة بالكوبون في السلة")
            
        # Apply rate to qualifying value
        if coupon.discount_type == "percentage":
            discount_amount = (coupon.value / 100.0) * qualifying_value
            if coupon.max_discount_value is not None:
                discount_amount = min(discount_amount, coupon.max_discount_value)
        elif coupon.discount_type == "fixed":
            # Cap fixed discount at qualifying value
            discount_amount = min(coupon.value, qualifying_value)
            
    if discount_amount <= 0.0:
        return CouponValidationResponse(valid=False, discount_amount=0.0, message="لم يترتب أي خصم على السلة الحالية")
        
    return CouponValidationResponse(
        valid=True,
        discount_amount=round(discount_amount, 2),
        message="تم تطبيق الكوبون بنجاح",
        coupon_id=coupon.id
    )

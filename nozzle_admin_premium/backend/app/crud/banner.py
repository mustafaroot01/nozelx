from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from datetime import datetime
from typing import List, Optional, Dict, Any
from app.models.banner import Banner
from app.schemas.banner import BannerCreate, BannerUpdate

def get_banner(db: Session, banner_id: int) -> Optional[Banner]:
    """
    Retrieves a single banner by its ID.
    """
    return db.query(Banner).filter(Banner.id == banner_id).first()

def get_banners(
    db: Session,
    *,
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False
) -> List[Banner]:
    """
    Retrieves a list of banners. If active_only is True, filters out inactive or out-of-schedule banners.
    """
    query = db.query(Banner)
    
    if active_only:
        now = datetime.utcnow()
        query = query.filter(
            Banner.is_active == True,
            or_(Banner.start_date == None, Banner.start_date <= now),
            or_(Banner.end_date == None, Banner.end_date >= now)
        )
        
    return query.order_by(Banner.sort_order.asc(), Banner.created_at.desc()).offset(skip).limit(limit).all()

def create_banner(db: Session, *, obj_in: BannerCreate) -> Banner:
    """
    Creates and persists a new banner.
    """
    db_obj = Banner(
        title=obj_in.title,
        image_url=obj_in.image_url,
        mobile_image_url=obj_in.mobile_image_url,
        link_type=obj_in.link_type,
        product_id=obj_in.product_id,
        category_id=obj_in.category_id,
        external_url=obj_in.external_url,
        sort_order=obj_in.sort_order,
        start_date=obj_in.start_date,
        end_date=obj_in.end_date,
        is_active=obj_in.is_active
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def update_banner(db: Session, *, db_obj: Banner, obj_in: BannerUpdate) -> Banner:
    """
    Selectively updates banner fields.
    """
    update_data = obj_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(db_obj, field, update_data[field])
    db.commit()
    db.refresh(db_obj)
    return db_obj

def delete_banner(db: Session, *, banner_id: int) -> bool:
    """
    Deletes a banner record.
    """
    db_obj = db.query(Banner).filter(Banner.id == banner_id).first()
    if db_obj:
        db.delete(db_obj)
        db.commit()
        return True
    return False

def increment_views(db: Session, *, banner_id: int) -> bool:
    """
    Increments the view counter for a banner.
    """
    db_obj = db.query(Banner).filter(Banner.id == banner_id).first()
    if db_obj:
        db_obj.views += 1
        db.commit()
        return True
    return False

def increment_clicks(db: Session, *, banner_id: int) -> bool:
    """
    Increments the click counter for a banner.
    """
    db_obj = db.query(Banner).filter(Banner.id == banner_id).first()
    if db_obj:
        db_obj.clicks += 1
        db.commit()
        return True
    return False

def update_banner_sort_orders(db: Session, *, sort_data: List[Dict[str, int]]) -> bool:
    """
    Updates sorting orders for multiple banners.
    """
    try:
        for item in sort_data:
            b_id = item.get("id")
            new_order = item.get("sort_order")
            if b_id is not None and new_order is not None:
                db.query(Banner).filter(Banner.id == b_id).update({"sort_order": new_order})
        db.commit()
        return True
    except Exception:
        db.rollback()
        return False

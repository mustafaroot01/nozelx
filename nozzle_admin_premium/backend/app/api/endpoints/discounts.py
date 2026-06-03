from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List

from app.api import deps
from app.core.database import get_db
from app.models.user import User
from app.schemas.discount import CouponCreate, CouponUpdate, CouponResponse, CouponValidationRequest, CouponValidationResponse
from app.crud import discount as crud_discount

router = APIRouter()

@router.get("/", response_model=dict)
def read_coupons(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    active_only: bool = Query(False, description="Filter only active and scheduled coupons")
):
    """
    Retrieves all e-commerce coupons.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    coupons = crud_discount.get_coupons(db, skip=skip, limit=limit, active_only=active_only)
    return {
        "status": "success",
        "data": coupons
    }

@router.get("/{coupon_id}", response_model=dict)
def read_coupon_by_id(
    coupon_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Retrieves detailed parameters of a coupon by ID.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    coupon = crud_discount.get_coupon(db, coupon_id)
    if not coupon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Coupon not found"
        )
    return {
        "status": "success",
        "data": coupon
    }

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_coupon(
    *,
    db: Session = Depends(get_db),
    obj_in: CouponCreate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Creates a new promotional coupon code.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    # Enforce unique code validation
    existing = crud_discount.get_coupon_by_code(db, obj_in.code)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"A coupon with code '{obj_in.code}' already exists."
        )
        
    coupon = crud_discount.create_coupon(db, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Coupon created successfully",
        "data": coupon
    }

@router.put("/{coupon_id}", response_model=dict)
def update_coupon(
    *,
    db: Session = Depends(get_db),
    coupon_id: int,
    obj_in: CouponUpdate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Updates an existing coupon's parameters selectively.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    coupon = crud_discount.get_coupon(db, coupon_id)
    if not coupon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Coupon not found"
        )
        
    # Verify code uniqueness if code is changing
    if obj_in.code and obj_in.code.lower() != coupon.code.lower():
        existing = crud_discount.get_coupon_by_code(db, obj_in.code)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"A coupon with code '{obj_in.code}' already exists."
            )
            
    updated_coupon = crud_discount.update_coupon(db, db_obj=coupon, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Coupon updated successfully",
        "data": updated_coupon
    }

@router.delete("/{coupon_id}", response_model=dict)
def delete_coupon(
    *,
    db: Session = Depends(get_db),
    coupon_id: int,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin"]))
):
    """
    Deletes a coupon code completely.
    Restricted to Super Admin and Admin accounts.
    """
    coupon = crud_discount.get_coupon(db, coupon_id)
    if not coupon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Coupon not found"
        )
        
    crud_discount.delete_coupon(db, coupon_id=coupon_id)
    return {
        "status": "success",
        "message": "Coupon deleted successfully"
    }

@router.post("/validate", response_model=CouponValidationResponse)
def validate_coupon(
    *,
    db: Session = Depends(get_db),
    validation_in: CouponValidationRequest
):
    """
    Validates a coupon code against a set of cart items and returns the eligible discount amount.
    Public endpoint triggered during checkout or cart review.
    """
    return crud_discount.validate_coupon_code(db, validation_in=validation_in)

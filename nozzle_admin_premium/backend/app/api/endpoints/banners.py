from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Dict

from app.api import deps
from app.core.database import get_db
from app.models.user import User
from app.schemas.banner import BannerCreate, BannerUpdate, BannerResponse
from app.crud import banner as crud_banner

router = APIRouter()

@router.get("/", response_model=dict)
def read_banners(
    db: Session = Depends(get_db),
    active_only: bool = Query(False, description="Filter only active and scheduled banners")
):
    """
    Retrieves all banner advertisements. Available to all users.
    """
    banners = crud_banner.get_banners(db, active_only=active_only)
    return {
        "status": "success",
        "data": banners
    }

@router.get("/{banner_id}", response_model=dict)
def read_banner_by_id(
    banner_id: int,
    db: Session = Depends(get_db)
):
    """
    Retrieves details for a single banner advertisement.
    """
    banner = crud_banner.get_banner(db, banner_id)
    if not banner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Banner not found"
        )
    return {
        "status": "success",
        "data": banner
    }

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_banner(
    *,
    db: Session = Depends(get_db),
    obj_in: BannerCreate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Creates a new banner advertisement.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    banner = crud_banner.create_banner(db, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Banner created successfully",
        "data": banner
    }

@router.put("/sort/order", response_model=dict)
def reorder_banners(
    *,
    db: Session = Depends(get_db),
    sort_data: List[Dict[str, int]],
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Updates sorting orders of multiple banners in bulk for drag-and-drop interfaces.
    """
    success = crud_banner.update_banner_sort_orders(db, sort_data=sort_data)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update banner sorting sequence"
        )
    return {
        "status": "success",
        "message": "Banner sorting sequence updated successfully"
    }

@router.put("/{banner_id}", response_model=dict)
def update_banner(
    *,
    db: Session = Depends(get_db),
    banner_id: int,
    obj_in: BannerUpdate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Updates an existing banner advertisement's fields selectively.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    banner = crud_banner.get_banner(db, banner_id)
    if not banner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Banner not found"
        )
        
    updated_banner = crud_banner.update_banner(db, db_obj=banner, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Banner updated successfully",
        "data": updated_banner
    }

@router.delete("/{banner_id}", response_model=dict)
def delete_banner(
    *,
    db: Session = Depends(get_db),
    banner_id: int,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin"]))
):
    """
    Deletes a banner advertisement.
    Restricted to Super Admin and Admin accounts.
    """
    banner = crud_banner.get_banner(db, banner_id)
    if not banner:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Banner not found"
        )
        
    crud_banner.delete_banner(db, banner_id=banner_id)
    return {
        "status": "success",
        "message": "Banner deleted successfully"
    }

@router.post("/{banner_id}/view", response_model=dict)
def log_banner_view(
    banner_id: int,
    db: Session = Depends(get_db)
):
    """
    Public endpoint to increment the view count of a banner.
    Should be triggered when a client renders the banner.
    """
    success = crud_banner.increment_views(db, banner_id=banner_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Banner not found"
        )
    return {
        "status": "success",
        "message": "Banner view logged successfully"
    }

@router.post("/{banner_id}/click", response_model=dict)
def log_banner_click(
    banner_id: int,
    db: Session = Depends(get_db)
):
    """
    Public endpoint to increment the click count of a banner.
    Should be triggered when a user clicks the banner.
    """
    success = crud_banner.increment_clicks(db, banner_id=banner_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Banner not found"
        )
    return {
        "status": "success",
        "message": "Banner click logged successfully"
    }

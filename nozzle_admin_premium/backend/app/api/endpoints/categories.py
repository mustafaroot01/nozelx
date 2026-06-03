from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Dict, Any

from app.api import deps
from app.core.database import get_db
from app.models.user import User
from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryUpdate
from app.crud import category as crud_category

router = APIRouter()

def format_category(db: Session, cat: Category) -> Dict[str, Any]:
    """
    Recursively formats a Category ORM object to match the response schema,
    attaching the count of active products under it.
    """
    return {
        "id": cat.id,
        "name": cat.name,
        "description": cat.description,
        "parent_id": cat.parent_id,
        "icon_url": cat.icon_url,
        "image_url": cat.image_url,
        "sort_order": cat.sort_order,
        "seo_title": cat.seo_title,
        "seo_description": cat.seo_description,
        "slug": cat.slug,
        "is_active": cat.is_active,
        "created_at": cat.created_at,
        "updated_at": cat.updated_at,
        "product_count": crud_category.get_category_product_count(db, cat.id, is_parent=(cat.parent_id is None)),
        "subcategories": [format_category(db, sub) for sub in cat.subcategories if sub.is_active]
    }

@router.get("/", response_model=dict)
def read_categories(
    db: Session = Depends(get_db),
    parent_only: bool = Query(False, description="If true, returns only parent categories without subcategory structures")
):
    """
    Retrieves all categories. Can optionally retrieve only primary parent categories.
    Attaches product counts and subcategory trees dynamically.
    """
    if parent_only:
        categories = crud_category.get_main_categories(db)
        data = [format_category(db, c) for c in categories]
    else:
        # Fetch all root categories
        root_categories = db.query(Category).filter(Category.parent_id == None).order_by(Category.sort_order.asc()).all()
        data = [format_category(db, c) for c in root_categories]
        
    return {
        "status": "success",
        "data": data
    }

@router.get("/{category_id}", response_model=dict)
def read_category_by_id(
    category_id: int,
    db: Session = Depends(get_db)
):
    """
    Retrieves a single category details including product count and its child subcategories.
    """
    cat = crud_category.get_category(db, category_id)
    if not cat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    return {
        "status": "success",
        "data": format_category(db, cat)
    }

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_category(
    *,
    db: Session = Depends(get_db),
    obj_in: CategoryCreate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Creates a new category or subcategory.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    # Verify parent exists if parent_id is specified
    if obj_in.parent_id:
        parent = crud_category.get_category(db, obj_in.parent_id)
        if not parent:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Parent category with ID '{obj_in.parent_id}' does not exist."
            )
            
    # Slug uniqueness is resolved dynamically in the CRUD layer
        
    category = crud_category.create_category(db, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Category created successfully",
        "data": format_category(db, category)
    }

@router.put("/sort/order", response_model=dict)
def reorder_categories(
    *,
    db: Session = Depends(get_db),
    sort_data: List[Dict[str, int]],
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Updates sorting orders of multiple categories in bulk for drag-and-drop interfaces.
    Expects request body format: [{"id": 1, "sort_order": 0}, {"id": 2, "sort_order": 1}]
    """
    success = crud_category.update_sort_orders(db, sort_data=sort_data)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update sorting order"
        )
    return {
        "status": "success",
        "message": "Category sorting sequence updated successfully"
    }

@router.put("/{category_id}", response_model=dict)
def update_category(
    *,
    db: Session = Depends(get_db),
    category_id: int,
    obj_in: CategoryUpdate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Updates an existing category's fields selectively.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    cat = crud_category.get_category(db, category_id)
    if not cat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
        
    # Verify parent exists if parent_id is specified
    if obj_in.parent_id:
        parent = crud_category.get_category(db, obj_in.parent_id)
        if not parent:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Parent category with ID '{obj_in.parent_id}' does not exist."
            )
            
    # Slug uniqueness is resolved dynamically in the CRUD layer
            
    updated_cat = crud_category.update_category(db, db_obj=cat, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Category updated successfully",
        "data": format_category(db, updated_cat)
    }

@router.delete("/{category_id}", response_model=dict)
def delete_category(
    *,
    db: Session = Depends(get_db),
    category_id: int,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin"]))
):
    """
    Deletes a category. All child subcategories are deleted in cascade.
    Restricted to Super Admin and Admin accounts.
    """
    cat = crud_category.get_category(db, category_id)
    if not cat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
        
    crud_category.delete_category(db, category_id=category_id)
    return {
        "status": "success",
        "message": "Category and all its subcategories deleted successfully"
    }

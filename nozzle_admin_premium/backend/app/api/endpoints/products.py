from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app.api import deps
from app.core.database import get_db
from app.models.user import User
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.crud import product as crud_product

router = APIRouter()

@router.get("/", response_model=dict)
def read_products(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="Offset for pagination"),
    limit: int = Query(20, ge=1, le=100, description="Limit size for page results"),
    search: Optional[str] = Query(None, description="Search term for name, description, or SKU"),
    category_id: Optional[int] = Query(None, description="Filter products by category ID"),
    subcategory_id: Optional[int] = Query(None, description="Filter products by subcategory ID"),
    status: Optional[str] = Query(None, description="Filter products by status (active, hidden, out_of_stock)"),
    min_price: Optional[float] = Query(None, ge=0, description="Filter products by minimum price"),
    max_price: Optional[float] = Query(None, ge=0, description="Filter products by maximum price")
):
    """
    Retrieves a list of all active products with pagination, keyword search, price range, and category filters.
    Available to all users.
    """
    total = crud_product.count_products(
        db,
        search=search,
        category_id=category_id,
        subcategory_id=subcategory_id,
        status=status,
        min_price=min_price,
        max_price=max_price
    )
    products = crud_product.get_products(
        db,
        skip=skip,
        limit=limit,
        search=search,
        category_id=category_id,
        subcategory_id=subcategory_id,
        status=status,
        min_price=min_price,
        max_price=max_price
    )
    
    # Serialize outputs to match the schema wrapper structure
    return {
        "status": "success",
        "total": total,
        "skip": skip,
        "limit": limit,
        "data": products
    }

@router.get("/{product_id}", response_model=dict)
def read_product_by_id(
    product_id: int,
    db: Session = Depends(get_db)
):
    """
    Retrieves details for a specific active product by its unique integer ID.
    Available to all users.
    """
    product = crud_product.get_product(db, product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found or has been deleted"
        )
    return {
        "status": "success",
        "data": product
    }

@router.get("/slug/{slug}", response_model=dict)
def read_product_by_slug(
    slug: str,
    db: Session = Depends(get_db)
):
    """
    Retrieves details for a specific active product by its unique SEO URL slug.
    Available to all users.
    """
    product = crud_product.get_product_by_slug(db, slug)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found or has been deleted"
        )
    return {
        "status": "success",
        "data": product
    }

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_product(
    *,
    db: Session = Depends(get_db),
    obj_in: ProductCreate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Creates a new product.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    # Enforce SKU uniqueness check if provided
    if obj_in.sku:
        existing_sku = crud_product.get_product_by_sku(db, obj_in.sku)
        if existing_sku:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"A product with SKU '{obj_in.sku}' already exists."
            )
            
    # Enforce slug uniqueness check
    existing_slug = crud_product.get_product_by_slug(db, obj_in.slug)
    if existing_slug:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"A product with URL slug '{obj_in.slug}' already exists."
        )
        
    product = crud_product.create_product(db, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Product created successfully",
        "data": product
    }

@router.put("/{product_id}", response_model=dict)
def update_product(
    *,
    db: Session = Depends(get_db),
    product_id: int,
    obj_in: ProductUpdate,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin", "manager"]))
):
    """
    Updates an existing product's fields selectively.
    Restricted to Super Admin, Admin, and Manager accounts.
    """
    product = crud_product.get_product(db, product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
        
    # Check SKU uniqueness if it's changing
    if obj_in.sku and obj_in.sku != product.sku:
        existing_sku = crud_product.get_product_by_sku(db, obj_in.sku)
        if existing_sku:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"A product with SKU '{obj_in.sku}' already exists."
            )
            
    # Check slug uniqueness if it's changing
    if obj_in.slug and obj_in.slug != product.slug:
        existing_slug = crud_product.get_product_by_slug(db, obj_in.slug)
        if existing_slug:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"A product with URL slug '{obj_in.slug}' already exists."
            )
            
    updated_product = crud_product.update_product(db, db_obj=product, obj_in=obj_in)
    return {
        "status": "success",
        "message": "Product updated successfully",
        "data": updated_product
    }

@router.delete("/{product_id}", response_model=dict)
def delete_product(
    *,
    db: Session = Depends(get_db),
    product_id: int,
    current_user: User = Depends(deps.check_roles(["superadmin", "admin"]))
):
    """
    Soft-deletes a product by marking it as deleted and hidden.
    Restricted to Super Admin and Admin accounts.
    """
    product = crud_product.get_product(db, product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
        
    crud_product.soft_delete_product(db, product_id=product_id)
    return {
        "status": "success",
        "message": "Product soft-deleted successfully"
    }

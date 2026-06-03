from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class ProductVariantSchema(BaseModel):
    sku: Optional[str] = None
    price: Optional[float] = None
    stock: int = Field(default=0, ge=0)
    options: Dict[str, str] = Field(default_factory=dict, description="e.g. {'color': 'Red', 'size': 'L'}")

class ProductBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    sale_price: Optional[float] = Field(default=None, ge=0)
    tax_rate: float = Field(default=15.0, ge=0)
    stock: int = Field(default=0, ge=0)
    low_stock_threshold: int = Field(default=10, ge=0)
    sku: Optional[str] = None
    category_id: int
    subcategory_id: Optional[int] = None
    images: List[str] = Field(default_factory=list)
    variants: List[ProductVariantSchema] = Field(default_factory=list)
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: str = Field(..., pattern=r"^[a-z0-9-]+$")
    status: str = Field(default="active", description="active, hidden, out_of_stock")

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    price: Optional[float] = Field(None, gt=0)
    sale_price: Optional[float] = None
    tax_rate: Optional[float] = None
    stock: Optional[int] = Field(None, ge=0)
    low_stock_threshold: Optional[int] = None
    sku: Optional[str] = None
    category_id: Optional[int] = None
    subcategory_id: Optional[int] = None
    images: Optional[List[str]] = None
    variants: Optional[List[ProductVariantSchema]] = None
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: Optional[str] = Field(None, pattern=r"^[a-z0-9-]+$")
    status: Optional[str] = None

# Nested Category schema for responses
class SimpleCategoryResponse(BaseModel):
    id: int
    name: str
    slug: str

    class Config:
        from_attributes = True

class ProductResponse(ProductBase):
    id: int
    created_at: datetime
    updated_at: datetime
    category: Optional[SimpleCategoryResponse] = None
    subcategory: Optional[SimpleCategoryResponse] = None

    class Config:
        from_attributes = True

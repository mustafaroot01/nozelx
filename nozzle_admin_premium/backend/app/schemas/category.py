from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class CategoryBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    parent_id: Optional[int] = Field(default=None, description="ID of parent category if this is a subcategory")
    icon_url: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: int = Field(default=0, ge=0)
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: str = Field(..., pattern=r"^[a-z0-9-]+$")
    is_active: bool = True

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = None
    parent_id: Optional[int] = None
    icon_url: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: Optional[int] = Field(None, ge=0)
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: Optional[str] = Field(None, pattern=r"^[a-z0-9-]+$")
    is_active: Optional[bool] = None

class CategoryResponse(CategoryBase):
    id: int
    created_at: datetime
    updated_at: datetime
    product_count: int = Field(default=0, description="Total active products linked directly to this category")
    subcategories: List['CategoryResponse'] = Field(default_factory=list)

    class Config:
        from_attributes = True

# Enable recursive schemas parsing in Pydantic v2
CategoryResponse.model_rebuild()

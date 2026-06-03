from pydantic import BaseModel, Field, model_validator
from typing import Optional, List
from datetime import datetime

class BannerBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=150)
    image_url: str = Field(..., description="Desktop image path")
    mobile_image_url: Optional[str] = Field(default=None, description="Mobile image path")
    link_type: str = Field(default="none", description="product, category, external, none")
    product_id: Optional[int] = None
    category_id: Optional[int] = None
    external_url: Optional[str] = None
    sort_order: int = Field(default=0, ge=0)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_active: bool = True

class BannerCreate(BannerBase):
    pass

class BannerUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=150)
    image_url: Optional[str] = None
    mobile_image_url: Optional[str] = None
    link_type: Optional[str] = None
    product_id: Optional[int] = None
    category_id: Optional[int] = None
    external_url: Optional[str] = None
    sort_order: Optional[int] = Field(None, ge=0)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_active: Optional[bool] = None

class BannerResponse(BannerBase):
    id: int
    views: int
    clicks: int
    ctr: float = Field(default=0.0, description="Click-Through Rate percentage")
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

    @model_validator(mode="before")
    @classmethod
    def calculate_ctr(cls, data: any) -> any:
        # In Pydantic v2 'before' mode, data can be an ORM object or dictionary
        if isinstance(data, dict):
            views = data.get("views", 0)
            clicks = data.get("clicks", 0)
            data["ctr"] = round((clicks / views) * 100, 2) if views > 0 else 0.0
        else:
            # Handle SQLAlchemy ORM object
            views = getattr(data, "views", 0)
            clicks = getattr(data, "clicks", 0)
            setattr(data, "ctr", round((clicks / views) * 100, 2) if views > 0 else 0.0)
        return data

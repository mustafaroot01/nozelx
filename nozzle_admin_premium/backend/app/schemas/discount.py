from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class CouponBase(BaseModel):
    code: str = Field(..., min_length=1, max_length=50)
    discount_type: str = Field(default="percentage", description="percentage, fixed, buy_x_get_y")
    value: float = Field(default=0.0, ge=0.0)
    min_order_value: Optional[float] = Field(default=None, ge=0.0)
    max_discount_value: Optional[float] = Field(default=None, ge=0.0)
    usage_limit: Optional[int] = Field(default=None, ge=1)
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    user_id: Optional[int] = None
    product_ids: List[int] = Field(default_factory=list)
    category_ids: List[int] = Field(default_factory=list)
    buy_x: Optional[int] = Field(default=None, ge=1)
    get_y: Optional[int] = Field(default=None, ge=1)
    get_y_discount: float = Field(default=100.0, ge=0.0, le=100.0)
    is_active: bool = True

class CouponCreate(CouponBase):
    pass

class CouponUpdate(BaseModel):
    code: Optional[str] = Field(None, min_length=1, max_length=50)
    discount_type: Optional[str] = None
    value: Optional[float] = Field(None, ge=0.0)
    min_order_value: Optional[float] = None
    max_discount_value: Optional[float] = None
    usage_limit: Optional[int] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    user_id: Optional[int] = None
    product_ids: Optional[List[int]] = None
    category_ids: Optional[List[int]] = None
    buy_x: Optional[int] = None
    get_y: Optional[int] = None
    get_y_discount: Optional[float] = None
    is_active: Optional[bool] = None

class CouponResponse(CouponBase):
    id: int
    usage_count: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class CartItemSchema(BaseModel):
    product_id: int
    quantity: int = Field(..., gt=0)
    price: float = Field(..., ge=0.0)
    category_id: Optional[int] = None

class CouponValidationRequest(BaseModel):
    code: str
    user_id: Optional[int] = None
    order_value: float = Field(..., ge=0.0)
    items: List[CartItemSchema] = Field(default_factory=list)

class CouponValidationResponse(BaseModel):
    valid: bool
    discount_amount: float
    message: str
    coupon_id: Optional[int] = None

from pydantic import BaseModel, EmailStr, Field, model_validator, field_validator
from typing import List, Optional, Dict, Any
from datetime import datetime

# --- TOKEN SCHEMAS ---
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None


# --- USER SCHEMAS ---
class UserBase(BaseModel):
    email: Optional[str] = None
    phone: Optional[str] = None
    full_name: str
    role: str = "admin" # superadmin, admin, manager, customer
    is_active: bool = True
    avatar_url: Optional[str] = None

class UserCreate(UserBase):
    password: str = Field(..., min_length=6)

class UserUpdate(BaseModel):
    email: Optional[str] = None
    phone: Optional[str] = None
    full_name: Optional[str] = None
    role: Optional[str] = None
    is_active: Optional[bool] = None
    password: Optional[str] = None
    avatar_url: Optional[str] = None

class UserResponse(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# --- CATEGORY SCHEMAS ---
class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    parent_id: Optional[int] = None
    icon_url: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: int = 0
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: Optional[str] = None
    is_active: bool = True

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    parent_id: Optional[int] = None
    icon_url: Optional[str] = None
    image_url: Optional[str] = None
    sort_order: Optional[int] = None
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: Optional[str] = None
    is_active: Optional[bool] = None

class CategoryResponse(CategoryBase):
    id: int
    created_at: datetime
    product_count: int = 0
    subcategories: List['CategoryResponse'] = []

    class Config:
        from_attributes = True


# --- PRODUCT SCHEMAS ---
class ProductVariantSchema(BaseModel):
    sku: Optional[str] = None
    price: Optional[float] = None
    stock: int = 0
    options: Dict[str, str] = {}

class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    sale_price: Optional[float] = None
    tax_rate: float = 15.0
    stock_quantity: int = Field(default=0, ge=0)
    low_stock_threshold: int = 10
    reorder_point: int = 20
    max_stock: int = 100
    sku: Optional[str] = None
    category_id: int
    subcategory_id: Optional[int] = None
    image_url: Optional[str] = None
    images: List[str] = []
    variants: List[ProductVariantSchema] = []
    features: List[str] = []
    specifications: Dict[str, str] = {}
    tags: List[str] = []
    tag_ids: Optional[List[int]] = []
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: Optional[str] = None
    status: str = "active" # active, hidden, out_of_stock

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    sale_price: Optional[float] = None
    tax_rate: Optional[float] = None
    stock_quantity: Optional[int] = None
    low_stock_threshold: Optional[int] = None
    reorder_point: Optional[int] = None
    max_stock: Optional[int] = None
    sku: Optional[str] = None
    category_id: Optional[int] = None
    subcategory_id: Optional[int] = None
    image_url: Optional[str] = None
    images: Optional[List[str]] = None
    variants: Optional[List[ProductVariantSchema]] = None
    features: Optional[List[str]] = None
    specifications: Optional[Dict[str, str]] = None
    tags: Optional[List[str]] = None
    tag_ids: Optional[List[int]] = None
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None
    slug: Optional[str] = None
    status: Optional[str] = None

class ProductResponse(ProductBase):
    id: int
    created_at: datetime
    category: Optional[CategoryResponse] = None
    stock_status: str = "in_stock"
    is_available: bool = True
    is_low_stock: bool = False

    class Config:
        from_attributes = True


# --- BANNER SCHEMAS ---
class BannerBase(BaseModel):
    title: Optional[str] = ""
    subtitle: Optional[str] = None
    image_url: str
    mobile_image_url: Optional[str] = None
    link_type: str = "none" # product, category, external, none
    product_id: Optional[int] = None
    category_id: Optional[int] = None
    external_url: Optional[str] = None
    text_alignment: str = "center"
    text_color: str = "#ffffff"
    overlay_color: str = "#000000"
    overlay_opacity: float = 0.4
    button_text: Optional[str] = None
    sort_order: int = 0
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_active: bool = True

class BannerCreate(BannerBase):
    pass

class BannerUpdate(BaseModel):
    title: Optional[str] = None
    subtitle: Optional[str] = None
    image_url: Optional[str] = None
    mobile_image_url: Optional[str] = None
    link_type: Optional[str] = None
    product_id: Optional[int] = None
    category_id: Optional[int] = None
    external_url: Optional[str] = None
    text_alignment: Optional[str] = None
    text_color: Optional[str] = None
    overlay_color: Optional[str] = None
    overlay_opacity: Optional[float] = None
    button_text: Optional[str] = None
    sort_order: Optional[int] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_active: Optional[bool] = None

class BannerResponse(BannerBase):
    id: int
    views: int
    clicks: int
    ctr: float = 0.0
    created_at: datetime

    class Config:
        from_attributes = True

    @model_validator(mode="before")
    @classmethod
    def calculate_ctr(cls, data: Any) -> Any:
        if isinstance(data, dict):
            views = data.get("views", 0)
            clicks = data.get("clicks", 0)
            data["ctr"] = round((clicks / views) * 100, 2) if views > 0 else 0.0
        else:
            views = getattr(data, "views", 0)
            clicks = getattr(data, "clicks", 0)
            setattr(data, "ctr", round((clicks / views) * 100, 2) if views > 0 else 0.0)
        return data


# --- COUPON/DISCOUNT SCHEMAS ---
class CouponBase(BaseModel):
    code: str
    discount_type: str = "percentage" # percentage, fixed, buy_x_get_y
    value: float = 0.0
    min_order_value: Optional[float] = None
    max_discount_value: Optional[float] = None
    usage_limit: Optional[int] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    user_id: Optional[int] = None
    product_ids: List[int] = []
    category_ids: List[int] = []
    buy_x: Optional[int] = None
    get_y: Optional[int] = None
    get_y_discount: float = 100.0
    is_active: bool = True

class CouponCreate(CouponBase):
    pass

class CouponUpdate(BaseModel):
    code: Optional[str] = None
    discount_type: Optional[str] = None
    value: Optional[float] = None
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

    class Config:
        from_attributes = True

class CartItemSchema(BaseModel):
    product_id: int
    quantity: int
    price: float
    category_id: Optional[int] = None

class CouponValidationRequest(BaseModel):
    code: str
    user_id: Optional[int] = None
    order_value: float
    items: List[CartItemSchema] = []

class CouponValidationResponse(BaseModel):
    valid: bool
    discount_amount: float
    message: str
    coupon_id: Optional[int] = None


# --- ORDER ITEM SCHEMAS ---
class OrderItemBase(BaseModel):
    product_id: int
    quantity: int = Field(..., gt=0)
    price: float
    selected_size: Optional[str] = None
    selected_color: Optional[str] = None

class OrderItemCreate(OrderItemBase):
    pass

class OrderItemResponse(OrderItemBase):
    id: int
    product: Optional[ProductResponse] = None

    class Config:
        from_attributes = True


# --- ORDER SCHEMAS ---
class OrderBase(BaseModel):
    customer_name: str
    customer_email: Optional[str] = None
    customer_phone: Optional[str] = None
    total_amount: float
    status: str = "pending"
    address: Optional[str] = None
    notes: Optional[str] = None
    payment_method: Optional[str] = "cash"
    subtotal: Optional[float] = None
    delivery_fee: Optional[float] = 3000.0
    coupon_code: Optional[str] = None
    coupon_discount: Optional[float] = 0.0
    invoice_number: Optional[str] = None
    order_number: Optional[str] = None
    user_id: Optional[int] = None
    status_history: Optional[List[Dict[str, Any]]] = []

    @model_validator(mode="before")
    @classmethod
    def map_customer_address(cls, data: Any) -> Any:
        if isinstance(data, dict):
            if "customer_address" in data and ("address" not in data or not data["address"]):
                data["address"] = data["customer_address"]
        return data

class OrderCreate(OrderBase):
    items: List[OrderItemCreate]

class OrderUpdate(BaseModel):
    status: Optional[str] = None
    customer_name: Optional[str] = None
    customer_email: Optional[str] = None
    customer_phone: Optional[str] = None

class OrderResponse(OrderBase):
    id: int
    created_at: datetime
    items: List[OrderItemResponse]

    class Config:
        from_attributes = True


# --- AUDIT LOG SCHEMAS ---
class AuditLogResponse(BaseModel):
    id: int
    user_id: Optional[int] = None
    action: str
    details: Optional[str] = None
    timestamp: datetime
    user: Optional[UserResponse] = None

    class Config:
        from_attributes = True


# --- DASHBOARD STATS SCHEMAS ---
class MonthlyRevenue(BaseModel):
    month: str
    revenue: float

class CategoryShare(BaseModel):
    category: str
    value: int

class RecentOrder(BaseModel):
    id: int
    customer: str
    amount: float
    status: str
    date: str

class DashboardStats(BaseModel):
    total_revenue: float
    total_orders: int
    total_products: int
    total_users: int
    revenue_growth_percentage: float
    orders_growth_percentage: float
    monthly_revenue: List[MonthlyRevenue]
    category_share: List[CategoryShare]
    recent_orders: List[RecentOrder]


# --- NOTIFICATION SCHEMAS ---
class NotificationBase(BaseModel):
    title: str
    body: str
    image_url: Optional[str] = None
    target_type: str = "all" # all, product, category, external
    target_id: Optional[str] = None
    status: str = "sent" # sent, scheduled, failed
    scheduled_at: Optional[datetime] = None

class NotificationCreate(NotificationBase):
    pass

class NotificationResponse(NotificationBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


# --- SETTING SCHEMAS ---
class SystemSettingBase(BaseModel):
    key: str
    value: Any

class SystemSettingCreate(SystemSettingBase):
    pass

class SystemSettingResponse(SystemSettingBase):
    id: int
    updated_at: datetime

    class Config:
        from_attributes = True


# --- CART SCHEMAS ---
class CartItemBase(BaseModel):
    product_id: int
    quantity: int = Field(1, ge=1)
    options: Optional[Dict[str, Any]] = None

class CartItemCreate(CartItemBase):
    session_id: Optional[str] = None

class CartItemUpdate(BaseModel):
    quantity: int = Field(..., ge=1)
    options: Optional[Dict[str, Any]] = None

class CartItemResponse(CartItemBase):
    id: int
    session_id: Optional[str] = None
    user_id: Optional[int] = None
    created_at: datetime
    product: Optional[ProductResponse] = None

    class Config:
        from_attributes = True


# --- FAVORITES SCHEMAS ---
class FavoriteBase(BaseModel):
    product_id: int

class FavoriteCreate(FavoriteBase):
    phone_number: Optional[str] = None

class FavoriteResponse(FavoriteBase):
    id: int
    user_id: Optional[int] = None
    phone_number: Optional[str] = None
    created_at: datetime
    product: Optional[ProductResponse] = None

    class Config:
        from_attributes = True


# --- ADDRESS SCHEMAS ---
class AddressBase(BaseModel):
    title: str
    recipient_name: str
    recipient_phone: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    address_details: str
    is_default: bool = False

class AddressCreate(AddressBase):
    phone_number: Optional[str] = None

class AddressUpdate(BaseModel):
    title: Optional[str] = None
    recipient_name: Optional[str] = None
    recipient_phone: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    address_details: Optional[str] = None
    is_default: Optional[bool] = None

class AddressResponse(AddressBase):
    id: int
    user_id: Optional[int] = None
    phone_number: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# --- PRODUCT RATING SCHEMAS ---
class ProductRatingBase(BaseModel):
    product_id: int
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None
    image_url: Optional[str] = None

class ProductRatingCreate(ProductRatingBase):
    order_id: Optional[int] = None

class ProductRatingResponse(ProductRatingBase):
    id: int
    user_id: Optional[int] = None
    order_id: Optional[int] = None
    created_at: datetime
    user: Optional[UserResponse] = None

    class Config:
        from_attributes = True


# --- OTP AUTH SCHEMAS ---
class OTPRequest(BaseModel):
    phone: str
    country_code: Optional[str] = None

class OTPVerify(BaseModel):
    phone: str
    otp: str

class CompleteProfileRequest(BaseModel):
    name: str

class LoginRequest(BaseModel):
    phone: str

class UserStats(BaseModel):
    orders_count: int
    completed_orders: int
    cancelled_orders: int
    service_requests_count: int
    favorites_count: int
    coupons_used_count: int
    total_savings: float
    total_spent: float

class CouponHistoryItem(BaseModel):
    coupon_code: str
    discount_amount: float
    order_number: Optional[str] = None
    used_at: datetime

class AdminUserListItem(BaseModel):
    id: int
    name: Optional[str] = None
    full_name: str
    phone: Optional[str] = None
    total_orders: int
    total_spent: float
    created_at: datetime
    last_login_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class AdminUserDetail(BaseModel):
    id: int
    name: Optional[str] = None
    full_name: str
    phone: Optional[str] = None
    total_orders: int
    total_spent: float
    created_at: datetime
    last_login_at: Optional[datetime] = None
    stats: UserStats
    recent_orders: List[Dict[str, Any]] = []
    recent_service_requests: List[Dict[str, Any]] = []
    coupons_used: List[CouponHistoryItem] = []
    favorites_count: int

    class Config:
        from_attributes = True

class ProfileUpdateRequest(BaseModel):
    name: Optional[str] = None
    avatar_url: Optional[str] = None



# --- SERVICE SCHEMAS ---

class ServiceOptionBase(BaseModel):
    name: str
    description: Optional[str] = None
    extra_price: float = 0.0
    duration_extra_minutes: int = 0
    sort_order: int = 0
    is_active: bool = True

class ServiceOptionCreate(ServiceOptionBase):
    pass

class ServiceOptionResponse(ServiceOptionBase):
    id: int
    service_id: int

    class Config:
        from_attributes = True


class ServiceBase(BaseModel):
    name: str
    description: Optional[str] = None
    short_description: Optional[str] = None
    image_url: Optional[str] = None
    gallery_urls: List[str] = []
    icon_emoji: Optional[str] = None
    base_price: float = 0.0
    price_type: str = "fixed"
    category: Optional[str] = None
    tags: List[str] = []
    duration_minutes: int = 60
    is_available: bool = True
    is_featured: bool = False
    sort_order: int = 0
    rating: float = 0.0
    reviews_count: int = 0
    total_bookings: int = 0
    working_hours: Dict[str, Any] = {}
    max_bookings_per_day: int = 10
    advance_booking_days: int = 30

    @field_validator("working_hours", mode="before")
    @classmethod
    def validate_working_hours(cls, v):
        if not isinstance(v, dict):
            return {}
        return v

class ServiceCreate(ServiceBase):
    options: Optional[List[ServiceOptionCreate]] = []

class ServiceUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    short_description: Optional[str] = None
    image_url: Optional[str] = None
    gallery_urls: Optional[List[str]] = None
    icon_emoji: Optional[str] = None
    base_price: Optional[float] = None
    price_type: Optional[str] = None
    category: Optional[str] = None
    tags: Optional[List[str]] = None
    duration_minutes: Optional[int] = None
    is_available: Optional[bool] = None
    is_featured: Optional[bool] = None
    sort_order: Optional[int] = None
    working_hours: Optional[Dict[str, Any]] = None
    max_bookings_per_day: Optional[int] = None
    advance_booking_days: Optional[int] = None
    options: Optional[List[ServiceOptionCreate]] = []

    @field_validator("working_hours", mode="before")
    @classmethod
    def validate_working_hours(cls, v):
        if v is None:
            return None
        if not isinstance(v, dict):
            return {}
        return v

class ServiceResponse(ServiceBase):
    id: int
    created_at: datetime
    updated_at: datetime
    options: List[ServiceOptionResponse] = []

    class Config:
        from_attributes = True


# --- SERVICE REQUEST SCHEMAS ---

class ServiceRequestBase(BaseModel):
    service_id: int
    service_option_id: Optional[int] = None
    customer_name: str
    customer_phone: str
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    scheduled_date: str
    scheduled_time: str
    notes: Optional[str] = None
    total_price: float
    payment_method: str = "cash"
    user_id: Optional[int] = None

class ServiceRequestCreate(ServiceRequestBase):
    pass

class ServiceBookingCreate(BaseModel):
    service_id: int
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    customer_district: Optional[str] = None
    booking_date: str
    preferred_time: str
    notes: Optional[str] = None

class ServiceRequestStatusHistoryResponse(BaseModel):
    id: int
    service_request_id: int
    old_status: Optional[str] = None
    new_status: str
    changed_by: Optional[str] = None
    note: Optional[str] = None
    notify_customer: bool = False
    created_at: datetime

    class Config:
        from_attributes = True

class ServiceRequestResponse(ServiceRequestBase):
    id: int
    request_number: str
    status: str
    payment_status: str
    assigned_worker: Optional[str] = None
    worker_phone: Optional[str] = None
    admin_notes: Optional[str] = None
    cancelled_reason: Optional[str] = None
    cancelled_by: Optional[str] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    service: Optional[ServiceResponse] = None
    option: Optional[ServiceOptionResponse] = None
    status_history: List[ServiceRequestStatusHistoryResponse] = []

    class Config:
        from_attributes = True



# --- STOCK MOVEMENT SCHEMAS ---
class StockMovementBase(BaseModel):
    product_id: int
    type: str  # in, out, adjustment, audit
    quantity_change: int
    quantity_before: int
    quantity_after: int
    reason: Optional[str] = None
    invoice_number: Optional[str] = None

class StockMovementCreate(BaseModel):
    product_id: int
    type: str
    quantity_change: int
    reason: Optional[str] = None
    invoice_number: Optional[str] = None

class StockMovementResponse(StockMovementBase):
    id: int
    created_by: Optional[int] = None
    created_at: datetime
    product: Optional[ProductResponse] = None

    class Config:
        from_attributes = True


# --- PRODUCT TAG SCHEMAS ---
class ProductTagBase(BaseModel):
    name: str
    subcategory_id: int
    parent_id: Optional[int] = None
    image_url: Optional[str] = None
    icon_emoji: Optional[str] = None
    sort_order: int = 0
    is_active: bool = True

class ProductTagCreate(ProductTagBase):
    product_ids: Optional[List[int]] = []

class ProductTagUpdate(BaseModel):
    name: Optional[str] = None
    subcategory_id: Optional[int] = None
    parent_id: Optional[int] = None
    image_url: Optional[str] = None
    icon_emoji: Optional[str] = None
    sort_order: Optional[int] = None
    is_active: Optional[bool] = None
    product_ids: Optional[List[int]] = None

class ProductTagResponse(ProductTagBase):
    id: int
    products_count: int = 0
    product_ids: Optional[List[int]] = []
    sub_tags: Optional[List['ProductTagResponse']] = []

    class Config:
        from_attributes = True


# Rebuild dynamic configurations
CategoryResponse.model_rebuild()
ProductResponse.model_rebuild()
CartItemResponse.model_rebuild()
FavoriteResponse.model_rebuild()
ServiceRequestResponse.model_rebuild()
StockMovementResponse.model_rebuild()
ProductTagResponse.model_rebuild()




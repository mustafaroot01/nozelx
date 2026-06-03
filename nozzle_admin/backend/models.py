import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text, JSON, BigInteger, CheckConstraint, Index, Table, UniqueConstraint
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=True)
    phone = Column(String, unique=True, index=True, nullable=True)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    name = Column(String, nullable=True) # for customer profiles
    role = Column(String, default="admin") # superadmin, admin, manager, customer
    is_active = Column(Boolean, default=True)
    avatar_url = Column(String, nullable=True)
    total_orders = Column(Integer, default=0)
    total_spent = Column(Float, default=0.0)
    last_login_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    logs = relationship("AuditLog", back_populates="user")


class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=False, index=True, nullable=False)
    description = Column(String, nullable=True)
    parent_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=True)
    icon_url = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    sort_order = Column(Integer, default=0, nullable=False)
    seo_title = Column(String, nullable=True)
    seo_description = Column(Text, nullable=True)
    slug = Column(String, unique=True, index=True, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    parent = relationship("Category", remote_side=[id], back_populates="subcategories")
    subcategories = relationship("Category", back_populates="parent", cascade="all, delete-orphan")
    products = relationship("Product", foreign_keys="[Product.category_id]", back_populates="category", cascade="all, delete-orphan")


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    sale_price = Column(Float, nullable=True)
    tax_rate = Column(Float, default=15.0, nullable=False)
    stock_quantity = Column(Integer, nullable=False, default=0, server_default='0')
    low_stock_threshold = Column(Integer, default=10, nullable=False)
    reorder_point = Column(Integer, default=20, nullable=False)
    max_stock = Column(Integer, default=100, nullable=False)
    sku = Column(String, unique=True, index=True, nullable=True)
    
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=False)
    subcategory_id = Column(Integer, ForeignKey("categories.id", ondelete="SET NULL"), nullable=True)
    
    image_url = Column(String, nullable=True) # compatibility field
    images = Column(JSON, default=list, nullable=True)
    variants = Column(JSON, default=list, nullable=True)
    features = Column(JSON, default=list, nullable=True)
    specifications = Column(JSON, default=dict, nullable=True)
    tags = Column(JSON, default=list, nullable=True)
    
    seo_title = Column(String, nullable=True)
    seo_description = Column(Text, nullable=True)
    slug = Column(String, unique=True, index=True, nullable=True)
    
    status = Column(String, default="active", nullable=False)
    is_deleted = Column(Boolean, default=False, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    __table_args__ = (
        CheckConstraint('stock_quantity >= 0', name='stock_non_negative'),
        Index('idx_product_stock_active', 'stock_quantity', 'is_active'),
    )

    category = relationship("Category", foreign_keys=[category_id], back_populates="products")
    order_items = relationship("OrderItem", back_populates="product")


class Banner(Base):
    __tablename__ = "banners"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=True)
    subtitle = Column(String, nullable=True)
    image_url = Column(String, nullable=False)
    mobile_image_url = Column(String, nullable=True)
    link_type = Column(String, default="none", nullable=False) # product, category, external, none
    product_id = Column(Integer, nullable=True)
    category_id = Column(Integer, nullable=True)
    external_url = Column(String, nullable=True)
    text_alignment = Column(String, default="center", nullable=False) # top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right
    text_color = Column(String, default="#ffffff", nullable=False)
    overlay_color = Column(String, default="#000000", nullable=False)
    overlay_opacity = Column(Float, default=0.4, nullable=False)
    button_text = Column(String, nullable=True)
    sort_order = Column(Integer, default=0, nullable=False)
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    views = Column(BigInteger, default=0, nullable=False)
    clicks = Column(BigInteger, default=0, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)


class Coupon(Base):
    __tablename__ = "coupons"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String, unique=True, index=True, nullable=False)
    discount_type = Column(String, default="percentage", nullable=False) # percentage, fixed, buy_x_get_y
    value = Column(Float, default=0.0, nullable=False)
    min_order_value = Column(Float, nullable=True)
    max_discount_value = Column(Float, nullable=True)
    usage_limit = Column(Integer, nullable=True)
    usage_count = Column(Integer, default=0, nullable=False)
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    product_ids = Column(JSON, default=list, nullable=False)
    category_ids = Column(JSON, default=list, nullable=False)
    buy_x = Column(Integer, nullable=True)
    get_y = Column(Integer, nullable=True)
    get_y_discount = Column(Float, default=100.0, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String(20), unique=True, index=True, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    customer_name = Column(String, nullable=False)
    customer_email = Column(String, nullable=True)
    customer_phone = Column(String, nullable=True)
    total_amount = Column(Float, nullable=False)
    status = Column(String, default="pending") # pending, processing, completed, cancelled
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    address = Column(String, nullable=True)
    notes = Column(String, nullable=True)
    payment_method = Column(String, default="cash", nullable=True)
    subtotal = Column(Float, nullable=True)
    delivery_fee = Column(Float, default=3000.0, nullable=True)
    coupon_code = Column(String, nullable=True)
    coupon_discount = Column(Float, default=0.0, nullable=True)
    invoice_number = Column(String, nullable=True)
    status_history = Column(JSON, default=list, nullable=True)

    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    quantity = Column(Integer, nullable=False, default=1)
    price = Column(Float, nullable=False)
    
    selected_size = Column(String, nullable=True)
    selected_color = Column(String, nullable=True)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    action = Column(String, nullable=False)
    details = Column(String, nullable=True)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", back_populates="logs")


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=False)
    body = Column(String, nullable=False)
    image_url = Column(String, nullable=True)
    target_type = Column(String, default="all", nullable=False) # all, product, category, external
    target_id = Column(String, nullable=True)
    status = Column(String, default="sent", nullable=False) # sent, scheduled, failed
    scheduled_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class SystemSetting(Base):
    __tablename__ = "system_settings"

    id = Column(Integer, primary_key=True, index=True)
    key = Column(String, unique=True, index=True, nullable=False)
    value = Column(JSON, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)


class CartItem(Base):
    __tablename__ = "cart_items"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String, index=True, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    quantity = Column(Integer, default=1, nullable=False)
    options = Column(JSON, default=dict, nullable=True)
    selected_size = Column(String(50), nullable=True)
    selected_color = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    user = relationship("User")
    product = relationship("Product")

    __table_args__ = (
        UniqueConstraint('user_id', 'product_id', 'selected_size', 'selected_color', name='_user_product_size_color_uc'),
    )


class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    phone_number = Column(String, index=True, nullable=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User")
    product = relationship("Product")

    __table_args__ = (
        UniqueConstraint('user_id', 'product_id', name='_user_product_uc'),
    )


class Address(Base):
    __tablename__ = "addresses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    phone_number = Column(String, index=True, nullable=True)
    title = Column(String, nullable=False) # e.g. المنزل, العمل
    recipient_name = Column(String, nullable=False)
    recipient_phone = Column(String, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    address_details = Column(Text, nullable=False)
    is_default = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User")


class ProductRating(Base):
    __tablename__ = "product_ratings"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    order_id = Column(Integer, ForeignKey("orders.id", ondelete="SET NULL"), nullable=True)
    rating = Column(Integer, nullable=False) # 1 to 5
    comment = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User")
    product = relationship("Product")
    order = relationship("Order")


class Service(Base):
    __tablename__ = "services"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    short_description = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    gallery_urls = Column(JSON, default=list, nullable=True)
    icon_emoji = Column(String(10), nullable=True)
    base_price = Column(Float, nullable=False, default=0.0)
    price_type = Column(String(20), default="fixed", nullable=False)
    category = Column(String(100), nullable=True)
    tags = Column(JSON, default=list, nullable=True)
    duration_minutes = Column(Integer, default=60, nullable=False)
    is_available = Column(Boolean, default=True, nullable=False)
    is_featured = Column(Boolean, default=False, nullable=False)
    sort_order = Column(Integer, default=0, nullable=False)
    rating = Column(Float, default=0.00, nullable=False)
    reviews_count = Column(Integer, default=0, nullable=False)
    total_bookings = Column(Integer, default=0, nullable=False)
    working_hours = Column(JSON, default=dict, nullable=True)
    max_bookings_per_day = Column(Integer, default=10, nullable=False)
    advance_booking_days = Column(Integer, default=30, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    # Relationships
    options = relationship("ServiceOption", back_populates="service", cascade="all, delete-orphan")


class ServiceOption(Base):
    __tablename__ = "service_options"

    id = Column(Integer, primary_key=True, index=True)
    service_id = Column(Integer, ForeignKey("services.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(String(500), nullable=True)
    extra_price = Column(Float, default=0.0, nullable=False)
    duration_extra_minutes = Column(Integer, default=0, nullable=False)
    sort_order = Column(Integer, default=0, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    # Relationships
    service = relationship("Service", back_populates="options")


class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(Integer, primary_key=True, index=True)
    request_number = Column(String(20), unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    service_id = Column(Integer, ForeignKey("services.id"), nullable=False)
    service_option_id = Column(Integer, ForeignKey("service_options.id"), nullable=True)
    customer_name = Column(String(255), nullable=False)
    customer_phone = Column(String(20), nullable=False)
    address = Column(Text, nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    scheduled_date = Column(String(20), nullable=False)  # Stored as string YYYY-MM-DD
    scheduled_time = Column(String(20), nullable=False)  # Stored as string HH:MM
    notes = Column(Text, nullable=True)
    status = Column(String(30), default="new", nullable=False)
    total_price = Column(Float, nullable=False)
    payment_method = Column(String(20), default="cash", nullable=False)
    payment_status = Column(String(20), default="pending", nullable=False)
    assigned_worker = Column(String(255), nullable=True)
    worker_phone = Column(String(20), nullable=True)
    admin_notes = Column(Text, nullable=True)
    cancelled_reason = Column(Text, nullable=True)
    cancelled_by = Column(String(20), nullable=True)
    completed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    # Relationships
    service = relationship("Service")
    option = relationship("ServiceOption")
    status_history = relationship("ServiceRequestStatusHistory", back_populates="request", cascade="all, delete-orphan")


class ServiceRequestStatusHistory(Base):
    __tablename__ = "service_request_status_history"

    id = Column(Integer, primary_key=True, index=True)
    service_request_id = Column(Integer, ForeignKey("service_requests.id", ondelete="CASCADE"), nullable=False)
    old_status = Column(String(30), nullable=True)
    new_status = Column(String(30), nullable=False)
    changed_by = Column(String(255), nullable=True)
    note = Column(Text, nullable=True)
    notify_customer = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    request = relationship("ServiceRequest", back_populates="status_history")



class StockMovement(Base):
    __tablename__ = "stock_movements"

    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    type = Column(String, nullable=False)  # in, out, adjustment, audit
    quantity_change = Column(Integer, nullable=False)
    quantity_before = Column(Integer, nullable=False)
    quantity_after = Column(Integer, nullable=False)
    reason = Column(String, nullable=True)
    invoice_number = Column(String, nullable=True)
    created_by = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    product = relationship("Product")
    user = relationship("User")


# Pivot Table for Product <-> ProductTag
product_tag_items = Table(
    "product_tag_items",
    Base.metadata,
    Column("product_id", Integer, ForeignKey("products.id", ondelete="CASCADE"), primary_key=True),
    Column("tag_id", Integer, ForeignKey("product_tags.id", ondelete="CASCADE"), primary_key=True),
)

class ProductTag(Base):
    __tablename__ = "product_tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    subcategory_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=False)
    parent_id = Column(Integer, ForeignKey("product_tags.id", ondelete="CASCADE"), nullable=True)
    image_url = Column(String, nullable=True)
    icon_emoji = Column(String, nullable=True)
    sort_order = Column(Integer, default=0, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    # Relationships
    parent = relationship("ProductTag", remote_side=[id], back_populates="sub_tags")
    sub_tags = relationship("ProductTag", back_populates="parent", cascade="all, delete-orphan")
    products = relationship("Product", secondary=product_tag_items, backref="product_tags_list")


class UserToken(Base):
    __tablename__ = "user_tokens"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    token = Column(String(500), unique=True, index=True, nullable=False)
    device_info = Column(String(255), nullable=True)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User")


class OTPCode(Base):
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), index=True, nullable=False)
    code = Column(String(10), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_used = Column(Boolean, default=False)
    attempts = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class UserCouponUsage(Base):
    __tablename__ = "user_coupon_usage"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    coupon_id = Column(Integer, ForeignKey("coupons.id"), nullable=False)
    coupon_code = Column(String(50), nullable=False)
    order_id = Column(Integer, ForeignKey("orders.id", ondelete="SET NULL"), nullable=True)
    discount_amount = Column(Float, nullable=False)
    used_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User")
    coupon = relationship("Coupon")
    order = relationship("Order")





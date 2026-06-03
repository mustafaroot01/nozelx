import datetime
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Boolean, JSON
from app.core.database import Base

class Coupon(Base):
    __tablename__ = "coupons"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String, unique=True, index=True, nullable=False)
    
    # discount_type: percentage, fixed, buy_x_get_y
    discount_type = Column(String, default="percentage", nullable=False)
    value = Column(Float, default=0.0, nullable=False) # Value of discount (e.g. 10.0 for 10% or $10)
    
    # Restrictions
    min_order_value = Column(Float, nullable=True)
    max_discount_value = Column(Float, nullable=True) # Max cap for percentage discounts
    
    usage_limit = Column(Integer, nullable=True)
    usage_count = Column(Integer, default=0, nullable=False)
    
    # Schedule windows
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    
    # Target scope configurations
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    product_ids = Column(JSON, default=list, nullable=False) # Applicable product IDs (empty = all)
    category_ids = Column(JSON, default=list, nullable=False) # Applicable category IDs (empty = all)
    
    # "Buy X Get Y" parameters
    buy_x = Column(Integer, nullable=True) # e.g. Buy 3
    get_y = Column(Integer, nullable=True) # e.g. Get 1
    get_y_discount = Column(Float, default=100.0, nullable=False) # Discount rate on Y (100.0 = free Y)
    
    is_active = Column(Boolean, default=True, nullable=False)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow, nullable=False)

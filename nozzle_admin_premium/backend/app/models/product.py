import datetime
from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Text, JSON, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    sale_price = Column(Float, nullable=True)
    tax_rate = Column(Float, default=15.0, nullable=False) # 15% VAT default
    stock = Column(Integer, default=0, nullable=False)
    low_stock_threshold = Column(Integer, default=10, nullable=False)
    sku = Column(String, unique=True, index=True, nullable=True)
    
    # Category links
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="RESTRICT"), nullable=False)
    subcategory_id = Column(Integer, ForeignKey("categories.id", ondelete="SET NULL"), nullable=True)
    
    # JSON columns for flexibility
    images = Column(JSON, default=list, nullable=False)
    variants = Column(JSON, default=list, nullable=False)
    
    # SEO Meta fields
    seo_title = Column(String, nullable=True)
    seo_description = Column(Text, nullable=True)
    slug = Column(String, unique=True, index=True, nullable=False)
    
    # Status: active, hidden, out_of_stock
    status = Column(String, default="active", nullable=False)
    is_deleted = Column(Boolean, default=False, nullable=False)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow, nullable=False)

    # Relationships
    category = relationship("Category", foreign_keys=[category_id])
    subcategory = relationship("Category", foreign_keys=[subcategory_id])

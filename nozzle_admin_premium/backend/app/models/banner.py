import datetime
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean, BigInteger
from app.core.database import Base

class Banner(Base):
    __tablename__ = "banners"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=False)
    
    # Web and Mobile specific image assets
    image_url = Column(String, nullable=False, description="Web image banner url")
    mobile_image_url = Column(String, nullable=True, description="Mobile optimized image banner url")
    
    # Redirection Link configurations
    # link_type can be: product, category, external, none
    link_type = Column(String, default="none", nullable=False)
    product_id = Column(Integer, nullable=True)
    category_id = Column(Integer, nullable=True)
    external_url = Column(String, nullable=True)
    
    # Sequence index for drag-and-drop sort reordering
    sort_order = Column(Integer, default=0, nullable=False)
    
    # Scheduling windows
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    
    is_active = Column(Boolean, default=True, nullable=False)
    
    # Analytics parameters for Click-Through Rate (CTR) computations
    views = Column(BigInteger, default=0, nullable=False)
    clicks = Column(BigInteger, default=0, nullable=False)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow, nullable=False)

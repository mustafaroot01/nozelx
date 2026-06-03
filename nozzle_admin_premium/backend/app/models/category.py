import datetime
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean, Text
from sqlalchemy.orm import relationship
from app.core.database import Base

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    description = Column(Text, nullable=True)
    
    # Self-referencing relationship for Main/Subcategories
    parent_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=True)
    
    # Asset parameters
    icon_url = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    
    # Sort ordering sequence for drag-and-drop hierarchy listing
    sort_order = Column(Integer, default=0, nullable=False)
    
    # SEO parameters
    seo_title = Column(String, nullable=True)
    seo_description = Column(Text, nullable=True)
    slug = Column(String, unique=True, index=True, nullable=False)
    
    is_active = Column(Boolean, default=True, nullable=False)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow, nullable=False)

    # Relationships
    parent = relationship("Category", remote_side=[id], back_populates="subcategories")
    subcategories = relationship("Category", back_populates="parent", cascade="all, delete-orphan")

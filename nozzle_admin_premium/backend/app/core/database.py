from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# Engine configuration for PostgreSQL
# pool_pre_ping=True checks connection health before issuing queries to avoid stale connection errors
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_size=20,
    max_overflow=10
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    """
    Database session dependency generator.
    Yields a SessionLocal transaction, closing it automatically once the request lifecycle completes.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

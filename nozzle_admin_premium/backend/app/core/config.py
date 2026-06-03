import os
from typing import Optional, List
from pydantic import AnyHttpUrl
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Nozzle Premium E-commerce Admin Dashboard"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Security
    SECRET_KEY: str = "production_level_jwt_secret_key_should_be_highly_secure_and_random"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 11520 # 8 days
    
    # Database
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/nozzle_premium_db"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # Cloudinary
    CLOUDINARY_CLOUD_NAME: Optional[str] = None
    CLOUDINARY_API_KEY: Optional[str] = None
    CLOUDINARY_API_SECRET: Optional[str] = None
    
    # AWS S3 (Optional Fallback)
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_BUCKET_NAME: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    
    # Firebase FCM
    FIREBASE_CREDENTIALS_PATH: str = "app/core/firebase_credentials.json"
    
    # Server Config
    PORT: int = 8080
    HOST: str = "0.0.0.0"
    
    class Config:
        case_sensitive = True
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()

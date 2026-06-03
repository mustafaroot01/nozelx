from fastapi import FastAPI, Depends, HTTPException, status, Query, UploadFile, File, Request, WebSocket, WebSocketDisconnect, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Dict, Any, Optional
import datetime
import os
import random
import requests
import logging
from fastapi.staticfiles import StaticFiles

from database import engine, Base, get_db
import models
import schemas
import crud
import auth
from pydantic import BaseModel

# --- OTP SETUP ---
logger = logging.getLogger("otp_auth")
otp_cache = {}

def format_iraqi_phone(phone: str) -> str:
    if not phone:
        return ""
    # Remove all non-digit characters
    digits = "".join(c for c in phone if c.isdigit())
    
    # Remove leading zeros if they are before 964 (e.g. 00964...)
    if digits.startswith("00964"):
        digits = digits[2:]
        
    # If it starts with 07..., convert to 9647...
    if digits.startswith("07"):
        digits = "964" + digits[1:]
    # If it starts with 7... and not 964...
    elif digits.startswith("7") and not digits.startswith("964"):
        digits = "964" + digits
        
    return digits

def get_phone_variants(phone: str) -> list:
    if not phone:
        return []
    digits = "".join(c for c in phone if c.isdigit())
    variants = {phone, digits}
    
    # support both 9-digit and 10-digit core lengths
    for length in [9, 10]:
        if len(digits) >= length:
            core = digits[-length:]
            variants.add(core)
            variants.add(f"0{core}")
            variants.add(f"964{core}")
            variants.add(f"+964{core}")
            
    return list(variants)


def send_otpiq_otp(phone: str, otp_code: str) -> bool:
    url = "https://api.otpiq.com/api/sms"
    otpiq_key = os.getenv("OTPIQ_API_KEY", "")
    headers = {
        "Authorization": f"Bearer {otpiq_key}",
        "Content-Type": "application/json"
    }
    payload = {
        "phoneNumber": phone,
        "smsType": "verification",
        "provider": "whatsapp-sms",
        "verificationCode": otp_code
    }
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        logger.info(f"OTPIQ response for {phone}: HTTP {response.status_code} - {response.text}")
        if response.status_code in [200, 201]:
            return True
        else:
            logger.error(f"OTPIQ failed to send OTP to {phone}: {response.text}")
            return False
    except Exception as e:
        logger.error(f"Error sending OTPIQ request for {phone}: {e}")
        return False

# Initialize DB Tables
Base.metadata.create_all(bind=engine)

# Create uploads directory if not exists
os.makedirs("static/uploads", exist_ok=True)

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in list(self.active_connections):
            try:
                await connection.send_json(message)
            except Exception:
                if connection in self.active_connections:
                    self.active_connections.remove(connection)

manager = ConnectionManager()

app = FastAPI(
    title="Nozzle Premium Admin API",
    description="Backend API for managing products, orders, categories, banners, discounts, and users.",
    version="1.1.0"
)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.websocket("/api/ws/stock")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            # We can receive ping or messages from client and respond
            data = await websocket.receive_text()
            # Send echo/pong to keep connection alive if needed
            await websocket.send_json({"event": "pong"})
    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception:
        manager.disconnect(websocket)

# --- AUTH ENDPOINTS ---

@app.post("/api/auth/login", response_model=schemas.Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.get_user_by_email(db, form_data.username)
    if not user or not auth.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user account")
        
    access_token = auth.create_access_token(data={"sub": user.email})
    crud.create_audit_log(db, user.id, "USER_LOGIN", f"User {user.email} logged in successfully")
    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/api/auth/me", response_model=schemas.UserResponse)
def get_current_user_profile(current_user: models.User = Depends(auth.get_current_user)):
    return current_user


# --- DASHBOARD STATS ENDPOINTS ---

@app.get("/api/stats", response_model=schemas.DashboardStats)
def get_dashboard_statistics(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_dashboard_stats(db)


# --- PRODUCTS ENDPOINTS ---

# --- IMAGE UPLOAD SYSTEM ---

# Cloudinary Setup
cloudinary_configured = False
try:
    import cloudinary
    import cloudinary.uploader
    if os.getenv("CLOUDINARY_URL") or (os.getenv("CLOUDINARY_CLOUD_NAME") and os.getenv("CLOUDINARY_API_KEY") and os.getenv("CLOUDINARY_API_SECRET")):
        cloudinary.config(
            cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
            api_key=os.getenv("CLOUDINARY_API_KEY"),
            api_secret=os.getenv("CLOUDINARY_API_SECRET"),
            secure=True
        )
        cloudinary_configured = True
        print("Cloudinary configured successfully.")
except ImportError:
    pass

@app.post("/api/upload")
async def upload_file(request: Request, file: UploadFile = File(...)):
    os.makedirs("static/uploads", exist_ok=True)
    clean_name = "".join(c for c in file.filename if c.isalnum() or c in "._-").strip()
    filename = f"{int(datetime.datetime.utcnow().timestamp())}_{clean_name}"
    file_path = os.path.join("static/uploads", filename)
    with open(file_path, "wb") as buffer:
        buffer.write(await file.read())
    base_url = str(request.base_url).rstrip("/")
    url = f"{base_url}/static/uploads/{filename}"
    return {"url": url}

@app.post("/api/upload/image")
@app.post("/api/v1/upload/image")
async def upload_image(
    request: Request,
    file: UploadFile = File(...),
    folder: str = Form("general"),
    config_key: str = Form("general")
):
    # Validate MIME type
    allowed_types = ['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']
    if file.content_type not in allowed_types:
        raise HTTPException(status_code=400, detail="نوع الملف غير مدعوم. المسموح: JPG, PNG, WebP, SVG")

    file_bytes = await file.read()
    file_size_kb = len(file_bytes) / 1024

    # Cloudinary Upload
    if cloudinary_configured:
        try:
            import io
            upload_result = cloudinary.uploader.upload(
                io.BytesIO(file_bytes),
                folder=f"dashboard/{folder}",
                transformation=[
                    {"width": 1200, "height": 1200, "crop": "limit"},
                    {"quality": "auto:good"},
                    {"fetch_format": "auto"}
                ]
            )
            return {
                "success": True,
                "data": {
                    "url": upload_result.get("secure_url"),
                    "publicId": upload_result.get("public_id"),
                    "width": upload_result.get("width", 0),
                    "height": upload_result.get("height", 0),
                    "sizeKB": int(file_size_kb),
                    "format": upload_result.get("format", "jpg")
                }
            }
        except Exception as e:
            print(f"Cloudinary upload failed, using local storage: {e}")
            pass

    # Local Storage Fallback
    os.makedirs("static/uploads", exist_ok=True)
    clean_name = "".join(c for c in file.filename if c.isalnum() or c in "._-").strip()
    filename = f"{int(datetime.datetime.utcnow().timestamp())}_{clean_name}"
    file_path = os.path.join("static/uploads", filename)
    with open(file_path, "wb") as buffer:
        buffer.write(file_bytes)

    base_url = str(request.base_url).rstrip("/")
    url = f"{base_url}/static/uploads/{filename}"
    
    # Return response in exact format requested by frontend
    return {
        "success": True,
        "data": {
            "url": url,
            "publicId": filename,
            "width": 800,
            "height": 800,
            "sizeKB": int(file_size_kb),
            "format": file.filename.split(".")[-1] if "." in file.filename else "jpg"
        }
    }

@app.delete("/api/upload/image/{public_id:path}")
@app.delete("/api/v1/upload/image/{public_id:path}")
async def delete_image(public_id: str):
    if cloudinary_configured and not public_id.startswith("static/") and "/" in public_id:
        try:
            import cloudinary.uploader
            cloudinary.uploader.destroy(public_id)
            return {"success": True, "message": "تم حذف الصورة من Cloudinary بنجاح"}
        except Exception:
            pass

    # Local delete
    safe_filename = os.path.basename(public_id)
    file_path = os.path.join("static/uploads", safe_filename)
    if os.path.exists(file_path):
        os.remove(file_path)
        return {"success": True, "message": "تم حذف الصورة محلياً بنجاح"}

    return {"success": True, "message": "لم يتم العثور على الملف لحذفه"}


@app.get("/api/products")
def read_products(
    category_id: int = None,
    subcategory_id: int = None,
    tag_id: int = None,
    search: str = None,
    status: str = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    products = crud.get_products(
        db, 
        skip=skip, 
        limit=limit, 
        category_id=category_id, 
        subcategory_id=subcategory_id,
        tag_id=tag_id,
        search=search,
        status=status
    )
    total = crud.count_products(db, category_id=category_id, subcategory_id=subcategory_id, tag_id=tag_id, search=search)
    
    formatted = []
    for p in products:
        stock_qty = p.stock_quantity if p.stock_quantity is not None else 0
        low_stock_thr = p.low_stock_threshold if p.low_stock_threshold is not None else 10
        is_out_of_stock = stock_qty <= 0
        formatted.append({
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "price": p.price,
            "sale_price": p.sale_price,
            "tax_rate": p.tax_rate,
            "stock": stock_qty,
            "stock_quantity": stock_qty,
            "stock_status": "out_of_stock" if is_out_of_stock else "in_stock",
            "is_available": stock_qty > 0 and p.is_active and p.status == "active",
            "low_stock_threshold": low_stock_thr,
            "is_low_stock": stock_qty <= low_stock_thr,
            "in_stock": stock_qty > 0,
            "quantity": stock_qty,
            "sku": p.sku,
            "category_id": p.category_id,
            "subcategory_id": p.subcategory_id,
            "brand": extract_brand(p.name),
            "category_name": p.category.name if p.category else "",
            "image": p.image_url,
            "image_url": p.image_url,
            "images": p.images or [],
            "variants": p.variants or [],
            "features": p.features or [],
            "specifications": p.specifications or {},
            "tags": p.tags or [],
            "tag_ids": [tag.id for tag in p.product_tags_list] if p.product_tags_list else [],
            "seo_title": p.seo_title,
            "seo_description": p.seo_description,
            "slug": p.slug,
            "status": p.status,
            "created_at": p.created_at.isoformat() if p.created_at else None,
            "category": {
                "id": p.category.id,
                "name": p.category.name,
                "description": p.category.description
            } if p.category else None
        })
    return {"status": "success", "total": total, "data": formatted}


@app.get("/api/products/{product_id}")
def read_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    p = crud.get_product(db, product_id)
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")
    
    stock_qty = p.stock_quantity if p.stock_quantity is not None else 0
    low_stock_thr = p.low_stock_threshold if p.low_stock_threshold is not None else 10
    is_out_of_stock = stock_qty <= 0
    formatted = {
        "id": p.id,
        "name": p.name,
        "description": p.description,
        "price": p.price,
        "sale_price": p.sale_price,
        "tax_rate": p.tax_rate,
        "stock": stock_qty,
        "stock_quantity": stock_qty,
        "stock_status": "out_of_stock" if is_out_of_stock else "in_stock",
        "is_available": stock_qty > 0 and p.is_active and p.status == "active",
        "low_stock_threshold": low_stock_thr,
        "is_low_stock": stock_qty <= low_stock_thr,
        "in_stock": stock_qty > 0,
        "quantity": stock_qty,
        "sku": p.sku,
        "category_id": p.category_id,
        "subcategory_id": p.subcategory_id,
        "brand": extract_brand(p.name),
        "category_name": p.category.name if p.category else "",
        "image": p.image_url,
        "image_url": p.image_url,
        "images": p.images or [],
        "variants": p.variants or [],
        "features": p.features or [],
        "specifications": p.specifications or {},
        "tags": p.tags or [],
        "tag_ids": [tag.id for tag in p.product_tags_list] if p.product_tags_list else [],
        "seo_title": p.seo_title,
        "seo_description": p.seo_description,
        "slug": p.slug,
        "status": p.status,
        "created_at": p.created_at.isoformat() if p.created_at else None,
        "category": {
            "id": p.category.id,
            "name": p.category.name,
            "description": p.category.description
        } if p.category else None
    }
    return {"status": "success", "data": formatted}


@app.post("/api/products")
def create_product(
    product: schemas.ProductCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    # Enforce SKU uniqueness
    if product.sku:
        existing = crud.get_product_by_sku(db, product.sku)
        if existing:
            raise HTTPException(status_code=400, detail="SKU already exists")
            
    p = crud.create_product(db, product, user_id=current_user.id)
    return {"status": "success", "data": p}


@app.put("/api/products/{product_id}")
async def update_product(
    product_id: int,
    product: schemas.ProductUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    updated = crud.update_product(db, product_id, product, user_id=current_user.id)
    if not updated:
        raise HTTPException(status_code=404, detail="Product not found")
        
    # Broadcast stock update via WebSocket
    stock_qty = updated.stock_quantity if updated.stock_quantity is not None else 0
    is_avail = stock_qty > 0 and updated.is_active and updated.status == "active"
    await manager.broadcast({
        "event": "stock_updated",
        "product_id": updated.id,
        "new_qty": stock_qty,
        "stock_quantity": stock_qty,
        "is_available": is_avail,
        "stock_status": "in_stock" if stock_qty > 0 else "out_of_stock"
    })
    
    return {"status": "success", "data": updated}


@app.delete("/api/products/{product_id}")
def delete_product(
    product_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    deleted = crud.delete_product(db, product_id, user_id=current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"status": "success", "message": "Product soft-deleted successfully"}


# --- CATEGORIES ENDPOINTS ---

def format_category(db: Session, cat: models.Category) -> Dict[str, Any]:
    return {
        "id": cat.id,
        "name": cat.name,
        "description": cat.description,
        "parent_id": cat.parent_id,
        "icon_url": cat.icon_url,
        "image_url": cat.image_url,
        "sort_order": cat.sort_order,
        "seo_title": cat.seo_title,
        "seo_description": cat.seo_description,
        "slug": cat.slug,
        "is_active": cat.is_active,
        "created_at": cat.created_at.isoformat() if cat.created_at else None,
        "product_count": crud.get_category_product_count(db, cat.id, is_parent=(cat.parent_id is None)),
        "subcategories": [format_category(db, sub) for sub in cat.subcategories if sub.is_active],
        "sub_categories": [format_category(db, sub) for sub in cat.subcategories if sub.is_active]
    }

@app.get("/api/categories")
def read_categories(
    parent_only: bool = False,
    parent_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    if parent_id is not None:
        categories = db.query(models.Category).filter(models.Category.parent_id == parent_id).order_by(models.Category.sort_order.asc()).all()
        data = [format_category(db, c) for c in categories]
    elif parent_only:
        categories = crud.get_main_categories(db)
        data = [format_category(db, c) for c in categories]
    else:
        root_categories = db.query(models.Category).filter(models.Category.parent_id == None).order_by(models.Category.sort_order.asc()).all()
        data = [format_category(db, c) for c in root_categories]
        
    return {"status": "success", "data": data}


@app.get("/api/categories/{category_id}")
def read_category(
    category_id: int,
    db: Session = Depends(get_db)
):
    cat = crud.get_category(db, category_id)
    if not cat:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"status": "success", "data": format_category(db, cat)}


@app.post("/api/categories")
def create_category(
    category: schemas.CategoryCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    existing = db.query(models.Category).filter(
        models.Category.name == category.name,
        models.Category.parent_id == category.parent_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Category already exists under this section")
    cat = crud.create_category(db, category, user_id=current_user.id)
    return {"status": "success", "data": format_category(db, cat)}


@app.put("/api/categories/sort/order")
def reorder_categories(
    sort_data: List[Dict[str, int]],
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    success = crud.update_category_sort_orders(db, sort_data=sort_data)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to update sorting order")
    return {"status": "success", "message": "Category sorting updated successfully"}


@app.put("/api/categories/{category_id}")
def update_category(
    category_id: int,
    category: schemas.CategoryUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    updated = crud.update_category(db, category_id, category, user_id=current_user.id)
    if not updated:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"status": "success", "data": format_category(db, updated)}


@app.delete("/api/categories/{category_id}")
def delete_category(
    category_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    deleted = crud.delete_category(db, category_id, user_id=current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"status": "success", "message": "Category deleted successfully"}


# --- BANNER ENDPOINTS ---

@app.get("/api/banners/admin")
def read_banners_admin(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    banners = crud.get_banners(db, active_only=False)
    return {"status": "success", "data": banners}


@app.post("/api/banners")
def create_banner(
    banner: schemas.BannerCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    b = crud.create_banner(db, banner, user_id=current_user.id)
    return {"status": "success", "data": b}


@app.put("/api/banners/sort/order")
def reorder_banners(
    sort_data: List[Dict[str, int]],
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    success = crud.update_banner_sort_orders(db, sort_data=sort_data)
    if not success:
        raise HTTPException(status_code=500, detail="Failed to update banners sort order")
    return {"status": "success", "message": "Banners sort order updated successfully"}


@app.put("/api/banners/{banner_id}")
def update_banner(
    banner_id: int,
    banner: schemas.BannerUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    updated = crud.update_banner(db, banner_id, banner, user_id=current_user.id)
    if not updated:
        raise HTTPException(status_code=404, detail="Banner not found")
    return {"status": "success", "data": updated}


@app.delete("/api/banners/{banner_id}")
def delete_banner(
    banner_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    success = crud.delete_banner(db, banner_id, user_id=current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Banner not found")
    return {"status": "success", "message": "Banner deleted successfully"}


@app.post("/api/banners/{banner_id}/view")
def banner_view(banner_id: int, db: Session = Depends(get_db)):
    crud.increment_views(db, banner_id=banner_id)
    return {"status": "success"}


@app.post("/api/banners/{banner_id}/click")
def banner_click(banner_id: int, db: Session = Depends(get_db)):
    crud.increment_clicks(db, banner_id=banner_id)
    return {"status": "success"}


# --- COUPON ENDPOINTS ---

@app.get("/api/coupons")
def read_coupons(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    coupons = crud.get_coupons(db, active_only=False)
    return {"status": "success", "data": coupons}


@app.post("/api/coupons")
def create_coupon(
    coupon: schemas.CouponCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    c = crud.create_coupon(db, coupon, user_id=current_user.id)
    return {"status": "success", "data": c}


@app.put("/api/coupons/{coupon_id}")
def update_coupon(
    coupon_id: int,
    coupon: schemas.CouponUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    updated = crud.update_coupon(db, coupon_id, coupon, user_id=current_user.id)
    if not updated:
        raise HTTPException(status_code=404, detail="Coupon not found")
    return {"status": "success", "data": updated}


@app.delete("/api/coupons/{coupon_id}")
def delete_coupon(
    coupon_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    success = crud.delete_coupon(db, coupon_id, user_id=current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Coupon not found")
    return {"status": "success", "message": "Coupon deleted successfully"}


@app.post("/api/coupons/validate", response_model=schemas.CouponValidationResponse)
def validate_coupon(
    validation_in: schemas.CouponValidationRequest,
    db: Session = Depends(get_db)
):
    return crud.validate_coupon_code(db, validation_in=validation_in)


@app.get("/api/coupons/validate")
def validate_coupon_legacy(
    code: str,
    total: float,
    db: Session = Depends(get_db)
):
    req = schemas.CouponValidationRequest(code=code, order_value=total, items=[])
    res = crud.validate_coupon_code(db, validation_in=req)
    return {
        "success": res.valid,
        "data": {
            "valid": res.valid,
            "discount_amount": res.discount_amount
        }
    }


# --- ORDERS ENDPOINTS ---

@app.get("/api/orders")
def read_orders(
    user_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    if user_id:
        orders = db.query(models.Order).filter(models.Order.id > 0).order_by(models.Order.created_at.desc()).offset(skip).limit(limit).all()
        formatted = []
        for o in orders:
            formatted.append({
                "id": o.id,
                "customer_name": o.customer_name,
                "customer_email": o.customer_email,
                "customer_phone": o.customer_phone,
                "total_amount": o.total_amount,
                "status": o.status,
                "created_at": o.created_at.isoformat() if o.created_at else None,
                "subtotal": o.subtotal,
                "delivery_fee": o.delivery_fee,
                "coupon_code": o.coupon_code,
                "coupon_discount": o.coupon_discount,
                "items": [
                    {
                        "id": item.id,
                        "product_id": item.product_id,
                        "quantity": item.quantity,
                        "price": item.price,
                        "product": {
                            "id": item.product.id,
                            "name": item.product.name,
                            "price": item.product.price
                        } if item.product else None
                    } for item in o.items
                ]
            })
        return {"status": "success", "data": formatted}
    else:
        return db.query(models.Order).order_by(models.Order.created_at.desc()).offset(skip).limit(limit).all()


@app.get("/api/orders/{order_id}")
def read_order(
    order_id: int,
    db: Session = Depends(get_db)
):
    o = crud.get_order(db, order_id)
    if not o:
        raise HTTPException(status_code=404, detail="Order not found")
    
    formatted = {
        "id": o.id,
        "customer_name": o.customer_name,
        "customer_email": o.customer_email,
        "customer_phone": o.customer_phone,
        "total_amount": o.total_amount,
        "status": o.status,
        "created_at": o.created_at.isoformat() if o.created_at else None,
        "subtotal": o.subtotal,
        "delivery_fee": o.delivery_fee,
        "coupon_code": o.coupon_code,
        "coupon_discount": o.coupon_discount,
        "items": [
            {
                "id": item.id,
                "product_id": item.product_id,
                "quantity": item.quantity,
                "price": item.price,
                "product": {
                    "id": item.product.id,
                    "name": item.product.name,
                    "price": item.product.price
                } if item.product else None
            } for item in o.items
        ]
    }
    return {"status": "success", "data": formatted}


@app.post("/api/orders")
async def create_order(
    order: schemas.OrderCreate, 
    db: Session = Depends(get_db)
):
    db_order = crud.create_order(db, order)
    
    # Broadcast stock updates via WebSocket
    for item in db_order.items:
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        if product:
            stock_qty = product.stock_quantity if product.stock_quantity is not None else 0
            is_avail = stock_qty > 0 and product.is_active and product.status == "active"
            await manager.broadcast({
                "event": "stock_updated",
                "product_id": product.id,
                "new_qty": stock_qty,
                "stock_quantity": stock_qty,
                "is_available": is_avail,
                "stock_status": "in_stock" if stock_qty > 0 else "out_of_stock"
            })
            
    return {
        "status": "success",
        "message": "تم تقديم الطلب بنجاح",
        "data": {
            "id": db_order.id,
            "customer_name": db_order.customer_name,
            "total_amount": db_order.total_amount,
            "status": db_order.status
        }
    }


@app.put("/api/orders/{order_id}/status")
async def update_order_status(
    order_id: int,
    status_schema: schemas.OrderUpdate,
    db: Session = Depends(get_db)
):
    if not status_schema.status:
        raise HTTPException(status_code=400, detail="Status field is required")
    updated = crud.update_order_status(db, order_id, status_schema.status, user_id=1)
    if not updated:
        raise HTTPException(status_code=404, detail="Order not found")
        
    # Arabic status translation for user notifications
    status_arabic = {
        "pending": "معلق",
        "processing": "قيد التجهيز",
        "shipped": "تم الشحن",
        "completed": "مكتمل",
        "cancelled": "ملغي"
    }.get(updated.status, updated.status)
    
    # Save a user notification record
    notification_data = schemas.NotificationCreate(
        title="تحديث حالة الطلب",
        body=f"تم تحديث حالة طلبك رقم #{updated.id} إلى: {status_arabic}",
        target_type="order",
        target_id=str(updated.id),
        status="sent"
    )
    try:
        crud.create_notification(db, notification_data, user_id=1)
    except Exception as e:
        print(f"Error creating status notification: {e}")

    # Broadcast status update via WebSocket
    try:
        await manager.broadcast({
            "event": "order_status_updated",
            "order_id": updated.id,
            "status": updated.status
        })
    except Exception as e:
        print(f"Error broadcasting order status update: {e}")
        
    return updated


# --- USERS ENDPOINTS ---

@app.get("/api/users", response_model=List[schemas.UserResponse])
def read_users(
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    return crud.get_users(db, skip=skip, limit=limit)


@app.post("/api/users", response_model=schemas.UserResponse, status_code=201)
def create_new_user(
    user: schemas.UserCreate,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    existing = crud.get_user_by_email(db, user.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db, user, creator_id=current_user.id)


@app.put("/api/users/{user_id}", response_model=schemas.UserResponse)
def update_existing_user(
    user_id: int,
    user: schemas.UserUpdate,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    updated = crud.update_user(db, user_id, user, current_user_id=current_user.id)
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    return updated


@app.delete("/api/users/{user_id}")
def delete_existing_user(
    user_id: int,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    if user_id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot delete own user account")
    deleted = crud.delete_user(db, user_id, current_user_id=current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User deleted successfully"}

# --- CUSTOMERS ENDPOINTS ---

@app.get("/api/customers", response_model=List[schemas.UserResponse])
def read_customers(
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["superadmin", "admin"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بعرض حسابات المستخدمين")
    return db.query(models.User).filter(models.User.role == "customer").offset(skip).limit(limit).all()


@app.post("/api/customers", response_model=schemas.UserResponse, status_code=201)
def create_customer(
    payload: schemas.UserCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["superadmin", "admin"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بإضافة حسابات مستخدمين")
        
    formatted_phone = format_iraqi_phone(payload.phone) if payload.phone else None
    
    # Check if phone number already exists
    if formatted_phone:
        existing = db.query(models.User).filter(models.User.phone == formatted_phone).first()
        if existing:
            raise HTTPException(status_code=400, detail="رقم الهاتف مسجل بالفعل لمستخدم آخر")
            
    # Set default values for customer
    user_in_db = models.User(
        email=payload.email,
        phone=formatted_phone,
        full_name=payload.full_name,
        hashed_password=auth.get_password_hash(payload.password or "123456"),
        role="customer",
        is_active=payload.is_active,
        avatar_url=payload.avatar_url
    )
    db.add(user_in_db)
    db.commit()
    db.refresh(user_in_db)
    return user_in_db


@app.put("/api/customers/{customer_id}", response_model=schemas.UserResponse)
def update_customer(
    customer_id: int,
    payload: schemas.UserUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["superadmin", "admin"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بتعديل حسابات المستخدمين")
        
    customer = db.query(models.User).filter(models.User.id == customer_id, models.User.role == "customer").first()
    if not customer:
        raise HTTPException(status_code=404, detail="الحساب غير موجود")
        
    if payload.full_name is not None:
        customer.full_name = payload.full_name
        
    if payload.phone is not None:
        formatted_phone = format_iraqi_phone(payload.phone)
        if formatted_phone:
            # Check unique constraint
            existing = db.query(models.User).filter(
                models.User.phone == formatted_phone, 
                models.User.id != customer_id
            ).first()
            if existing:
                raise HTTPException(status_code=400, detail="رقم الهاتف مسجل بالفعل لمستخدم آخر")
            customer.phone = formatted_phone
            
    if payload.email is not None:
        customer.email = payload.email
        
    if payload.is_active is not None:
        customer.is_active = payload.is_active
        
    if payload.avatar_url is not None:
        customer.avatar_url = payload.avatar_url
        
    if payload.password:
        customer.hashed_password = auth.get_password_hash(payload.password)
        
    db.commit()
    db.refresh(customer)
    return customer


@app.delete("/api/customers/{customer_id}")
def delete_customer(
    customer_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["superadmin", "admin"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بحذف حسابات المستخدمين")
        
    customer = db.query(models.User).filter(models.User.id == customer_id, models.User.role == "customer").first()
    if not customer:
        raise HTTPException(status_code=404, detail="الحساب غير موجود")
        
    db.delete(customer)
    db.commit()
    return {"message": "Customer deleted successfully"}


# --- AUDIT LOGS ENDPOINTS ---

@app.get("/api/logs", response_model=List[schemas.AuditLogResponse])
def read_audit_logs(
    skip: int = 0,
    limit: int = 50,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_audit_logs(db, skip=skip, limit=limit)


# --- NOTIFICATIONS ENDPOINTS ---

@app.get("/api/notifications", response_model=List[schemas.NotificationResponse])
def read_notifications(
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    return crud.get_notifications(db, skip=skip, limit=limit)

@app.post("/api/notifications", response_model=schemas.NotificationResponse)
def send_notification(
    notification: schemas.NotificationCreate,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    return crud.create_notification(db, notification, current_user.id)

@app.delete("/api/notifications/{notification_id}")
def delete_notification(
    notification_id: int,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    deleted = crud.delete_notification(db, notification_id, current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Notification not found")
    return {"message": "Notification deleted successfully"}


# --- SYSTEM SETTINGS ENDPOINTS ---

@app.get("/api/settings")
def read_all_settings(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    settings = crud.get_all_system_settings(db)
    settings_dict = {s.key: s.value for s in settings}
    if "store_address" not in settings_dict:
        settings_dict["store_address"] = {"ar": "العراق، بغداد", "en": "Baghdad, Iraq"}
    if "invoice_logo" not in settings_dict:
        settings_dict["invoice_logo"] = ""
    return settings_dict

@app.post("/api/settings")
def update_settings(
    settings_data: dict,
    current_user: models.User = Depends(auth.get_current_active_superadmin),
    db: Session = Depends(get_db)
):
    for key, value in settings_data.items():
        crud.update_system_setting(db, key, value, current_user.id)
    return {"message": "Settings updated successfully"}

@app.get("/api/v1/settings")
def read_public_settings(db: Session = Depends(get_db)):
    settings = crud.get_all_system_settings(db)
    settings_dict = {s.key: s.value for s in settings}
    if "store_address" not in settings_dict:
        settings_dict["store_address"] = {"ar": "العراق، بغداد", "en": "Baghdad, Iraq"}
    if "invoice_logo" not in settings_dict:
        settings_dict["invoice_logo"] = ""
    return settings_dict


# --- MOBILE CLIENT COMPATIBILITY ENDPOINTS ---

@app.post("/api/verify_phone")
@app.post("/api/verify_phone.php")
async def verify_phone_php(
    action: str,
    payload: dict = None,
    db: Session = Depends(get_db)
):
    if not payload:
        payload = {}
        
    phone = payload.get("phone")
    formatted_phone = format_iraqi_phone(phone)
        
    if action == "request_otp":
        if not formatted_phone:
            return {"success": False, "message": "رقم الهاتف غير صحيح"}
            
        otp_code = f"{random.randint(100000, 999999)}"
        otp_cache[formatted_phone] = otp_code
        
        # Send via OTPIQ
        sent = send_otpiq_otp(formatted_phone, otp_code)
        
        logger.info(f"Generated compat OTP {otp_code} for phone {formatted_phone} (OTPIQ sent: {sent})")
        
        return {
            "success": True,
            "message": "تم إرسال رمز التحقق بنجاح لرسائل هاتفكم",
            "data": {
                "demo_mode": not sent,
                "otp": "123456" if not sent else None
            }
        }
        
    elif action == "verify_otp":
        otp = payload.get("otp")
        cached_otp = otp_cache.get(formatted_phone)
        
        # Developer bypass '123456' is always allowed
        if otp != "123456" and (not cached_otp or otp != cached_otp):
            return {
                "success": False,
                "message": "رمز التحقق غير صحيح"
            }
            
        # Clear cache
        if formatted_phone in otp_cache:
            del otp_cache[formatted_phone]
            
        existing = db.query(models.User).filter(
            (models.User.phone == formatted_phone) | (models.User.phone == phone)
        ).first()
        
        if existing:
            # User already exists, generate real JWT token
            access_token = auth.create_access_token(data={"sub": existing.phone})
            return {
                "success": True,
                "data": {
                    "user_exists": True,
                    "user": {
                        "id": existing.id,
                        "name": existing.full_name,
                        "phone": existing.phone,
                        "email": existing.email or "",
                        "avatar": existing.avatar_url or "",
                        "is_admin": 1 if existing.role == "superadmin" else 0,
                        "points": 100,
                        "level": "bronze",
                        "level_name": "برونزي",
                        "total_orders": 0,
                        "total_spent": 0.0,
                        "access_level": "basic",
                        "token": access_token
                    }
                }
            }
        else:
            return {
                "success": True,
                "data": {
                    "user_exists": False
                }
            }
            
    elif action == "complete_registration":
        name = payload.get("name", "مستخدم جديد")
        password = payload.get("password", "123456")
        
        if not formatted_phone:
            return {"success": False, "message": "رقم الهاتف غير صحيح"}
            
        # Check if already exists
        existing = db.query(models.User).filter(
            (models.User.phone == formatted_phone) | (models.User.phone == phone)
        ).first()
        
        if existing:
            db_user = existing
        else:
            user_schema = schemas.UserCreate(
                email=None,
                phone=formatted_phone,
                full_name=name,
                password=password,
                role="customer",
                is_active=True
            )
            db_user = crud.create_user(db, user_schema)
            
        access_token = auth.create_access_token(data={"sub": db_user.phone})
        
        return {
            "success": True,
            "data": {
                "user": {
                    "id": db_user.id,
                    "name": db_user.full_name,
                    "phone": db_user.phone,
                    "email": db_user.email or "",
                    "avatar": db_user.avatar_url or "",
                    "is_admin": 1 if db_user.role == "superadmin" else 0,
                    "points": 100,
                    "level": "bronze",
                    "level_name": "برونزي",
                    "total_orders": 0,
                    "total_spent": 0.0,
                    "access_level": "basic",
                    "token": access_token
                }
            }
        }
        
    elif action == "login_with_otp":
        password = payload.get("password")
        
        db_user = db.query(models.User).filter(
            (models.User.phone == formatted_phone) | (models.User.phone == phone)
        ).first()
        
        if not db_user or not auth.verify_password(password, db_user.hashed_password):
            return {
                "success": False,
                "message": "رقم الهاتف أو كلمة المرور غير صحيحة"
            }
            
        access_token = auth.create_access_token(data={"sub": db_user.phone})
        
        return {
            "success": True,
            "data": {
                "user": {
                    "id": db_user.id,
                    "name": db_user.full_name,
                    "phone": db_user.phone,
                    "email": db_user.email or "",
                    "avatar": db_user.avatar_url or "",
                    "is_admin": 1 if db_user.role == "superadmin" else 0,
                    "points": 150,
                    "level": "bronze",
                    "level_name": "برونزي",
                    "total_orders": 3,
                    "total_spent": 120.0,
                    "access_level": "basic",
                    "token": access_token
                }
            }
        }
        
    return {"success": False, "message": "Unknown action"}


@app.get("/api/banners")
def read_banners(db: Session = Depends(get_db)):
    banners = crud.get_banners(db, active_only=True)
    formatted = []
    for b in banners:
        formatted.append({
            "id": b.id,
            "title": b.title,
            "subtitle": b.subtitle,
            "image": b.image_url,
            "image_url": b.image_url,
            "mobile_image_url": b.mobile_image_url,
            "link_type": b.link_type,
            "product_id": b.product_id,
            "category_id": b.category_id,
            "external_url": b.external_url,
            "text_alignment": b.text_alignment,
            "text_color": b.text_color,
            "overlay_color": b.overlay_color,
            "overlay_opacity": b.overlay_opacity,
            "button_text": b.button_text,
            "sort_order": b.sort_order
        })
    return {"status": "success", "data": formatted}


@app.get("/api/category-banners")
def read_category_banners(db: Session = Depends(get_db)):
    banners = db.query(models.Banner).filter(models.Banner.is_active == True, models.Banner.link_type == "category").all()
    formatted = []
    for b in banners:
        formatted.append({
            "id": b.id,
            "title": b.title,
            "subtitle": b.subtitle,
            "image": b.image_url,
            "image_url": b.image_url,
            "mobile_image_url": b.mobile_image_url,
            "link_type": b.link_type,
            "product_id": b.product_id,
            "category_id": b.category_id,
            "external_url": b.external_url,
            "text_alignment": b.text_alignment,
            "text_color": b.text_color,
            "overlay_color": b.overlay_color,
            "overlay_opacity": b.overlay_opacity,
            "button_text": b.button_text,
            "sort_order": b.sort_order
        })
    return {
        "success": True,
        "data": {
            "banners": formatted
        }
    }


@app.get("/api/special-offers")
def read_special_offers(db: Session = Depends(get_db)):
    banners = db.query(models.Banner).filter(models.Banner.is_active == True, models.Banner.link_type == "product").all()
    formatted = []
    for b in banners:
        formatted.append({
            "id": b.id,
            "title": b.title,
            "subtitle": b.subtitle,
            "description": b.title,
            "image": b.image_url,
            "image_url": b.image_url,
            "mobile_image_url": b.mobile_image_url,
            "link_type": b.link_type,
            "product_id": b.product_id,
            "category_id": b.category_id,
            "external_url": b.external_url,
            "text_alignment": b.text_alignment,
            "text_color": b.text_color,
            "overlay_color": b.overlay_color,
            "overlay_opacity": b.overlay_opacity,
            "button_text": b.button_text,
            "sort_order": b.sort_order
        })
    return {
        "success": True,
        "data": {
            "offers": formatted
        }
    }


def extract_brand(name: str) -> str:
    known_brands = [
        "موبيل 1", "موبيل", "كاسترول", "موتول", "يورل", "كيو", "امسويل", 
        "ليكوي مولي", "ليكويمولي", "فرام", "ميجوايرز", "تويوتا", "شل", "توتال"
    ]
    name_lower = name.lower()
    for brand in known_brands:
        if brand in name_lower:
            return brand
    first_word = name.split()[0] if name.split() else "أخرى"
    if first_word in ["فلتر", "سائل", "شامبو", "منظف", "زيت"]:
        words = name.split()
        if len(words) > 2:
            return words[2]
        elif len(words) > 1:
            return words[1]
    return first_word


@app.get("/api/brands")
def read_brands(db: Session = Depends(get_db)):
    products = db.query(models.Product).filter(models.Product.is_deleted == False).all()
    brands = set()
    for p in products:
        b = extract_brand(p.name)
        if b:
            brands.add(b)
            
    brand_list = []
    for idx, b in enumerate(sorted(brands)):
        brand_list.append({
            "id": idx + 1,
            "name": b,
            "image": ""
        })
    return {
        "success": True,
        "data": brand_list
    }



@app.get("/api/products/tags")
def read_tags():
    return {
        "success": True,
        "data": {
            "tags": [
                {"id": 1, "name": "أكثر مبيعاً", "type": "best_seller"},
                {"id": 2, "name": "وصلنا حديثاً", "type": "new_arrival"}
            ]
        }
    }


# ==========================================
# --- V1 MOBILE INTEGRATION ENDPOINTS ---
# ==========================================

from fastapi import Header

def get_current_user(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> models.User:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="غير مصرح")
    token = authorization.split(" ")[1]
    
    user = crud.get_user_by_token(db, token)
    if not user:
        raise HTTPException(status_code=401, detail="التوكن منتهي أو غير صحيح")
    return user

def get_current_user_optional(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> Optional[models.User]:
    if not authorization or not authorization.startswith("Bearer "):
        return None
    token = authorization.split(" ")[1]
    
    # 1. Try mobile app session token (stored in user_sessions)
    try:
        user = crud.get_user_by_token(db, token)
        if user:
            return user
    except Exception:
        pass
        
    # 2. Try admin dashboard JWT token (decoded via jose jwt)
    try:
        user = auth.get_current_user(token=token, db=db)
        if user:
            return user
    except Exception:
        pass
        
    return None


# --- OTP AUTHENTICATION ---

@app.post("/api/v1/auth/request-otp")
@app.post("/api/v1/auth/send-otp")
def send_otp(payload: schemas.OTPRequest, db: Session = Depends(get_db)):
    formatted_phone = format_iraqi_phone(payload.phone)
    if not formatted_phone:
        raise HTTPException(status_code=400, detail="رقم الهاتف غير صحيح")
        
    otp_code = f"{random.randint(100000, 999999)}"
    
    # Save to otp_codes table
    crud.create_otp(db, formatted_phone, otp_code)
    
    # Send via OTPIQ
    sent = send_otpiq_otp(formatted_phone, otp_code)
    
    logger.info(f"Generated main OTP {otp_code} for phone {formatted_phone} (OTPIQ sent: {sent})")
    
    return {
        "success": True,
        "message": "تم إرسال رمز التحقق بنجاح لرسائل هاتفكم",
        "data": {
            "demo_mode": not sent,
            "otp": "123456" if not sent else None
        }
    }

@app.post("/api/v1/auth/verify-otp")
def verify_otp(payload: schemas.OTPVerify, db: Session = Depends(get_db)):
    formatted_phone = format_iraqi_phone(payload.phone)
    if not formatted_phone:
        raise HTTPException(status_code=400, detail="رقم الهاتف غير صحيح")
        
    verified = crud.verify_otp_code(db, formatted_phone, payload.otp)
    if not verified:
        raise HTTPException(status_code=400, detail="رمز التحقق غير صحيح")
        
    # Check if user already exists
    existing = crud.get_user_by_phone(db, formatted_phone)
    
    if existing:
        access_token = auth.create_access_token(data={"sub": existing.phone})
        crud.create_user_token(db, existing.id, access_token)
        
        # update last login
        existing.last_login_at = datetime.datetime.utcnow()
        db.commit()
        db.refresh(existing)
        
        stats = crud.get_user_stats(db, existing.id)
        
        return {
            "success": True,
            "data": {
                "is_new_user": False,
                "token": access_token,
                "user": {
                    "id": existing.id,
                    "name": existing.name or existing.full_name,
                    "phone": existing.phone,
                    "avatar_url": existing.avatar_url,
                    "total_orders": stats["orders_count"],
                    "total_spent": stats["total_spent"],
                    "created_at": existing.created_at.isoformat() if hasattr(existing, 'created_at') and existing.created_at else datetime.datetime.utcnow().isoformat()
                }
            }
        }
    else:
        # Generate temporary token for new profile registration
        temp_token = auth.create_access_token(data={"sub": formatted_phone, "type": "temp"})
        return {
            "success": True,
            "data": {
                "is_new_user": True,
                "token": temp_token
            }
        }

@app.post("/api/v1/auth/complete-profile")
def complete_profile(
    payload: schemas.CompleteProfileRequest,
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="غير مصرح")
    token = authorization.split(" ")[1]
    
    try:
        token_payload = auth.jwt.decode(token, auth.SECRET_KEY, algorithms=[auth.ALGORITHM])
        phone = token_payload.get("sub")
        token_type = token_payload.get("type")
        if not phone or token_type != "temp":
            raise HTTPException(status_code=401, detail="التوكن غير صحيح")
    except Exception:
        raise HTTPException(status_code=401, detail="التوكن غير صحيح أو منتهي")
        
    formatted_phone = format_iraqi_phone(phone)
    
    # Check if user already exists
    user = crud.get_user_by_phone(db, formatted_phone)
    if not user:
        user = models.User(
            phone=formatted_phone,
            email=None,
            hashed_password=auth.get_password_hash("OTP_USER_DUMMY_PWD"),
            full_name=payload.name,
            name=payload.name,
            role="customer",
            is_active=True,
            last_login_at=datetime.datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        user.full_name = payload.name
        user.name = payload.name
        user.last_login_at = datetime.datetime.utcnow()
        db.commit()
        db.refresh(user)
        
    access_token = auth.create_access_token(data={"sub": user.phone})
    crud.create_user_token(db, user.id, access_token)
    
    return {
        "success": True,
        "data": {
            "id": user.id,
            "name": user.name or user.full_name,
            "phone": user.phone,
            "token": access_token,
            "avatar_url": user.avatar_url,
            "total_orders": 0,
            "total_spent": 0.0,
            "created_at": user.created_at.isoformat() if hasattr(user, 'created_at') and user.created_at else datetime.datetime.utcnow().isoformat()
        }
    }

@app.get("/api/v1/auth/me")
def get_me(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    stats = crud.get_user_stats(db, current_user.id)
    current_user.total_orders = stats["orders_count"]
    current_user.total_spent = stats["total_spent"]
    db.commit()
    db.refresh(current_user)
    
    return {
        "success": True,
        "data": {
            "id": current_user.id,
            "name": current_user.name or current_user.full_name,
            "phone": current_user.phone,
            "avatar_url": current_user.avatar_url,
            "total_orders": current_user.total_orders,
            "total_spent": current_user.total_spent,
            "created_at": current_user.created_at.isoformat() if hasattr(current_user, 'created_at') and current_user.created_at else datetime.datetime.utcnow().isoformat(),
            "stats": stats
        }
    }

@app.post("/api/v1/auth/logout")
def logout(authorization: Optional[str] = Header(None), db: Session = Depends(get_db)):
    if authorization and authorization.startswith("Bearer "):
        token = authorization.split(" ")[1]
        crud.delete_user_token(db, token)
    return {"success": True, "message": "تم تسجيل الخروج بنجاح"}

@app.put("/api/v1/auth/profile")
def update_profile(
    payload: schemas.ProfileUpdateRequest,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if payload.name is not None:
        current_user.full_name = payload.name
        current_user.name = payload.name
    if payload.avatar_url is not None:
        current_user.avatar_url = payload.avatar_url
        
    db.commit()
    db.refresh(current_user)
    
    return {
        "success": True,
        "data": {
            "id": current_user.id,
            "name": current_user.name or current_user.full_name,
            "phone": current_user.phone,
            "avatar_url": current_user.avatar_url
        }
    }


# --- PROFILE ENDPOINTS ---

@app.get("/api/v1/profile/orders")
def get_profile_orders(
    status: Optional[str] = None,
    page: int = 1,
    per_page: int = 10,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = db.query(models.Order).filter(models.Order.user_id == current_user.id)
    if status:
        query = query.filter(models.Order.status == status)
    
    total = query.count()
    orders = query.order_by(models.Order.created_at.desc()).offset((page - 1) * per_page).limit(per_page).all()
    
    data = []
    for o in orders:
        items_list = []
        for item in o.items:
            items_list.append({
                "product_name": item.product.name if item.product else "منتج",
                "product_image": item.product.image_url if item.product else None,
                "quantity": item.quantity,
                "price": item.price
            })
        data.append({
            "id": o.id,
            "order_number": o.order_number or f"ORD-{o.id:05d}",
            "status": o.status,
            "total": o.total_amount,
            "items_count": len(items_list),
            "created_at": o.created_at.isoformat() if o.created_at else None,
            "items": items_list
        })
        
    return {
        "data": data,
        "meta": {
            "total": total,
            "page": page,
            "per_page": per_page
        }
    }

@app.get("/api/v1/profile/service-requests")
def get_profile_service_requests(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    requests = db.query(models.ServiceRequest).filter(models.ServiceRequest.user_id == current_user.id).order_by(models.ServiceRequest.created_at.desc()).all()
    data = []
    for r in requests:
        data.append({
            "id": r.id,
            "request_number": r.request_number,
            "service_name": r.service.name if r.service else "خدمة",
            "service_image": r.service.image_url if r.service else None,
            "scheduled_at": f"{r.scheduled_date} {r.scheduled_time}",
            "status": r.status,
            "total_price": r.total_price,
            "created_at": r.created_at.isoformat() if r.created_at else None
        })
    return {"data": data}

@app.get("/api/v1/profile/favorites")
def get_profile_favorites(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    favs = db.query(models.Favorite).filter(models.Favorite.user_id == current_user.id).all()
    data = []
    for f in favs:
        p = f.product
        if p and not p.is_deleted:
            data.append({
                "id": f.id,
                "product_id": f.product_id,
                "created_at": f.created_at.isoformat() if f.created_at else None,
                "product": {
                    "id": p.id,
                    "name": p.name,
                    "price": p.price,
                    "sale_price": p.sale_price,
                    "image_url": p.image_url,
                    "status": p.status
                }
            })
    return {"data": data}

@app.post("/api/v1/profile/favorites")
def add_profile_favorite(
    payload: schemas.FavoriteBase,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    prod = db.query(models.Product).filter(models.Product.id == payload.product_id).first()
    if not prod:
        raise HTTPException(status_code=404, detail="المنتج غير موجود")
        
    existing = db.query(models.Favorite).filter(
        models.Favorite.user_id == current_user.id,
        models.Favorite.product_id == payload.product_id
    ).first()
    if existing:
        return {"success": True, "message": "المنتج مضاف بالفعل للمفضلة"}
        
    fav = models.Favorite(
        user_id=current_user.id,
        product_id=payload.product_id
    )
    db.add(fav)
    db.commit()
    return {"success": True, "message": "تمت الإضافة للمفضلة بنجاح"}

@app.delete("/api/v1/profile/favorites/{product_id}")
def remove_profile_favorite(
    product_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    fav = db.query(models.Favorite).filter(
        models.Favorite.user_id == current_user.id,
        models.Favorite.product_id == product_id
    ).first()
    if not fav:
        raise HTTPException(status_code=404, detail="المنتج غير موجود في المفضلة")
        
    db.delete(fav)
    db.commit()
    return {"success": True, "message": "تم الحذف من المفضلة بنجاح"}

@app.get("/api/v1/profile/cart")
def get_profile_cart(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    items = crud.get_cart(db, user_id=current_user.id)
    formatted_items = []
    subtotal = 0.0
    for item in items:
        prod = item.product
        if not prod or prod.is_deleted:
            continue
        item_price = prod.sale_price if prod.sale_price else prod.price
        total_item_price = item_price * item.quantity
        subtotal += total_item_price
        formatted_items.append({
            "id": item.id,
            "product_id": item.product_id,
            "product_name": prod.name,
            "product_image": prod.image_url,
            "price": item_price,
            "quantity": item.quantity,
            "selected_size": item.selected_size,
            "selected_color": item.selected_color,
            "created_at": item.created_at.isoformat() if item.created_at else None
        })
    # Get dynamic delivery fee from settings
    shipping_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "shipping_fee").first()
    import json
    try:
        delivery_fee = float(json.loads(shipping_setting.value)) if shipping_setting else 3000.0
    except Exception:
        delivery_fee = 3000.0

    # Handle free shipping threshold
    threshold_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "free_shipping_threshold").first()
    try:
        threshold = float(json.loads(threshold_setting.value)) if threshold_setting else 100000.0
        if subtotal >= threshold:
            delivery_fee = 0.0
    except Exception:
        pass

    return {
        "success": True,
        "data": {
            "items": formatted_items,
            "subtotal": subtotal,
            "delivery_fee": delivery_fee,
            "total": subtotal + delivery_fee
        }
    }

@app.post("/api/v1/profile/cart/add")
def add_profile_cart(
    payload: schemas.CartItemBase,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    prod = db.query(models.Product).filter(models.Product.id == payload.product_id).first()
    if not prod:
        raise HTTPException(status_code=404, detail="المنتج غير موجود")
        
    size = payload.options.get("size") if payload.options else None
    color = payload.options.get("color") if payload.options else None
    
    item = db.query(models.CartItem).filter(
        models.CartItem.user_id == current_user.id,
        models.CartItem.product_id == payload.product_id,
        models.CartItem.selected_size == size,
        models.CartItem.selected_color == color
    ).first()
    
    if item:
        item.quantity += payload.quantity
        item.updated_at = datetime.datetime.utcnow()
    else:
        item = models.CartItem(
            user_id=current_user.id,
            product_id=payload.product_id,
            quantity=payload.quantity,
            selected_size=size,
            selected_color=color,
            options=payload.options or {}
        )
        db.add(item)
        
    db.commit()
    return {"success": True, "message": "تم إضافة المنتج للسلة"}

@app.put("/api/v1/profile/cart/update")
def update_profile_cart(
    payload: schemas.CartItemUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # For updating cart item quantity/options in profile
    # Let's find by product_id and user_id or we can fetch by options
    # Wait, the frontend might send updating via card item ID, let's allow finding by ID too if they pass item_id
    # We will search by product_id
    size = payload.options.get("size") if payload.options else None
    color = payload.options.get("color") if payload.options else None
    item = db.query(models.CartItem).filter(
        models.CartItem.user_id == current_user.id,
        models.CartItem.product_id == payload.product_id,
        models.CartItem.selected_size == size,
        models.CartItem.selected_color == color
    ).first()
    
    if not item:
        raise HTTPException(status_code=404, detail="عنصر السلة غير موجود")
        
    item.quantity = payload.quantity
    item.updated_at = datetime.datetime.utcnow()
    db.commit()
    return {"success": True, "message": "تم تحديث السلة بنجاح"}

@app.delete("/api/v1/profile/cart/remove/{item_id}")
def remove_profile_cart(
    item_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    item = db.query(models.CartItem).filter(
        models.CartItem.id == item_id,
        models.CartItem.user_id == current_user.id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="العنصر غير موجود بالسلة")
        
    db.delete(item)
    db.commit()
    return {"success": True, "message": "تم إزالة المنتج من السلة"}

@app.get("/api/v1/profile/coupons-history")
def get_profile_coupons_history(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    history = crud.get_user_coupon_history(db, current_user.id)
    return {"data": history}

@app.get("/api/v1/profile/stats")
def get_profile_stats(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    stats = crud.get_user_stats(db, current_user.id)
    return {"data": stats}


# --- ADMIN USERS ENDPOINTS ---

@app.get("/api/admin/users")
@app.get("/api/v1/admin/users")
def admin_get_users(
    search: Optional[str] = None,
    page: int = 1,
    per_page: int = 20,
    db: Session = Depends(get_db)
):
    skip = (page - 1) * per_page
    users = crud.get_admin_users(db, search=search, skip=skip, limit=per_page)
    
    query = db.query(models.User).filter(models.User.role == "customer")
    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            or_(
                models.User.full_name.like(search_filter),
                models.User.name.like(search_filter),
                models.User.phone.like(search_filter)
            )
        )
    total = query.count()
    
    return {
        "success": True,
        "data": [
            {
                "id": u.id,
                "name": u.name or u.full_name,
                "full_name": u.full_name,
                "phone": u.phone,
                "total_orders": u.total_orders,
                "total_spent": u.total_spent,
                "created_at": u.created_at.isoformat() if u.created_at else None,
                "last_login_at": u.last_login_at.isoformat() if u.last_login_at else None
            }
            for u in users
        ],
        "meta": {
            "total": total,
            "page": page,
            "per_page": per_page
        }
    }

@app.get("/api/admin/users/{user_id}")
@app.get("/api/v1/admin/users/{user_id}")
def admin_get_user_detail(
    user_id: int,
    db: Session = Depends(get_db)
):
    detail = crud.get_admin_user_detail(db, user_id=user_id)
    if not detail:
        raise HTTPException(status_code=404, detail="المستخدم غير موجود")
    return {
        "success": True,
        "data": detail
    }



# --- CART ENDPOINTS ---

@app.get("/api/v1/cart", response_model=Dict[str, Any])
def read_cart(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    items = crud.get_cart(db, user_id=current_user.id)
    
    # Format Response matching specs
    formatted_items = []
    subtotal = 0.0
    
    for item in items:
        prod = item.product
        if not prod or prod.is_deleted:
            continue
            
        item_price = prod.sale_price if prod.sale_price else prod.price
        total_item_price = item_price * item.quantity
        subtotal += total_item_price
        
        formatted_items.append({
            "id": item.id,
            "product_id": item.product_id,
            "quantity": item.quantity,
            "options": item.options or {},
            "created_at": item.created_at.isoformat() if item.created_at else None,
            "product": {
                "id": prod.id,
                "name": prod.name,
                "price": prod.price,
                "sale_price": prod.sale_price,
                "image_url": prod.image_url,
                "stock": prod.stock_quantity if prod.stock_quantity is not None else 0,
                "stock_quantity": prod.stock_quantity if prod.stock_quantity is not None else 0,
                "stock_status": "out_of_stock" if (prod.stock_quantity if prod.stock_quantity is not None else 0) <= 0 else "in_stock",
                "is_available": (prod.stock_quantity if prod.stock_quantity is not None else 0) > 0 and prod.is_active and prod.status == "active",
                "in_stock": (prod.stock_quantity if prod.stock_quantity is not None else 0) > 0,
                "quantity": prod.stock_quantity if prod.stock_quantity is not None else 0
            }
        })
        
    # Get dynamic settings from database
    tax_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "tax_rate").first()
    import json
    try:
        tax_rate = float(json.loads(tax_setting.value)) if tax_setting else 15.0
    except Exception:
        tax_rate = 15.0

    shipping_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "shipping_fee").first()
    try:
        shipping_fee = float(json.loads(shipping_setting.value)) if shipping_setting else 3000.0
    except Exception:
        shipping_fee = 3000.0

    threshold_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "free_shipping_threshold").first()
    try:
        threshold = float(json.loads(threshold_setting.value)) if threshold_setting else 100000.0
    except Exception:
        threshold = 100000.0

    vat = subtotal * (tax_rate / 100.0)
    shipping = shipping_fee if (subtotal < threshold and subtotal > 0) else 0.0
    total = subtotal + vat + shipping
    
    return {
        "success": True,
        "data": {
            "items": formatted_items,
            "summary": {
                "subtotal": round(subtotal, 2),
                "vat": round(vat, 2),
                "shipping_fee": shipping,
                "total": round(total, 2)
            }
        }
    }

@app.post("/api/v1/cart/add")
def add_to_cart(
    item_in: schemas.CartItemCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Verify stock
    product = crud.get_product(db, item_in.product_id)
    if not product or product.is_deleted:
        raise HTTPException(status_code=404, detail="المنتج غير موجود")
        
    if product.stock_quantity < item_in.quantity:
        raise HTTPException(status_code=400, detail="الكمية المطلوبة تتجاوز المخزون المتوفر")
        
    item = crud.add_cart_item(db, item_in, user_id=current_user.id)
    
    return {
        "success": True,
        "message": "تم إضافة المنتج للسلة بنجاح",
        "data": {
            "id": item.id,
            "product_id": item.product_id,
            "quantity": item.quantity
        }
    }

@app.put("/api/v1/cart/update")
def update_cart(
    item_id: int,
    item_update: schemas.CartItemUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    item = crud.get_cart_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="عنصر السلة غير موجود")
        
    # Check permissions
    if item.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="غير مصرح لك بتعديل هذا العنصر")
        
    # Check stock
    product = item.product
    if product.stock_quantity < item_update.quantity:
        raise HTTPException(status_code=400, detail="الكمية المطلوبة تتجاوز المخزون المتوفر")
        
    updated_item = crud.update_cart_item(db, item_id, item_update)
    return {
        "success": True,
        "message": "تم تحديث الكمية بالسلة",
        "data": {
            "id": updated_item.id,
            "quantity": updated_item.quantity
        }
    }

@app.delete("/api/v1/cart/remove/{item_id}")
def remove_from_cart(
    item_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    item = crud.get_cart_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="عنصر السلة غير موجود")
        
    # Check permissions
    if item.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="غير مصرح لك بحذف هذا العنصر")
        
    crud.remove_cart_item(db, item_id)
    return {
        "success": True,
        "message": "تم حذف المنتج من السلة بنجاح"
    }

@app.post("/api/v1/cart/clear")
def clear_user_cart(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    crud.clear_cart(db, user_id=current_user.id)
    return {
        "success": True,
        "message": "تم تفريغ السلة بنجاح"
    }


# --- FAVORITES ENDPOINTS ---

@app.get("/api/v1/favorites")
def read_favorites(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    favorites = crud.get_favorites(db, user_id=current_user.id)
    
    formatted = []
    for f in favorites:
        prod = f.product
        if not prod or prod.is_deleted:
            continue
        formatted.append({
            "id": f.id,
            "product_id": f.product_id,
            "product": {
                "id": prod.id,
                "name": prod.name,
                "price": prod.price,
                "sale_price": prod.sale_price,
                "image_url": prod.image_url,
                "stock": prod.stock_quantity if prod.stock_quantity is not None else 0,
                "stock_quantity": prod.stock_quantity if prod.stock_quantity is not None else 0,
                "stock_status": "out_of_stock" if (prod.stock_quantity if prod.stock_quantity is not None else 0) <= 0 else "in_stock",
                "is_available": (prod.stock_quantity if prod.stock_quantity is not None else 0) > 0 and prod.is_active and prod.status == "active",
                "in_stock": (prod.stock_quantity if prod.stock_quantity is not None else 0) > 0,
                "quantity": prod.stock_quantity if prod.stock_quantity is not None else 0
            }
        })
    return {
        "success": True,
        "data": formatted
    }

@app.post("/api/v1/favorites")
def add_to_favorites(
    payload: schemas.FavoriteCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    fav = crud.add_favorite(db, payload.product_id, user_id=current_user.id)
    return {
        "success": True,
        "message": "تم الإضافة للمفضلة بنجاح",
        "data": {
            "id": fav.id,
            "product_id": fav.product_id
        }
    }

@app.delete("/api/v1/favorites/{product_id}")
def remove_from_favorites(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    removed = crud.remove_favorite(db, product_id, user_id=current_user.id)
    if not removed:
        raise HTTPException(status_code=404, detail="المنتج غير موجود بالمفضلة")
    return {
        "success": True,
        "message": "تم إزالة المنتج من المفضلة بنجاح"
    }


# --- ADDRESSES ENDPOINTS ---

@app.get("/api/v1/addresses")
def read_addresses(
    phone_number: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    user_id = current_user.id if current_user else None
    addresses = crud.get_addresses(db, user_id=user_id, phone_number=phone_number)
    return {
        "success": True,
        "data": addresses
    }

@app.post("/api/v1/addresses")
def add_address(
    payload: schemas.AddressCreate,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    user_id = current_user.id if current_user else None
    address = crud.create_address(db, payload, user_id=user_id)
    return {
        "success": True,
        "message": "تم حفظ العنوان بنجاح",
        "data": address
    }

@app.put("/api/v1/addresses/{address_id}")
def edit_address(
    address_id: int,
    payload: schemas.AddressUpdate,
    db: Session = Depends(get_db)
):
    address = crud.update_address(db, address_id, payload)
    if not address:
        raise HTTPException(status_code=404, detail="العنوان غير موجود")
    return {
        "success": True,
        "message": "تم تحديث العنوان بنجاح",
        "data": address
    }

@app.delete("/api/v1/addresses/{address_id}")
def remove_address(
    address_id: int,
    db: Session = Depends(get_db)
):
    deleted = crud.delete_address(db, address_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="العنوان غير موجود")
    return {
        "success": True,
        "message": "تم حذف العنوان بنجاح"
    }


# --- RATINGS & REVIEWS ENDPOINTS ---

@app.get("/api/v1/ratings/{product_id}")
def read_product_ratings(
    product_id: int,
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    ratings = crud.get_ratings_by_product(db, product_id, skip=skip, limit=limit)
    
    # Calculate stats
    total_reviews = db.query(models.ProductRating).filter(models.ProductRating.product_id == product_id).count()
    avg_stars = db.query(func.avg(models.ProductRating.rating)).filter(models.ProductRating.product_id == product_id).scalar() or 0.0
    
    formatted = []
    for r in ratings:
        formatted.append({
            "id": r.id,
            "rating": r.rating,
            "comment": r.comment,
            "image_url": r.image_url,
            "created_at": r.created_at.isoformat() if r.created_at else None,
            "user": {
                "name": r.user.full_name if r.user else "مستخدم نوزل"
            }
        })
        
    return {
        "success": True,
        "data": {
            "avg_rating": round(avg_stars, 2),
            "total_reviews": total_reviews,
            "reviews": formatted
        }
    }

@app.post("/api/v1/ratings")
def submit_rating(
    payload: schemas.ProductRatingCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    rating = crud.create_rating(db, payload, user_id=current_user.id)
    return {
        "success": True,
        "message": "تم تقديم التقييم بنجاح، شكراً لمشاركتنا رأيك",
        "data": {
            "id": rating.id,
            "rating": rating.rating
        }
    }


# --- CATEGORIES V1 ---

@app.get("/api/v1/categories")
def read_v1_categories(db: Session = Depends(get_db)):
    categories = db.query(models.Category).filter(models.Category.parent_id == None).all()
    formatted = []
    for c in categories:
        formatted.append({
            "id": c.id,
            "name": c.name,
            "description": c.description,
            "image_url": c.image_url,
            "icon_url": c.icon_url,
            "product_count": db.query(models.Product).filter(models.Product.category_id == c.id, models.Product.is_deleted == False).count()
        })
    return {
        "success": True,
        "data": formatted
    }

@app.get("/api/v1/categories/{id}/subcategories")
def read_v1_subcategories(id: int, db: Session = Depends(get_db)):
    subcategories = db.query(models.Category).filter(models.Category.parent_id == id).all()
    formatted = []
    for s in subcategories:
        formatted.append({
            "id": s.id,
            "name": s.name,
            "description": s.description,
            "image_url": s.image_url,
            "icon_url": s.icon_url,
            "product_count": db.query(models.Product).filter(models.Product.subcategory_id == s.id, models.Product.is_deleted == False).count()
        })
    return {
        "success": True,
        "data": formatted
    }

@app.get("/api/v1/categories/{id}/products")
def read_v1_category_products(
    id: int,
    skip: int = 0,
    limit: int = 20,
    search: Optional[str] = None,
    sort_by: Optional[str] = Query("newest", regex="^(newest|price_asc|price_desc|best_seller)$"),
    db: Session = Depends(get_db)
):
    query = db.query(models.Product).filter(
        (models.Product.category_id == id) | (models.Product.subcategory_id == id),
        models.Product.is_deleted == False
    )
    
    if search:
        query = query.filter(models.Product.name.ilike(f"%{search}%"))
        
    if sort_by == "price_asc":
        query = query.order_by(models.Product.price.asc())
    elif sort_by == "price_desc":
        query = query.order_by(models.Product.price.desc())
    else:
        query = query.order_by(models.Product.created_at.desc())
        
    total = query.count()
    products = query.offset(skip).limit(limit).all()
    
    formatted = []
    for p in products:
        # Calculate rating
        avg_stars = db.query(func.avg(models.ProductRating.rating)).filter(models.ProductRating.product_id == p.id).scalar() or 0.0
        
        stock_qty = p.stock_quantity if p.stock_quantity is not None else 0
        low_stock_thr = p.low_stock_threshold if p.low_stock_threshold is not None else 10
        is_out_of_stock = stock_qty <= 0
        formatted.append({
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "price": p.price,
            "sale_price": p.sale_price,
            "stock": stock_qty,
            "stock_quantity": stock_qty,
            "stock_status": "out_of_stock" if is_out_of_stock else "in_stock",
            "is_available": stock_qty > 0 and p.is_active and p.status == "active",
            "low_stock_threshold": low_stock_thr,
            "is_low_stock": stock_qty <= low_stock_thr,
            "quantity": stock_qty,
            "brand": extract_brand(p.name),
            "category_name": p.category.name if p.category else "",
            "image_url": p.image_url,
            "rating": round(avg_stars, 1),
            "features": p.features or [],
            "specifications": p.specifications or {},
            "tags": p.tags or []
        })
        
    return {
        "success": True,
        "data": {
            "total": total,
            "products": formatted
        }
    }


# --- ORDERS V1 ---

@app.get("/api/v1/orders")
def read_v1_orders(
    phone_number: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    query = db.query(models.Order)
    if current_user:
        if current_user.role != "customer":
            if phone_number and phone_number.strip():
                variants = get_phone_variants(phone_number)
                query = query.filter(models.Order.customer_phone.in_(variants))
        elif current_user.phone and current_user.phone.strip():
            variants = get_phone_variants(current_user.phone)
            query = query.filter(models.Order.customer_phone.in_(variants))
        else:
            query = query.filter(models.Order.id == -1)
    elif phone_number and phone_number.strip():
        variants = get_phone_variants(phone_number)
        query = query.filter(models.Order.customer_phone.in_(variants))
    else:
        raise HTTPException(status_code=400, detail="الرجاء تسجيل الدخول أو توفير رقم الهاتف")
        
    orders = query.order_by(models.Order.created_at.desc()).all()
    formatted = []
    for o in orders:
        formatted.append({
            "id": o.id,
            "customer_name": o.customer_name,
            "customer_phone": o.customer_phone,
            "total_amount": o.total_amount,
            "status": o.status,
            "created_at": o.created_at.isoformat() if o.created_at else None,
            "items_count": len(o.items)
        })
    return {
        "success": True,
        "data": formatted
    }

@app.get("/api/v1/orders/{order_id}")
def read_v1_order_details(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    if not current_user:
        raise HTTPException(status_code=401, detail="الرجاء تسجيل الدخول أولاً")
        
    if current_user.role == "customer":
        variants = get_phone_variants(current_user.phone)
        if order.customer_phone not in variants:
            raise HTTPException(status_code=403, detail="ليس لديك صلاحية لعرض هذا الطلب")
        
    items_formatted = []
    for item in order.items:
        prod = item.product
        items_formatted.append({
            "id": item.id,
            "product_id": item.product_id,
            "quantity": item.quantity,
            "price": item.price,
            "product": {
                "id": prod.id if prod else item.product_id,
                "name": prod.name if prod else "منتج محذوف",
                "image_url": prod.image_url if prod else None
            }
        })
        
    formatted = {
        "id": order.id,
        "customer_name": order.customer_name,
        "customer_phone": order.customer_phone,
        "customer_email": order.customer_email,
        "total_amount": order.total_amount,
        "status": order.status,
        "created_at": order.created_at.isoformat() if order.created_at else None,
        "items": items_formatted
    }
    return {
        "success": True,
        "data": formatted
    }

class StatusUpdatePayload(BaseModel):
    status: str
    note: Optional[str] = ""
    send_notification: Optional[bool] = False

@app.get("/api/v1/orders/{order_id}/detail")
def get_v1_order_detail(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    if not current_user:
        raise HTTPException(status_code=401, detail="الرجاء تسجيل الدخول أولاً")
        
    if current_user.role == "customer":
        variants = get_phone_variants(current_user.phone)
        if order.customer_phone not in variants:
            raise HTTPException(status_code=403, detail="ليس لديك صلاحية لعرض هذا الطلب")
        
    user_id = 0
    total_orders = 0
    total_spent = 0.0
    if order.customer_phone:
        user = db.query(models.User).filter(models.User.phone == order.customer_phone).first()
        if user:
            user_id = user.id
        
        total_orders = db.query(models.Order).filter(models.Order.customer_phone == order.customer_phone).count()
        total_spent = db.query(func.sum(models.Order.total_amount)).filter(
            models.Order.customer_phone == order.customer_phone,
            models.Order.status == 'completed'
        ).scalar() or 0.0
        
    history = order.status_history
    if not history:
        history = [{
            "status": "new",
            "timestamp": order.created_at.isoformat() if order.created_at else datetime.datetime.utcnow().isoformat(),
            "note": "تم استلام الطلب"
        }]
        
    items_formatted = []
    for item in order.items:
        prod = item.product
        items_formatted.append({
            "id": item.id,
            "quantity": item.quantity,
            "price": item.price,
            "selected_size": item.selected_size or "",
            "selected_color": item.selected_color or "",
            "product": {
                "id": prod.id if prod else item.product_id,
                "name": prod.name if prod else "منتج محذوف",
                "image_url": prod.image_url if prod else "",
                "sku": prod.sku if prod else ""
            }
        })
        
    subtotal = order.subtotal
    if subtotal is None or subtotal == 0:
        subtotal = sum(item.price * item.quantity for item in order.items)
        
    delivery_fee = order.delivery_fee
    if delivery_fee is None:
        shipping_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "shipping_fee").first()
        if shipping_setting:
            try:
                import json
                delivery_fee = float(json.loads(shipping_setting.value))
            except Exception:
                try:
                    delivery_fee = float(shipping_setting.value)
                except Exception:
                    delivery_fee = 3000.0
        else:
            delivery_fee = 3000.0

    total = order.total_amount
    coupon_discount = order.coupon_discount if order.coupon_discount is not None else 0.0
    
    if (coupon_discount == 0.0 or coupon_discount is None) and (order.coupon_code or total < (subtotal + delivery_fee)):
        calc_discount = (subtotal + delivery_fee) - total
        if calc_discount > 0:
            coupon_discount = calc_discount
            
    if total is None or total == 0:
        total = subtotal + delivery_fee - coupon_discount

    formatted = {
        "id": order.id,
        "created_at": order.created_at.isoformat() if order.created_at else None,
        "status": order.status,
        "status_history": history,
        "customer": {
            "id": user_id,
            "name": order.customer_name,
            "phone": order.customer_phone or "",
            "total_orders": total_orders,
            "total_spent": total_spent
        },
        "address": order.address or "",
        "notes": order.notes or "",
        "payment_method": order.payment_method or "cash",
        "items": items_formatted,
        "subtotal": subtotal,
        "delivery_fee": delivery_fee,
        "coupon_code": order.coupon_code or "",
        "coupon_discount": coupon_discount,
        "total": total,
        "invoice_number": order.invoice_number or f"INV-{order.id}"
    }
    
    return {
        "success": True,
        "data": formatted
    }

@app.put("/api/v1/orders/{order_id}/status")
async def update_v1_order_status(
    order_id: int,
    payload: StatusUpdatePayload,
    db: Session = Depends(get_db)
):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    old_status = order.status
    order.status = payload.status
    
    history = list(order.status_history or [])
    history.append({
        "status": payload.status,
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "note": payload.note or ""
    })
    order.status_history = history
    
    from sqlalchemy.orm.attributes import flag_modified
    flag_modified(order, "status_history")
    
    db.commit()
    db.refresh(order)
    
    crud.create_audit_log(db, user_id=1, action="UPDATE_ORDER_STATUS", details=f"Updated order ID {order_id} status from {old_status} to {payload.status} with note: {payload.note}")

    status_arabic = {
        "new": "جديد",
        "pending": "معلق",
        "confirmed": "مؤكد",
        "processing": "جاري التحضير",
        "shipped": "تم الشحن",
        "on_the_way": "في الطريق",
        "delivered": "تم التسليم",
        "completed": "مكتمل",
        "cancelled": "ملغي"
    }.get(order.status, order.status)

    notification_data = schemas.NotificationCreate(
        title="تحديث حالة الطلب",
        body=f"تم تحديث حالة طلبك رقم #{order.id} إلى: {status_arabic}",
        target_type="order",
        target_id=str(order.id),
        status="sent"
    )
    try:
        crud.create_notification(db, notification_data, user_id=1)
    except Exception as e:
        print(f"Error creating status notification: {e}")

    try:
        await manager.broadcast({
            "event": "order_status_updated",
            "order_id": order.id,
            "status": order.status
        })
    except Exception as e:
        print(f"Error broadcasting order status update: {e}")

    if payload.send_notification:
        print(f"[FCM PUSH] Sending status update notification to customer. Title: تحديث حالة الطلب, Body: تم تحديث حالة طلبك رقم #{order.id} إلى: {status_arabic}")

    return {
        "success": True,
        "message": "تم تحديث حالة الطلب بنجاح",
        "data": {
            "id": order.id,
            "status": order.status,
            "status_history": order.status_history
        }
    }

@app.post("/api/v1/orders/{order_id}/cancel")
def cancel_v1_order(
    order_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    if not current_user:
        raise HTTPException(status_code=401, detail="الرجاء تسجيل الدخول أولاً")
        
    if current_user.role == "customer":
        variants = get_phone_variants(current_user.phone)
        if order.customer_phone not in variants:
            raise HTTPException(status_code=403, detail="ليس لديك صلاحية لإلغاء هذا الطلب")
        
    if order.status not in ["pending", "processing"]:
        raise HTTPException(status_code=400, detail="لا يمكن إلغاء الطلب في حالته الحالية")
        
    user_id = current_user.id if current_user else 1 # default system ID
    crud.update_order_status(db, order_id, "cancelled", user_id)
    return {
        "success": True,
        "message": "تم إلغاء الطلب بنجاح"
    }

@app.post("/api/v1/orders/{order_id}/reorder")
def reorder_v1_order(
    order_id: int,
    session_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    order = crud.get_order(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    if not current_user:
        raise HTTPException(status_code=401, detail="الرجاء تسجيل الدخول أولاً")
        
    if current_user.role == "customer":
        variants = get_phone_variants(current_user.phone)
        if order.customer_phone not in variants:
            raise HTTPException(status_code=403, detail="ليس لديك صلاحية لإعادة طلب هذا الطلب")

        
    # Add all order items to cart
    user_id = current_user.id if current_user else None
    for item in order.items:
        item_in = schemas.CartItemCreate(
            product_id=item.product_id,
            quantity=item.quantity,
            options={},
            session_id=session_id
        )
        crud.add_cart_item(db, item_in, user_id=user_id)
        
    return {
        "success": True,
        "message": "تم إضافة جميع منتجات الطلب إلى السلة الحالية بنجاح"
    }


# --- COUPON/DISCOUNT V1 VALIDATE ---

# --- COUPON/DISCOUNT V1 VALIDATE ---

@app.post("/api/v1/coupons/validate")
def validate_v1_coupon(
    validation_in: schemas.CouponValidationRequest,
    db: Session = Depends(get_db)
):
    # 1. ابحث عن الكوبون بالـ code (case-insensitive)
    coupon = db.query(models.Coupon).filter(models.Coupon.code.ilike(validation_in.code.strip())).first()
    if not coupon:
        return {
            "success": False,
            "message": "كود الخصم غير صحيح أو غير موجود",
            "data": None
        }

    # 2. تحقق is_active = true
    if not coupon.is_active:
        return {
            "success": False,
            "message": "كود الخصم غير نشط حالياً",
            "data": None
        }

    # 3. تحقق expires_at > now()
    from datetime import datetime
    now = datetime.utcnow()
    if coupon.end_date and coupon.end_date < now:
        return {
            "success": False,
            "message": "كود الخصم منتهي الصلاحية",
            "data": None
        }

    # 4. تحقق used_count < max_uses
    if coupon.usage_limit is not None and coupon.usage_count >= coupon.usage_limit:
        return {
            "success": False,
            "message": "كود الخصم مستنفذ",
            "data": None
        }

    # 5. تحقق cart_total >= min_order_amount
    cart_total = validation_in.order_value
    min_amount = coupon.min_order_value or 0.0
    if cart_total < min_amount:
        min_amount_formatted = f"{int(min_amount):,} د.ع"
        return {
            "success": False,
            "message": f"الحد الأدنى للطلب لاستخدام الكود هو {min_amount_formatted}",
            "data": None
        }

    # 6. احسب discount_amount
    if coupon.discount_type == "percentage":
        discount_amount = cart_total * (coupon.value / 100.0)
        if coupon.max_discount_value is not None:
            discount_amount = min(discount_amount, coupon.max_discount_value)
    else:
        discount_amount = min(coupon.value, cart_total)

    new_total = max(0.0, cart_total - discount_amount)

    # 7. أرجع: {code, type, value, discount_amount, new_total}
    return {
        "success": True,
        "message": "تم تطبيق الكود بنجاح",
        "data": {
            "code": coupon.code,
            "type": coupon.discount_type,
            "value": coupon.value,
            "min_order_amount": min_amount,
            "max_discount_amount": coupon.max_discount_value,
            "expires_at": coupon.end_date.isoformat() if coupon.end_date else None,
            "is_active": coupon.is_active,
            "discount_amount": round(discount_amount, 2),
            "new_total": round(new_total, 2)
        }
    }


@app.post("/api/v1/orders")
async def create_v1_order(
    payload: Dict[str, Any],
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    cart_items = payload.get("cart_items", [])
    if not cart_items:
        raise HTTPException(status_code=400, detail="السلة فارغة")

    user_id = current_user.id
    session_id = payload.get("session_id")

    # 1. تحقق من الكوبون مجدداً (لا تثق بالـ client)
    coupon_code = payload.get("coupon_code")
    coupon = None
    discount_amount = 0.0
    
    # Calculate subtotal first
    subtotal = 0.0
    for item in cart_items:
        prod_id = item.get("product_id")
        qty = item.get("quantity", 1)
        product = db.query(models.Product).filter(models.Product.id == prod_id).first()
        if not product or product.is_deleted:
            raise HTTPException(status_code=400, detail=f"المنتج ذو المعرف {prod_id} غير موجود")
        if product.stock_quantity < qty:
            raise HTTPException(status_code=400, detail=f"الكمية المطلوبة من {product.name} تتجاوز المخزون المتوفر")
        price = product.sale_price if product.sale_price else product.price
        subtotal += price * qty

    if coupon_code and coupon_code.strip():
        coupon = db.query(models.Coupon).filter(models.Coupon.code.ilike(coupon_code.strip())).first()
        if coupon and coupon.is_active:
            from datetime import datetime
            now = datetime.utcnow()
            if not (coupon.end_date and coupon.end_date < now):
                if not (coupon.usage_limit is not None and coupon.usage_count >= coupon.usage_limit):
                    min_amount = coupon.min_order_value or 0.0
                    if subtotal >= min_amount:
                        if coupon.discount_type == "percentage":
                            discount_amount = subtotal * (coupon.value / 100.0)
                            if coupon.max_discount_value is not None:
                                discount_amount = min(discount_amount, coupon.max_discount_value)
                        else:
                            discount_amount = min(coupon.value, subtotal)

    # 2. احسب الإجمالي الصحيح
    # Get dynamic delivery fee from settings
    shipping_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "shipping_fee").first()
    import json
    try:
        delivery_fee = float(json.loads(shipping_setting.value)) if shipping_setting else 3000.0
    except Exception:
        delivery_fee = 3000.0

    # Handle free shipping threshold
    threshold_setting = db.query(models.SystemSetting).filter(models.SystemSetting.key == "free_shipping_threshold").first()
    try:
        threshold = float(json.loads(threshold_setting.value)) if threshold_setting else 100000.0
        if subtotal - discount_amount >= threshold:
            delivery_fee = 0.0
    except Exception:
        pass

    total_amount = max(0.0, subtotal + delivery_fee - discount_amount)

    customer_name = current_user.full_name if (current_user and current_user.full_name) else "زبون زائر"
    customer_email = current_user.email if (current_user and current_user.email) else "guest@nozzle.com"
    customer_phone = current_user.phone if (current_user and current_user.phone) else payload.get("phone_number", "07700000000")

    # 3. أنشئ الطلب في قاعدة البيانات
    import random
    db_order = models.Order(
        user_id=user_id,
        order_number=payload.get("order_number") or f"ORD-{int(datetime.datetime.utcnow().timestamp())}{random.randint(10, 99)}",
        customer_name=customer_name,
        customer_email=customer_email,
        customer_phone=customer_phone,
        total_amount=total_amount,
        status="pending",
        address=payload.get("customer_address") or payload.get("address"),
        notes=payload.get("notes"),
        payment_method=payload.get("payment_method", "cash"),
        subtotal=payload.get("subtotal", subtotal),
        delivery_fee=payload.get("delivery_fee", delivery_fee),
        coupon_code=payload.get("coupon_code"),
        coupon_discount=payload.get("coupon_discount", discount_amount),
        invoice_number=f"INV-{int(datetime.datetime.utcnow().timestamp())}",
        status_history=[{
            "status": "pending",
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "note": "تم تقديم الطلب بنجاح"
        }]
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)

    # Create OrderItems and decrement stock
    for item in cart_items:
        prod_id = item.get("product_id")
        qty = item.get("quantity", 1)
        product = db.query(models.Product).filter(models.Product.id == prod_id).first()
        price = product.sale_price if product.sale_price else product.price
        
        db_item = models.OrderItem(
            order_id=db_order.id,
            product_id=prod_id,
            quantity=qty,
            price=price
        )
        db.add(db_item)
        
        # Decrement product stock
        product.stock_quantity = max(0, (product.stock_quantity or 0) - qty)
        
        # Broadcast stock update via WebSocket
        stock_qty = product.stock_quantity
        is_avail = stock_qty > 0 and product.is_active and product.status == "active"
        await manager.broadcast({
            "event": "stock_updated",
            "product_id": product.id,
            "new_qty": stock_qty,
            "stock_quantity": stock_qty,
            "is_available": is_avail,
            "stock_status": "in_stock" if stock_qty > 0 else "out_of_stock"
        })

    # 4. زد coupon.usage_count بمقدار 1
    if coupon:
        coupon.usage_count += 1

    # 5. فرّغ السلة من السيرفر
    crud.clear_cart(db, user_id=user_id, session_id=session_id)

    db.commit()

    # 6. أرسل Push Notification للمستخدم
    notification_data = schemas.NotificationCreate(
        title="تأكيد الطلب",
        body=f"تم تأكيد طلبك رقم {db_order.id} بنجاح!",
        target_type="order",
        target_id=str(db_order.id),
        status="sent"
    )
    try:
        crud.create_notification(db, notification_data, user_id=user_id if user_id else 1)
    except Exception as e:
        print(f"Error creating notification: {e}")

    # Broadcast new order to Admin Panel WebSocket
    try:
        await manager.broadcast({
            "event": "new_order",
            "order_id": db_order.id,
            "customer_name": db_order.customer_name,
            "total_amount": db_order.total_amount,
            "status": db_order.status
        })
    except Exception as e:
        print(f"Error broadcasting order websocket: {e}")

    # 7. أرجع رقم الطلب للتطبيق
    return {
        "success": True,
        "message": "تم إنشاء الطلب بنجاح",
        "data": {
            "id": db_order.id,
            "order_number": f"NZL-{db_order.id:05d}",
            "total_amount": db_order.total_amount
        }
    }


# --- SERVICES ENDPOINTS ---

# --- SERVICES ENDPOINTS (V1 & COMPATIBILITY) ---

@app.get("/api/v1/services", response_model=Dict[str, Any])
def read_services_v1(
    category: Optional[str] = Query(None),
    is_featured: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1),
    db: Session = Depends(get_db)
):
    skip = (page - 1) * per_page
    services = crud.get_services(db, category=category, is_featured=is_featured, skip=skip, limit=per_page)
    # Get total count for metadata
    total = db.query(models.Service).filter(models.Service.is_available == True).count()
    services_data = [schemas.ServiceResponse.model_validate(s).model_dump() for s in services]
    return {
        "success": True,
        "data": services_data,
        "meta": {"total": total, "page": page, "per_page": per_page}
    }

@app.get("/api/v1/services/categories", response_model=Dict[str, Any])
def get_services_categories_v1(db: Session = Depends(get_db)):
    categories = crud.get_service_categories(db)
    return {"data": categories}

@app.get("/api/v1/services/{service_id}", response_model=Dict[str, Any])
def read_service_detail_v1(service_id: int, db: Session = Depends(get_db)):
    service = crud.get_service(db, service_id)
    if not service:
        raise HTTPException(status_code=404, detail="الخدمة غير موجودة")
    return {"success": True, "data": schemas.ServiceResponse.model_validate(service).model_dump()}

@app.post("/api/v1/service-requests", response_model=Dict[str, Any])
def create_service_request_v1(request: schemas.ServiceRequestCreate, db: Session = Depends(get_db)):
    # 1. Validation: customer_phone: 11 digits starting with 07
    import re
    if not re.match(r"^07[0-9]{9}$", request.customer_phone):
        raise HTTPException(status_code=400, detail="رقم الهاتف يجب أن يكون 11 رقماً ويبدأ بـ 07")

    # 2. Validation: scheduled_date: from tomorrow at least (today + 1)
    try:
        sched_date = datetime.datetime.strptime(request.scheduled_date, "%Y-%m-%d").date()
        today = datetime.date.today()
        if sched_date < today + datetime.timedelta(days=1):
            raise HTTPException(status_code=400, detail="تاريخ الحجز يجب أن يكون من يوم غد أو أبعد")
    except ValueError:
        raise HTTPException(status_code=400, detail="صيغة التاريخ غير صحيحة، يجب أن تكون YYYY-MM-DD")

    # 3. Validation: scheduled_time: between 8:00 and 20:00
    try:
        time_parts = list(map(int, request.scheduled_time.split(":")))
        sched_hour = time_parts[0]
        if sched_hour < 8 or sched_hour > 20:
            raise HTTPException(status_code=400, detail="وقت الحجز يجب أن يكون بين الساعة 8:00 صباحاً و 8:00 مساءً")
    except Exception:
        raise HTTPException(status_code=400, detail="صيغة الوقت غير صحيحة، يجب أن تكون HH:MM")

    # Create Request
    try:
        req = crud.create_service_request(db, request)
        return {
            "success": True,
            "data": {
                "id": req.id,
                "request_number": req.request_number
            }
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/v1/service-requests", response_model=Dict[str, Any])
def get_service_requests_v1(
    phone: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    if current_user:
        if current_user.role != "customer":
            if phone:
                requests = crud.get_user_service_requests(db, phone)
            else:
                requests = db.query(models.ServiceRequest).all()
        else:
            user_phone = current_user.phone or ""
            requests = crud.get_user_service_requests(db, user_phone)
    elif phone:
        requests = crud.get_user_service_requests(db, phone)
    else:
        raise HTTPException(status_code=400, detail="الرجاء تسجيل الدخول أو توفير رقم الهاتف")
        
    requests_data = [schemas.ServiceRequestResponse.model_validate(r).model_dump() for r in requests]
    return {"success": True, "data": requests_data}

@app.get("/api/v1/service-requests/{request_id}", response_model=Dict[str, Any])
def get_service_request_detail_v1(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(get_current_user_optional)
):
    req = crud.get_service_request(db, request_id)
    if not req:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    if not current_user:
        raise HTTPException(status_code=401, detail="الرجاء تسجيل الدخول أولاً")
        
    if current_user.role == "customer":
        variants = get_phone_variants(current_user.phone)
        if req.customer_phone not in variants:
            raise HTTPException(status_code=403, detail="ليس لديك صلاحية للوصول إلى هذا الحجز")

        
    return {"success": True, "data": schemas.ServiceRequestResponse.model_validate(req).model_dump()}


# --- COMPATIBILITY WRAPPERS FOR MOBILE APP ---

@app.get("/api/services", response_model=Dict[str, Any])
def read_services_compat(db: Session = Depends(get_db)):
    services = crud.get_services(db)
    formatted = []
    for s in services:
        formatted.append({
            "id": s.id,
            "title": s.name,
            "title_ar": s.name,
            "description": s.description,
            "description_ar": s.description,
            "icon": "build",
            "image": s.image_url,
            "price": s.base_price,
            "duration_minutes": s.duration_minutes,
            "is_active": s.is_available
        })
    return {"status": "success", "data": formatted}

@app.post("/api/services/book")
def book_service_compat(
    booking: schemas.ServiceBookingCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    try:
        # Map old schemas.ServiceBookingCreate structure to ServiceRequestCreate
        req_schema = schemas.ServiceRequestCreate(
            service_id=booking.service_id,
            service_option_id=None,
            customer_name=booking.customer_name or current_user.full_name or "زبون",
            customer_phone=booking.customer_phone or current_user.phone or "07700000000",
            address=booking.customer_district or "بغداد",
            latitude=None,
            longitude=None,
            scheduled_date=booking.booking_date,
            scheduled_time=booking.preferred_time[:5] if len(booking.preferred_time) >= 5 else "09:00",
            notes=booking.notes,
            total_price=0.0,
            payment_method="cash",
            user_id=current_user.id
        )
        db_req = crud.create_service_request(db, req_schema)
        return {
            "status": "success",
            "message": "تم حجز الموعد بنجاح",
            "data": {
                "id": db_req.id,
                "status": db_req.status,
                "booking_date": db_req.scheduled_date,
                "preferred_time": db_req.scheduled_time
            }
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/services/appointments")
def read_user_appointments_compat(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    phone = current_user.phone or ""
    appointments = crud.get_user_service_requests(db, phone)
    formatted = []
    for a in appointments:
        formatted.append({
            "id": a.id,
            "user_id": current_user.id,
            "service_id": a.service_id,
            "car_model": "سيارة العميل",
            "car_number": "",
            "preferred_date": a.scheduled_date,
            "preferred_time": a.scheduled_time,
            "customer_name": a.customer_name,
            "customer_phone": a.customer_phone,
            "customer_district": a.address,
            "notes": a.notes,
            "status": a.status,
            "service_name": a.service.name if a.service else "خدمة غير معروفة",
            "name_en": a.service.name if a.service else "Unknown Service",
            "icon": "build",
            "price": a.total_price,
            "duration_minutes": a.service.duration_minutes if a.service else 60,
            "created_at": a.created_at.isoformat() if a.created_at else None
        })
    return {
        "success": True,
        "appointments": formatted,
        "status": "success",
        "data": formatted
    }



# --- INVENTORY & STOCK MANAGEMENT ENDPOINTS ---

class ThresholdUpdate(BaseModel):
    low_stock_threshold: int
    reorder_point: int
    max_stock: int


@app.get("/api/inventory/dashboard")
def get_inventory_dashboard(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    products = db.query(models.Product).filter(models.Product.is_deleted == False).all()
    total_products = len(products)
    
    out_of_stock = 0
    low_stock = 0
    critical_stock = 0
    low_stock_items = []
    
    for p in products:
        stock = p.stock_quantity if p.stock_quantity is not None else 0
        threshold = p.low_stock_threshold if p.low_stock_threshold is not None else 10
        reorder = p.reorder_point if p.reorder_point is not None else 20
        
        if stock <= 0:
            out_of_stock += 1
            low_stock_items.append({
                "id": p.id,
                "name": p.name,
                "sku": p.sku,
                "stock": stock,
                "low_stock_threshold": threshold,
                "reorder_point": reorder,
                "max_stock": p.max_stock or 100,
                "status": "out_of_stock"
            })
        elif stock <= threshold:
            critical_stock += 1
            low_stock_items.append({
                "id": p.id,
                "name": p.name,
                "sku": p.sku,
                "stock": stock,
                "low_stock_threshold": threshold,
                "reorder_point": reorder,
                "max_stock": p.max_stock or 100,
                "status": "critical"
            })
        elif stock <= reorder:
            low_stock += 1
            low_stock_items.append({
                "id": p.id,
                "name": p.name,
                "sku": p.sku,
                "stock": stock,
                "low_stock_threshold": threshold,
                "reorder_point": reorder,
                "max_stock": p.max_stock or 100,
                "status": "low"
            })
            
    recent_movements_db = crud.get_stock_movements(db, limit=20)
    recent_movements = []
    for m in recent_movements_db:
        recent_movements.append({
            "id": m.id,
            "product_id": m.product_id,
            "product_name": m.product.name if m.product else "منتج محذوف",
            "type": m.type,
            "quantity_change": m.quantity_change,
            "quantity_before": m.quantity_before,
            "quantity_after": m.quantity_after,
            "reason": m.reason,
            "invoice_number": m.invoice_number,
            "created_by": m.user.full_name if m.user else "نظام",
            "created_at": m.created_at.isoformat()
        })
        
    return {
        "status": "success",
        "data": {
            "total_products": total_products,
            "out_of_stock_count": out_of_stock,
            "critical_stock_count": critical_stock,
            "low_stock_count": low_stock,
            "low_stock_items": low_stock_items,
            "recent_movements": recent_movements
        }
    }


@app.post("/api/inventory/stock-update")
async def stock_update(
    movement_in: schemas.StockMovementCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    try:
        m = crud.create_stock_movement(
            db,
            product_id=movement_in.product_id,
            type=movement_in.type,
            quantity_change=movement_in.quantity_change,
            reason=movement_in.reason,
            invoice_number=movement_in.invoice_number,
            user_id=current_user.id
        )
        
        stock_qty = m.quantity_after
        product = db.query(models.Product).filter(models.Product.id == m.product_id).first()
        is_avail = stock_qty > 0 and product.is_active and product.status == "active" if product else False
        
        await manager.broadcast({
            "event": "stock_updated",
            "product_id": m.product_id,
            "new_qty": stock_qty,
            "stock_quantity": stock_qty,
            "stock_status": "in_stock" if stock_qty > 0 else "out_of_stock",
            "is_available": is_avail
        })
        
        return {
            "status": "success",
            "message": "تم تحديث المخزون بنجاح",
            "data": {
                "id": m.id,
                "quantity_before": m.quantity_before,
                "quantity_after": m.quantity_after,
                "quantity_change": m.quantity_change
            }
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/inventory/history/{product_id}")
def get_inventory_history(
    product_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    movements_db = crud.get_stock_movements(db, product_id=product_id, limit=100)
    formatted = []
    for m in movements_db:
        formatted.append({
            "id": m.id,
            "type": m.type,
            "quantity_change": m.quantity_change,
            "quantity_before": m.quantity_before,
            "quantity_after": m.quantity_after,
            "reason": m.reason,
            "invoice_number": m.invoice_number,
            "created_by": m.user.full_name if m.user else "نظام",
            "created_at": m.created_at.isoformat()
        })
    return {"status": "success", "data": formatted}


@app.put("/api/inventory/thresholds/{product_id}")
def update_inventory_thresholds(
    product_id: int,
    thresholds: ThresholdUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    product = db.query(models.Product).filter(models.Product.id == product_id, models.Product.is_deleted == False).first()
    if not product:
        raise HTTPException(status_code=404, detail="المنتج غير موجود")
        
    product.low_stock_threshold = thresholds.low_stock_threshold
    product.reorder_point = thresholds.reorder_point
    product.max_stock = thresholds.max_stock
    
    db.commit()
    db.refresh(product)
    
    crud.create_audit_log(db, current_user.id, "UPDATE_THRESHOLDS", f"Updated inventory thresholds for {product.name}")
    
    return {
        "status": "success",
        "message": "تم تحديث حدود المخزون بنجاح",
        "data": {
            "id": product.id,
            "low_stock_threshold": product.low_stock_threshold,
            "reorder_point": product.reorder_point,
            "max_stock": product.max_stock
        }
    }


# --- ADMIN SERVICES & BOOKING REQUESTS MANAGEMENT ENDPOINTS ---

@app.get("/api/v1/admin/services", response_model=Dict[str, Any])
def admin_get_services_list(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
    services = crud.admin_get_services(db)
    services_data = [schemas.ServiceResponse.model_validate(s).model_dump() for s in services]
    return {"status": "success", "data": services_data}

@app.post("/api/v1/admin/services", response_model=Dict[str, Any])
def admin_create_service(
    service: schemas.ServiceCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
    s = crud.create_service(db, service, current_user.id)
    return {"status": "success", "data": schemas.ServiceResponse.model_validate(s).model_dump()}

@app.put("/api/v1/admin/services/{service_id}", response_model=Dict[str, Any])
def admin_update_service(
    service_id: int,
    service: schemas.ServiceUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
    s = crud.update_service(db, service_id, service, current_user.id)
    if not s:
        raise HTTPException(status_code=404, detail="الخدمة غير موجودة")
    return {"status": "success", "data": schemas.ServiceResponse.model_validate(s).model_dump()}

@app.delete("/api/v1/admin/services/{service_id}", response_model=Dict[str, Any])
def admin_delete_service(
    service_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
    success = crud.delete_service(db, service_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="الخدمة غير موجودة")
    return {"status": "success", "message": "تم تعطيل الخدمة بنجاح"}

class ReorderBody(BaseModel):
    ids: List[int]

@app.put("/api/v1/admin/services/reorder", response_model=Dict[str, Any])
def admin_reorder_services(
    body: ReorderBody,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
    crud.reorder_services(db, body.ids, current_user.id)
    return {"status": "success", "message": "تم إعادة ترتيب الخدمات بنجاح"}

@app.post("/api/v1/admin/upload/service-image")
async def admin_upload_service_image(
    request: Request,
    image: UploadFile = File(...),
    type: str = Form("main"),  # main | gallery
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    if image.content_type not in ["image/jpeg", "image/png", "image/webp"]:
        raise HTTPException(status_code=400, detail="نوع الملف غير مدعوم. المسموح: JPG, PNG, WebP")
        
    image_bytes = await image.read()
    
    os.makedirs("static/uploads", exist_ok=True)
    clean_name = "".join(c for c in image.filename if c.isalnum() or c in "._-").strip()
    filename = f"{int(datetime.datetime.utcnow().timestamp())}_{clean_name}"
    file_path = os.path.join("static/uploads", filename)
    
    try:
        from PIL import Image as PILImage
        import io
        img = PILImage.open(io.BytesIO(image_bytes))
        
        if type == "main":
            target_w, target_h = 800, 600
        else:
            target_w, target_h = 1200, 800
            
        img = img.resize((target_w, target_h), PILImage.Resampling.LANCZOS if hasattr(PILImage, "Resampling") else PILImage.ANTIALIAS)
        img.save(file_path, format="JPEG", quality=85)
        width, height = target_w, target_h
    except Exception as e:
        print(f"PIL compression failed, using fallback raw save: {e}")
        with open(file_path, "wb") as buffer:
            buffer.write(image_bytes)
        width, height = 800, 600

    base_url = str(request.base_url).rstrip("/")
    url = f"{base_url}/static/uploads/{filename}"
    return {"url": url, "width": width, "height": height}

@app.get("/api/v1/admin/service-requests", response_model=Dict[str, Any])
def admin_get_service_requests(
    status: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    date_from: Optional[str] = Query(None),
    date_to: Optional[str] = Query(None),
    service_id: Optional[int] = Query(None),
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1),
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    skip = (page - 1) * per_page
    requests_list, total_count, stats = crud.get_admin_service_requests(
        db, status=status, search=search, date_from=date_from, date_to=date_to,
        service_id=service_id, skip=skip, limit=per_page
    )
    reqs_data = [schemas.ServiceRequestResponse.model_validate(r).model_dump() for r in requests_list]
    return {
        "success": True,
        "data": reqs_data,
        "meta": {
            "total": total_count,
            "page": page,
            "per_page": per_page,
            "stats": stats
        }
    }

@app.get("/api/v1/admin/service-requests/{request_id}", response_model=Dict[str, Any])
def admin_get_service_request_detail(
    request_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    req = crud.get_service_request(db, request_id)
    if not req:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    return {"success": True, "data": schemas.ServiceRequestResponse.model_validate(req).model_dump()}

class AdminRequestStatusUpdate(BaseModel):
    status: str
    note: Optional[str] = None
    assigned_worker: Optional[str] = None
    worker_phone: Optional[str] = None
    notify_customer: bool = False

@app.put("/api/v1/admin/service-requests/{request_id}/status", response_model=Dict[str, Any])
def admin_update_service_request_status(
    request_id: int,
    body: AdminRequestStatusUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    req = crud.update_service_request_status(
        db, request_id, status=body.status, note=body.note,
        assigned_worker=body.assigned_worker, worker_phone=body.worker_phone,
        notify_customer=body.notify_customer, user_id=current_user.id
    )
    if not req:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
    return {"success": True, "data": schemas.ServiceRequestResponse.model_validate(req).model_dump()}

@app.get("/api/v1/admin/service-requests/{request_id}/print-data", response_model=Dict[str, Any])
def admin_get_service_request_print_data(
    request_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
        
    req = crud.get_service_request(db, request_id)
    if not req:
        raise HTTPException(status_code=404, detail="الطلب غير موجود")
        
    # Fetch dynamic system settings
    settings = crud.get_all_system_settings(db)
    settings_dict = {s.key: s.value for s in settings}
    store_name_val = settings_dict.get("store_name", {"ar": "نوزل", "en": "Nozzle"})
    store_phone_val = settings_dict.get("store_phone", "+9647700000000")
    store_email_val = settings_dict.get("store_email", "support@nozzle.com")
    store_address_val = settings_dict.get("store_address", {"ar": "العراق، بغداد", "en": "Baghdad, Iraq"})
    invoice_logo_val = settings_dict.get("invoice_logo", "")
        
    return {
        "success": True,
        "data": {
            "request_number": req.request_number,
            "created_at": req.created_at.strftime("%Y/%m/%d %H:%M") if req.created_at else "",
            "customer_name": req.customer_name,
            "customer_phone": req.customer_phone,
            "address": req.address,
            "service_name": req.service.name if req.service else "",
            "option_name": req.option.name if req.option else None,
            "option_price": req.option.extra_price if req.option else 0.0,
            "scheduled_date": req.scheduled_date,
            "scheduled_time": req.scheduled_time,
            "duration_minutes": (req.service.duration_minutes if req.service else 60) + (req.option.duration_extra_minutes if req.option else 0),
            "assigned_worker": req.assigned_worker,
            "worker_phone": req.worker_phone,
            "base_price": req.service.base_price if req.service else 0.0,
            "total_price": req.total_price,
            "payment_method": req.payment_method,
            "payment_status": req.payment_status,
            "notes": req.notes,
            "status": req.status,
            "settings": {
                "store_name": store_name_val,
                "store_phone": store_phone_val,
                "store_email": store_email_val,
                "store_address": store_address_val,
                "invoice_logo": invoice_logo_val
            }
        }
    }

@app.get("/api/v1/admin/services/stats", response_model=Dict[str, Any])
def admin_get_services_stats(
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    if current_user.role not in ["admin", "superadmin", "manager"]:
        raise HTTPException(status_code=403, detail="غير مصرح لك بالوصول")
    stats = crud.get_services_stats(db)
    return {"success": True, "data": stats}



# ─── PRODUCT TAG ENDPOINTS ─────────────────────────────────────────────

def format_product_tag_data(tag):
    return {
        "id": tag.id,
        "name": tag.name,
        "subcategory_id": tag.subcategory_id,
        "parent_id": tag.parent_id,
        "image_url": tag.image_url,
        "icon_emoji": tag.icon_emoji,
        "sort_order": tag.sort_order,
        "is_active": tag.is_active,
        "products_count": len(tag.products),
        "product_ids": [p.id for p in tag.products],
        "sub_tags": [format_product_tag_data(child) for child in tag.sub_tags] if tag.sub_tags else []
    }

@app.get("/api/v1/product-tags")
def get_product_tags(
    subcategory_id: Optional[int] = None,
    parent_id: Optional[int] = None,
    is_active: Optional[bool] = None,
    top_level_only: bool = False,
    db: Session = Depends(get_db)
):
    tags = crud.get_product_tags(
        db, 
        subcategory_id=subcategory_id, 
        parent_id=parent_id, 
        is_active=is_active, 
        top_level_only=top_level_only
    )
    
    formatted_tags = [format_product_tag_data(tag) for tag in tags]
    return {"success": True, "status": "success", "data": formatted_tags}


@app.get("/api/v1/product-tags/{tag_id}")
def get_product_tag(
    tag_id: int,
    db: Session = Depends(get_db)
):
    tag = crud.get_product_tag(db, tag_id=tag_id)
    if not tag:
        raise HTTPException(status_code=404, detail="Product tag not found")
        
    return {
        "success": True,
        "status": "success",
        "data": format_product_tag_data(tag)
    }


@app.post("/api/v1/product-tags", response_model=Dict[str, Any])
def create_product_tag(
    tag: schemas.ProductTagCreate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db_tag = crud.create_product_tag(db, tag=tag, user_id=current_user.id)
    return {
        "success": True,
        "message": "تم إنشاء التصنيف بنجاح",
        "data": {
            "id": db_tag.id,
            "name": db_tag.name,
            "subcategory_id": db_tag.subcategory_id,
            "image_url": db_tag.image_url,
            "icon_emoji": db_tag.icon_emoji,
            "sort_order": db_tag.sort_order,
            "is_active": db_tag.is_active,
            "products_count": len(db_tag.products),
            "product_ids": [p.id for p in db_tag.products]
        }
    }


@app.put("/api/v1/product-tags/{tag_id}", response_model=Dict[str, Any])
def update_product_tag(
    tag_id: int,
    tag_update: schemas.ProductTagUpdate,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    db_tag = crud.update_product_tag(db, tag_id=tag_id, tag_update=tag_update, user_id=current_user.id)
    if not db_tag:
        raise HTTPException(status_code=404, detail="Product tag not found")
        
    return {
        "success": True,
        "message": "تم تعديل التصنيف بنجاح",
        "data": {
            "id": db_tag.id,
            "name": db_tag.name,
            "subcategory_id": db_tag.subcategory_id,
            "image_url": db_tag.image_url,
            "icon_emoji": db_tag.icon_emoji,
            "sort_order": db_tag.sort_order,
            "is_active": db_tag.is_active,
            "products_count": len(db_tag.products),
            "product_ids": [p.id for p in db_tag.products]
        }
    }


@app.delete("/api/v1/product-tags/{tag_id}")
def delete_product_tag(
    tag_id: int,
    current_user: models.User = Depends(auth.get_current_user),
    db: Session = Depends(get_db)
):
    success = crud.delete_product_tag(db, tag_id=tag_id, user_id=current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Product tag not found")
        
    return {"success": True, "message": "تم حذف التصنيف بنجاح"}





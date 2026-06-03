import datetime
from sqlalchemy.orm import Session
from database import engine, Base, SessionLocal
import models
import auth

def seed_db():
    print("Recreating database tables...")
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    db: Session = SessionLocal()
    
    try:
        print("Seeding admin users...")
        # Super Admin
        super_admin = models.User(
            email="superadmin@nozzle.com",
            hashed_password=auth.get_password_hash("admin123"),
            full_name="المدير العام",
            role="superadmin",
            is_active=True
        )
        # Normal Admin
        normal_admin = models.User(
            email="admin@nozzle.com",
            hashed_password=auth.get_password_hash("admin123"),
            full_name="مدير العمليات",
            role="admin",
            is_active=True
        )
        db.add(super_admin)
        db.add(normal_admin)
        db.commit()
        db.refresh(super_admin)
        db.refresh(normal_admin)
        
        print("Seeding categories...")
        cat_oils = models.Category(name="زيوت محركات", description="زيوت محركات تخليقية ومعدنية للسيارات والدراجات النارية")
        cat_filters = models.Category(name="فلاتر", description="فلاتر زيت وهواء وتكييف")
        cat_care = models.Category(name="عناية بالسيارة", description="منظفات وملمعات وأدوات الغسيل والتشحيم")
        cat_accs = models.Category(name="إكسسوارات وسوائل", description="سوائل فرامل ورادياتير وإكسسوارات عامة")
        db.add(cat_oils)
        db.add(cat_filters)
        db.add(cat_care)
        db.add(cat_accs)
        db.commit()
        db.refresh(cat_oils)
        db.refresh(cat_filters)
        db.refresh(cat_care)
        db.refresh(cat_accs)
        
        print("Seeding products...")
        products = [
            models.Product(
                name="موبيل 1 زيت تخليقي كامل 5W-30 (1 لتر)",
                description="زيت محرك متطور يوفر حماية فائقة للمحرك وتنظيف الأجزاء الداخلية",
                price=14.99,
                stock_quantity=150,
                category_id=cat_oils.id,
                image_url="https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=500&auto=format&fit=crop",
                features=["تنظيف ممتاز للأجزاء الداخلية", "حماية من التآكل والاحتكاك", "تحمل درجات الحرارة العالية"],
                specifications={"اللزوجة": "5W-30", "الحجم": "1 لتر", "النوع": "تخليقي كامل"},
                tags=["best_seller", "new_arrival"]
            ),
            models.Product(
                name="كاسترول إيدج زيت محرك 5W-40 (4 لتر)",
                description="زيت معزز بتقنية تيتانيوم السائل لأقصى قوة وأداء للمحرك",
                price=49.99,
                stock_quantity=80,
                category_id=cat_oils.id,
                image_url="https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=500&auto=format&fit=crop",
                features=["تقنية تيتانيوم السائل لقوة المحرك", "تقليل الاحتكاك حتى 20%", "موصى به من قبل مصنعي السيارات الفاخرة"],
                specifications={"اللزوجة": "5W-40", "الحجم": "4 لتر", "النوع": "تخليقي بالكامل"},
                tags=["best_seller", "special_offer"]
            ),
            models.Product(
                name="فلتر زيت فرام PH7317",
                description="فلتر زيت عالي الكفاءة ومصمم لتصفية الشوائب الدقيقة وحماية المحرك",
                price=7.50,
                stock_quantity=200,
                category_id=cat_filters.id,
                image_url="https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500&auto=format&fit=crop",
                features=["كفاءة تصفية تصل إلى 99%", "هيكل معدني قوي مقاوم للضغط", "صمام أمان لمنع الارتجاع"],
                specifications={"النوع": "فلتر زيت معدني", "التوافق": "محركات يابانية وكورية"},
                tags=["new_arrival"]
            ),
            models.Product(
                name="شامبو ملمع ميجوايرز للغسيل والواكس",
                description="منظف رغوي فائق يزيل الأوساخ برفق ويترك طبقة حماية شمعية لامعة",
                price=19.99,
                stock_quantity=45,
                category_id=cat_care.id,
                image_url="https://images.unsplash.com/photo-1607860108855-64acf2078ed9?w=500&auto=format&fit=crop",
                features=["تنظيف عميق ولمعان شمعي في خطوة واحدة", "رغوة كثيفة لتقليل خدش الطلاء", "آمن على جميع أنواع طلاء السيارات"],
                specifications={"الحجم": "1.42 لتر", "النوع": "شامبو وواكس"},
                tags=["special_offer"]
            ),
            models.Product(
                name="سائل فرامل تويوتا دوت 4 (0.5 لتر)",
                description="سائل فرامل ذو نقطة غليان عالية لتوفير استجابة سريعة للفرملة",
                price=12.00,
                stock_quantity=120,
                category_id=cat_accs.id,
                image_url="https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=500&auto=format&fit=crop",
                features=["درجة غليان جافة تتجاوز 230 مئوية", "حماية فائقة من التآكل والصدأ لمكونات المكابح", "أداء مستقر في أقسى ظروف القيادة"],
                specifications={"النوع": "DOT 4", "الحجم": "500 مل"},
                tags=[]
            ),
        ]
        
        for p in products:
            db.add(p)
        db.commit()
        
        # Reload products to get IDs
        prod_mobil = db.query(models.Product).filter(models.Product.name.like("موبيل 1%")).first()
        prod_castrol = db.query(models.Product).filter(models.Product.name.like("كاسترول%")).first()
        prod_fram = db.query(models.Product).filter(models.Product.name.like("فلتر زيت%")).first()
        
        print("Seeding orders and audit logs...")
        
        # Order 1: Completed
        o1 = models.Order(
            customer_name="أحمد العتيبي",
            customer_email="ahmed@example.com",
            total_amount=37.48,
            status="completed",
            created_at=datetime.datetime.utcnow() - datetime.timedelta(days=10)
        )
        db.add(o1)
        db.commit()
        db.refresh(o1)
        
        db.add(models.OrderItem(order_id=o1.id, product_id=prod_mobil.id, quantity=2, price=14.99))
        db.add(models.OrderItem(order_id=o1.id, product_id=prod_fram.id, quantity=1, price=7.50))
        
        # Order 2: Completed
        o2 = models.Order(
            customer_name="خالد الدوسري",
            customer_email="khaled@example.com",
            total_amount=99.98,
            status="completed",
            created_at=datetime.datetime.utcnow() - datetime.timedelta(days=5)
        )
        db.add(o2)
        db.commit()
        db.refresh(o2)
        
        db.add(models.OrderItem(order_id=o2.id, product_id=prod_castrol.id, quantity=2, price=49.99))
        
        # Order 3: Pending
        o3 = models.Order(
            customer_name="سارة المطيري",
            customer_email="sara@example.com",
            total_amount=22.49,
            status="pending",
            created_at=datetime.datetime.utcnow() - datetime.timedelta(hours=6)
        )
        db.add(o3)
        db.commit()
        db.refresh(o3)
        
        db.add(models.OrderItem(order_id=o3.id, product_id=prod_mobil.id, quantity=1, price=14.99))
        db.add(models.OrderItem(order_id=o3.id, product_id=prod_fram.id, quantity=1, price=7.50))
        
        # Order 4: Processing
        o4 = models.Order(
            customer_name="محمد العمري",
            customer_email="mohammed@example.com",
            total_amount=19.99,
            status="processing",
            created_at=datetime.datetime.utcnow() - datetime.timedelta(days=1)
        )
        db.add(o4)
        db.commit()
        db.refresh(o4)
        
        prod_soap = db.query(models.Product).filter(models.Product.name.like("شامبو ملمع%")).first()
        db.add(models.OrderItem(order_id=o4.id, product_id=prod_soap.id, quantity=1, price=19.99))
        
        # Commit all items
        db.commit()
        
        # Add some audit logs
        db.add(models.AuditLog(user_id=super_admin.id, action="SYSTEM_INIT", details="System initialized and seeded successfully"))
        db.add(models.AuditLog(user_id=super_admin.id, action="CREATE_USER", details="Seeded administrative users"))
        
        # Add initial settings
        initial_settings = [
            models.SystemSetting(key="store_name", value={"ar": "نوزل برو", "en": "Nozzle Pro"}),
            models.SystemSetting(key="store_email", value="support@nozzle.com"),
            models.SystemSetting(key="store_phone", value="+966500000000"),
            models.SystemSetting(key="tax_rate", value=15.0),
            models.SystemSetting(key="shipping_fee", value=15.0),
            models.SystemSetting(key="free_shipping_threshold", value=150.0),
            models.SystemSetting(key="cod_enabled", value=True),
            models.SystemSetting(key="card_enabled", value=True)
        ]
        for s in initial_settings:
            db.add(s)
            
        db.commit()
        
        print("Database seeded successfully!")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_db()

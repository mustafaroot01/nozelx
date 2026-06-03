import os
import sqlite3
import datetime
from sqlalchemy.orm import Session
from database import engine, Base, SessionLocal
import models

def reset_services_tables():
    db_path = "admin_dashboard.db"
    if not os.path.exists(db_path):
        print(f"Database file not found at {db_path}")
        return

    print("Dropping old services and service_bookings tables if they exist...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    try:
        cursor.execute("DROP TABLE IF EXISTS service_request_status_history;")
        cursor.execute("DROP TABLE IF EXISTS service_requests;")
        cursor.execute("DROP TABLE IF EXISTS service_options;")
        cursor.execute("DROP TABLE IF EXISTS service_bookings;")
        cursor.execute("DROP TABLE IF EXISTS services;")
        conn.commit()
        print("Dropped tables successfully.")
    except Exception as e:
        conn.rollback()
        print(f"Failed to drop tables: {e}")
    finally:
        conn.close()

    print("Recreating services tables using SQLAlchemy models...")
    Base.metadata.create_all(bind=engine)
    print("Recreated tables successfully.")

    db: Session = SessionLocal()
    try:
        print("Seeding initial services and options...")
        # 1. AC Cleaning Service
        s1 = models.Service(
            name="تنظيف المكيفات",
            description="تنظيف احترافي لجميع أنواع المكيفات وغسل الفلاتر وإعادة التعبئة لغاز الفريون بالكامل مع فحص دقيق.",
            short_description="تنظيف احترافي لجميع أنواع المكيفات",
            image_url="/static/uploads/seed_ac_cleaning.jpg",
            gallery_urls=["/static/uploads/seed_ac_cleaning.jpg"],
            icon_emoji="❄️",
            base_price=15000.0,
            price_type="from",
            category="تنظيف",
            tags=["featured", "best_seller"],
            duration_minutes=120,
            is_available=True,
            is_featured=True,
            sort_order=1,
            rating=4.8,
            reviews_count=120,
            working_hours={"sat": "08:00-20:00", "sun": "08:00-20:00", "mon": "08:00-20:00", "tue": "08:00-20:00", "wed": "08:00-20:00", "thu": "08:00-20:00", "fri": "14:00-20:00"},
            max_bookings_per_day=8,
            advance_booking_days=30
        )
        db.add(s1)
        db.commit()
        db.refresh(s1)

        opt1 = models.ServiceOption(
            service_id=s1.id,
            name="خدمة عاجلة",
            description="خلال ساعتين",
            extra_price=5000.0,
            duration_extra_minutes=0,
            sort_order=1,
            is_active=True
        )
        opt2 = models.ServiceOption(
            service_id=s1.id,
            name="تنظيف عميق للمنزل بالكامل",
            description="شامل غسيل القطع الخارجية والداخلية والمعاينة الفنية",
            extra_price=8000.0,
            duration_extra_minutes=30,
            sort_order=2,
            is_active=True
        )
        db.add(opt1)
        db.add(opt2)

        # 2. Mobile Car Wash
        s2 = models.Service(
            name="غسيل سيارات متنقل",
            description="غسيل سيارات متنقل يأتي إليك أينما كنت. يشمل تنظيف داخلي وخارجي وتلميع الإطارات وتعطير السيارة بالكامل بأجود المواد.",
            short_description="غسيل سيارات متنقل عند باب بيتك",
            image_url="/static/uploads/seed_car_wash.jpg",
            gallery_urls=["/static/uploads/seed_car_wash.jpg"],
            icon_emoji="🚿",
            base_price=10000.0,
            price_type="fixed",
            category="تنظيف",
            tags=["featured"],
            duration_minutes=60,
            is_available=True,
            is_featured=True,
            sort_order=2,
            rating=4.7,
            reviews_count=98,
            working_hours={"sat": "08:00-20:00", "sun": "08:00-20:00", "mon": "08:00-20:00", "tue": "08:00-20:00", "wed": "08:00-20:00", "thu": "08:00-20:00", "fri": "08:00-20:00"},
            max_bookings_per_day=15,
            advance_booking_days=30
        )
        db.add(s2)
        db.commit()
        db.refresh(s2)

        opt3 = models.ServiceOption(
            service_id=s2.id,
            name="تلميع واكس نانو",
            description="إضافة طبقة شمع حماية ولمعان لهيكل السيارة",
            extra_price=3000.0,
            duration_extra_minutes=15,
            sort_order=1,
            is_active=True
        )
        opt4 = models.ServiceOption(
            service_id=s2.id,
            name="تنظيف عميق للمقاعد بالبخار",
            description="تنظيف وتطهير المقاعد وإزالة البقع المستعصية",
            extra_price=12000.0,
            duration_extra_minutes=45,
            sort_order=2,
            is_active=True
        )
        db.add(opt3)
        db.add(opt4)

        # 3. Oil & Filter Change
        s3 = models.Service(
            name="تبديل زيت وفلتر",
            description="تبديل زيت المحرك والفلتر بأيدي متخصصين مع فحص السوائل الأخرى وضغط الإطارات مجاناً.",
            short_description="تبديل زيت المحرك مع فلتر أصلي",
            image_url="/static/uploads/seed_oil_change.jpg",
            gallery_urls=["/static/uploads/seed_oil_change.jpg"],
            icon_emoji="🛢️",
            base_price=25000.0,
            price_type="from",
            category="صيانة",
            tags=["featured"],
            duration_minutes=45,
            is_available=True,
            is_featured=True,
            sort_order=3,
            rating=4.9,
            reviews_count=145,
            working_hours={"sat": "08:00-22:00", "sun": "08:00-22:00", "mon": "08:00-22:00", "tue": "08:00-22:00", "wed": "08:00-22:00", "thu": "08:00-22:00", "fri": "14:00-22:00"},
            max_bookings_per_day=20,
            advance_booking_days=30
        )
        db.add(s3)
        db.commit()
        db.refresh(s3)

        opt5 = models.ServiceOption(
            service_id=s3.id,
            name="فلتر هواء محرك أصلي",
            description="تبديل فلتر الهواء بفلتر أصلي جديد لتحسين كفاءة الاحتراق والوقود",
            extra_price=7000.0,
            duration_extra_minutes=10,
            sort_order=1,
            is_active=True
        )
        opt6 = models.ServiceOption(
            service_id=s3.id,
            name="تنظيف وتصفية البواجي",
            description="فحص شمعات الاحتراق وتنظيفها أو استبدالها",
            extra_price=5000.0,
            duration_extra_minutes=15,
            sort_order=2,
            is_active=True
        )
        db.add(opt5)
        db.add(opt6)

        db.commit()
        print("Seeded database services successfully!")
    except Exception as e:
        db.rollback()
        print(f"Failed to seed services: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    reset_services_tables()

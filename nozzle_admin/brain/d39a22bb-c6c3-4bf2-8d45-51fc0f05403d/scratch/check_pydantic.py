import sys
sys.path.append("/Users/ahmdfars/Desktop/nozzleapp/nozzle_admin/backend")

from database import SessionLocal
import main
import models
import schemas

db = SessionLocal()
try:
    # 1. Create a dummy admin user
    admin_user = db.query(models.User).filter(models.User.role == "admin").first()
    if not admin_user:
        print("Creating mock admin user...")
        admin_user = models.User(
            phone="07812345678",
            full_name="المشرف",
            role="admin",
            is_active=True
        )
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)

    print(f"Using Admin User: {admin_user.full_name} ({admin_user.role})")
    
    # 2. Test admin_get_services_list
    print("\n--- Testing admin_get_services_list ---")
    res = main.admin_get_services_list(current_user=admin_user, db=db)
    print("Success! Return status:", res.keys())
    print("Number of services:", len(res["data"]))
    if len(res["data"]) > 0:
        print("First service keys:", res["data"][0].keys())
        print("First service options:", res["data"][0]["options"])

    # 3. Test get_inventory_dashboard
    print("\n--- Testing get_inventory_dashboard ---")
    dashboard_res = main.get_inventory_dashboard(current_user=admin_user, db=db)
    print("Success! Dashboard response status:", dashboard_res["status"])
    print("Dashboard product count:", dashboard_res["data"]["total_products"])
    print("Dashboard recent movements:", len(dashboard_res["data"]["recent_movements"]))

    # 4. Test admin_get_service_requests
    print("\n--- Testing admin_get_service_requests ---")
    reqs_res = main.admin_get_service_requests(
        current_user=admin_user, db=db, page=1, per_page=20,
        status=None, search=None, date_from=None, date_to=None, service_id=None
    )
    print("Success! Return status:", reqs_res.keys())
    print("Number of bookings:", len(reqs_res["data"]))
    if len(reqs_res["data"]) > 0:
        print("First booking keys:", reqs_res["data"][0].keys())
        print("First booking status:", reqs_res["data"][0]["status"])
        print("First booking service name:", reqs_res["data"][0]["service"]["name"] if reqs_res["data"][0]["service"] else "None")

except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()

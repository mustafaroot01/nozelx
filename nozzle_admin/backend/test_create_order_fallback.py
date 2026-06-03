import json
import urllib.request
import urllib.error

BASE_URL = "http://localhost:8080/api"

def test_create_order_fallback():
    order_payload = {
        "customer_name": "احمد فارس",
        "customer_phone": "07813548764",
        "customer_address": "المثنى - تقاطع باني",
        "payment_method": "cash",
        "total_amount": 21049.99,
        "user_id": 999, # User ID 999 does not exist, should fallback to user ID 3 (phone 07813548764)
        "items": [
            {
                "product_id": 4,
                "quantity": 1,
                "price": 19.99
            }
        ]
    }
    
    req = urllib.request.Request(
        f"{BASE_URL}/orders",
        data=json.dumps(order_payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            status = response.getcode()
            body = response.read().decode("utf-8")
            print(f"Status: {status}")
            res = json.loads(body)
            order = res.get("data", {})
            print("Successfully Created Order:")
            print(f"  Order ID: {order.get('id')}")
            print(f"  Resolved User ID: {order.get('user_id')} (Expected: 3)")
    except urllib.error.HTTPError as e:
        status = e.code
        body = e.read().decode("utf-8")
        print(f"Failed (HTTP {status}): {body}")
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    test_create_order_fallback()

import requests

def test_endpoints():
    url = "http://127.0.0.1:8080/api/v1/admin/users"
    print(f"Testing GET {url}...")
    try:
        r = requests.get(url)
        print(f"Status: {r.status_code}")
        print(f"JSON: {r.json()}")
        
        # Test detail endpoint
        detail_url = "http://127.0.0.1:8080/api/v1/admin/users/4"
        print(f"Testing GET {detail_url}...")
        r_detail = requests.get(detail_url)
        print(f"Status: {r_detail.status_code}")
        print(f"Detail JSON: {r_detail.json()}")
    except Exception as e:
        print(f"Failed: {e}")

if __name__ == "__main__":
    test_endpoints()

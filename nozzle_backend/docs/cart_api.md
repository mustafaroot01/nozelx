# Cart (Basket) API Documentation

## Overview
The cart API supports both `/cart` and `/basket` endpoints interchangeably. It also supports `session_key` and `session_id` parameters to bypass WAF blocking.

**Base URL:** `https://nozzlecenter.center/api/v1/`

**Authentication:** Bearer Token (JWT) or Session Key for guest users

---

## Endpoints

### 1. Get Cart Contents

Retrieve the current user's or guest's shopping cart.

```http
GET /basket
# or
GET /cart
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_key` | string | Optional | Guest session identifier (alternative to `session_id`) |
| `session_id` | string | Optional | Guest session identifier |

**Headers:**
```http
Authorization: Bearer <JWT_TOKEN>
```

**Example Request:**
```bash
curl -X GET "https://nozzlecenter.center/api/v1/basket?session_key=abc123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "product_id": 1,
        "quantity": 2,
        "options": {},
        "created_at": "2026-06-15T00:00:00+00:00",
        "product": {
          "id": 1,
          "name": "Product Name",
          "price": 13000.00,
          "sale_price": null,
          "image_url": "https://nozzlecenter.center/...",
          "stock": 100,
          "stock_quantity": 100,
          "stock_status": "in_stock",
          "is_available": true,
          "in_stock": true,
          "quantity": 100
        }
      }
    ],
    "summary": {
      "subtotal": 26000.00,
      "vat": 3900.00,
      "shipping_fee": 0.00,
      "total": 29900.00
    }
  }
}
```

---

### 2. Add Product to Cart

Add a product to the shopping cart.

```http
POST /basket/add
# or
POST /cart/add
```

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `product_id` | integer | Yes | Product ID |
| `quantity` | integer | Yes | Quantity (min: 1) |
| `session_key` | string | Optional | Guest session key (alternative to `session_id`) |
| `session_id` | string | Optional | Guest session ID |
| `options` | object | Optional | Product options (size, color, etc.) |

**Example Request:**
```bash
curl -X POST "https://nozzlecenter.center/api/v1/basket/add" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "product_id": 1,
    "quantity": 1,
    "session_key": "guest_session_abc123",
    "options": {
      "size": "L",
      "color": "red"
    }
  }'
```

**Example Response (200 OK):**
```json
{
  "success": true,
  "message": "تم إضافة المنتج للسلة بنجاح",
  "data": {
    "id": 6,
    "product_id": 1,
    "quantity": 1
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "detail": "الرجاء تسجيل الدخول أو توفير معرف الجلسة"
}
```

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "detail": "المنتج غير موجود"
}
```

**Error Response (400 - Out of Stock):**
```json
{
  "success": false,
  "detail": "الكمية المطلوبة تتجاوز المخزون المتوفر"
}
```

---

### 3. Update Cart Item Quantity

Update the quantity of an item in the cart.

```http
PUT /basket/update
# or
PUT /cart/update
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `item_id` | integer | Yes | Cart item ID (query or body) |
| `quantity` | integer | Yes | New quantity (min: 1) |

**Example Request:**
```bash
curl -X PUT "https://nozzlecenter.center/api/v1/basket/update?item_id=1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "quantity": 3
  }'
```

**Example Response (200 OK):**
```json
{
  "success": true,
  "message": "تم تحديث الكمية بالسلة",
  "data": {
    "id": 1,
    "quantity": 3
  }
}
```

---

### 4. Remove Item from Cart

Remove a specific item from the cart.

```http
DELETE /basket/remove/{item_id}
# or
DELETE /cart/remove/{item_id}
```

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `item_id` | integer | Yes | Cart item ID |

**Example Request:**
```bash
curl -X DELETE "https://nozzlecenter.center/api/v1/basket/remove/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response (200 OK):**
```json
{
  "success": true,
  "message": "تم حذف المنتج من السلة بنجاح"
}
```

---

### 5. Clear Cart

Remove all items from the cart.

```http
POST /basket/clear
# or
POST /cart/clear
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `session_key` | string | Optional | Guest session key (alternative to `session_id`) |
| `session_id` | string | Optional | Guest session ID |

**Example Request:**
```bash
curl -X POST "https://nozzlecenter.center/api/v1/basket/clear" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "session_key": "guest_session_abc123"
  }'
```

**Example Response (200 OK):**
```json
{
  "success": true,
  "message": "تم تفريغ السلة بنجاح"
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "detail": "الرجاء تسجيل الدخول أو توفير معرف الجلسة"
}
```

---

## Authentication

### Logged-in Users
Provide a valid JWT token in the `Authorization` header:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Guest Users
Use either `session_key` or `session_id` parameter in requests. The cart will be associated with this session identifier.

---

## Alternative Endpoints (Profile Cart)

These endpoints mirror the basket functionality:

| Basket Endpoint | Profile Cart Equivalent |
|----------------|-------------------------|
| `GET /basket` | `GET /profile/basket` |
| `GET /cart` | `GET /profile/cart` |
| `POST /basket/add` | `POST /profile/basket/add` |
| `POST /cart/add` | `POST /profile/cart/add` |
| `PUT /basket/update` | `PUT /profile/basket/update` |
| `PUT /cart/update` | `PUT /profile/cart/update` |
| `DELETE /basket/remove/{id}` | `DELETE /profile/basket/remove/{id}` |
| `DELETE /cart/remove/{id}` | `DELETE /profile/cart/remove/{id}` |

---

## WAF Compatibility Notes

To bypass server WAF blocking:
- Use `/basket` instead of `/cart`
- Use `session_key` instead of `session_id`

Both old and new parameter names are supported for backward compatibility.

---

## Data Models

### Cart Item
| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Cart item ID |
| `product_id` | integer | Product ID |
| `quantity` | integer | Quantity |
| `options` | object | Selected options (size, color) |
| `created_at` | string | ISO 8601 timestamp |
| `product` | object | Full product details |

### Cart Summary
| Field | Type | Description |
|-------|------|-------------|
| `subtotal` | float | Sum of item prices |
| `vat` | float | Tax amount (default 15%) |
| `shipping_fee` | float | Shipping cost (free above threshold) |
| `total` | float | Final total |

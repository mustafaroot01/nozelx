-- ══ جدول المستخدمين ══════════════════════════════
CREATE TABLE users (
  id              SERIAL PRIMARY KEY,
  phone           VARCHAR(20) UNIQUE NOT NULL,
  name            VARCHAR(255) NOT NULL,
  avatar_url      VARCHAR(500),
  total_orders    INT DEFAULT 0,
  total_spent     DECIMAL(14,2) DEFAULT 0,
  is_active       BOOLEAN DEFAULT true,
  last_login_at   TIMESTAMP,
  created_at      TIMESTAMP DEFAULT NOW(),
  updated_at      TIMESTAMP DEFAULT NOW()
);

-- ══ جدول الـ OTP ══════════════════════════════════
CREATE TABLE otp_codes (
  id          SERIAL PRIMARY KEY,
  phone       VARCHAR(20) NOT NULL,
  code        VARCHAR(6) NOT NULL,
  expires_at  TIMESTAMP NOT NULL,
  is_used     BOOLEAN DEFAULT false,
  attempts    INT DEFAULT 0,
  created_at  TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_otp_phone ON otp_codes(phone);

-- ══ جدول الجلسات (tokens) ═══════════════════════
CREATE TABLE user_sessions (
  id          SERIAL PRIMARY KEY,
  user_id     INT REFERENCES users(id) ON DELETE CASCADE,
  token       TEXT UNIQUE NOT NULL,
  device_name VARCHAR(255),
  device_os   VARCHAR(50),
  ip_address  VARCHAR(50),
  expires_at  TIMESTAMP NOT NULL,
  last_used   TIMESTAMP DEFAULT NOW(),
  created_at  TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_sessions_token ON user_sessions(token);
CREATE INDEX idx_sessions_user ON user_sessions(user_id);

-- ══ جدول المفضلة ══════════════════════════════════
CREATE TABLE favorites (
  id          SERIAL PRIMARY KEY,
  user_id     INT REFERENCES users(id) ON DELETE CASCADE,
  product_id  INT NOT NULL,
  created_at  TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);
CREATE INDEX idx_fav_user ON favorites(user_id);

-- ══ جدول السلة ════════════════════════════════════
CREATE TABLE cart_items (
  id              SERIAL PRIMARY KEY,
  user_id         INT REFERENCES users(id) ON DELETE CASCADE,
  product_id      INT NOT NULL,
  product_name    VARCHAR(255) NOT NULL,
  product_image   VARCHAR(500),
  price           DECIMAL(12,2) NOT NULL,
  quantity        INT NOT NULL DEFAULT 1,
  selected_size   VARCHAR(50),
  selected_color  VARCHAR(50),
  created_at      TIMESTAMP DEFAULT NOW(),
  updated_at      TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, product_id, selected_size, selected_color)
);
CREATE INDEX idx_cart_user ON cart_items(user_id);

-- ══ جدول الطلبات ══════════════════════════════════
CREATE TABLE orders (
  id               SERIAL PRIMARY KEY,
  order_number     VARCHAR(20) UNIQUE NOT NULL,
  user_id          INT REFERENCES users(id),
  status           VARCHAR(30) DEFAULT 'new',
  customer_name    VARCHAR(255) NOT NULL,
  customer_phone   VARCHAR(20) NOT NULL,
  address          TEXT NOT NULL,
  subtotal         DECIMAL(12,2) NOT NULL,
  delivery_fee     DECIMAL(12,2) DEFAULT 3000,
  coupon_code      VARCHAR(50),
  coupon_discount  DECIMAL(12,2) DEFAULT 0,
  total            DECIMAL(12,2) NOT NULL,
  payment_method   VARCHAR(20) DEFAULT 'cash',
  notes            TEXT,
  created_at       TIMESTAMP DEFAULT NOW(),
  updated_at       TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_orders_user ON orders(user_id);

-- ══ جدول عناصر الطلب ══════════════════════════════
CREATE TABLE order_items (
  id           SERIAL PRIMARY KEY,
  order_id     INT REFERENCES orders(id) ON DELETE CASCADE,
  product_id   INT NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  product_image VARCHAR(500),
  price        DECIMAL(12,2) NOT NULL,
  quantity     INT NOT NULL,
  selected_size  VARCHAR(50),
  selected_color VARCHAR(50)
);

-- ══ جدول طلبات الخدمات ════════════════════════════
CREATE TABLE service_requests (
  id               SERIAL PRIMARY KEY,
  request_number   VARCHAR(20) UNIQUE NOT NULL,
  user_id          INT REFERENCES users(id),
  service_id       INT NOT NULL,
  service_name     VARCHAR(255) NOT NULL,
  service_image    VARCHAR(500),
  option_name      VARCHAR(255),
  customer_name    VARCHAR(255) NOT NULL,
  customer_phone   VARCHAR(20) NOT NULL,
  address          TEXT NOT NULL,
  scheduled_at     TIMESTAMP NOT NULL,
  status           VARCHAR(30) DEFAULT 'new',
  total_price      DECIMAL(12,2) NOT NULL,
  notes            TEXT,
  created_at       TIMESTAMP DEFAULT NOW(),
  updated_at       TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_srv_req_user ON service_requests(user_id);

-- ══ جدول استخدام كوبونات المستخدم ══════════════════
CREATE TABLE user_coupon_usage (
  id          SERIAL PRIMARY KEY,
  user_id     INT REFERENCES users(id) ON DELETE CASCADE,
  coupon_id   INT NOT NULL,
  coupon_code VARCHAR(50) NOT NULL,
  order_id    INT REFERENCES orders(id),
  discount_amount DECIMAL(12,2) NOT NULL,
  used_at     TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_coupon_user ON user_coupon_usage(user_id);

-- ══ trigger تحديث إحصاءات المستخدم ════════════════
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users SET
    total_orders = (
      SELECT COUNT(*) FROM orders
      WHERE user_id = NEW.user_id
      AND status != 'cancelled'
    ),
    total_spent = (
      SELECT COALESCE(SUM(total), 0) FROM orders
      WHERE user_id = NEW.user_id
      AND status = 'completed'
    ),
    updated_at = NOW()
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_stats
AFTER INSERT OR UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_user_stats();

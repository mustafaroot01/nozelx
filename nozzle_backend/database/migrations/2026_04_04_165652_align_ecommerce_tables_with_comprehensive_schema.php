<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Brands Table
        Schema::create('brands', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('name_ar')->nullable();
            $table->string('slug')->unique();
            $table->string('logo')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // 2. Users Table Enhancements
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'phone')) {
                $table->string('phone')->unique()->nullable();
            }
            if (!Schema::hasColumn('users', 'avatar')) {
                $table->string('avatar')->nullable();
            }
            if (!Schema::hasColumn('users', 'is_active')) {
                $table->boolean('is_active')->default(true);
            }
        });

        // 3. User Addresses Table
        Schema::create('user_addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('label')->default('Home'); // Home, Work, etc.
            $table->string('full_name')->nullable();
            $table->string('phone')->nullable();
            $table->string('city')->nullable();
            $table->string('street_address')->nullable();
            $table->boolean('is_default')->default(false);
            $table->timestamps();
        });

        // 4. Coupons Table
        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->enum('type', ['fixed', 'percentage'])->default('percentage');
            $table->decimal('value', 10, 2);
            $table->decimal('min_cart_value', 10, 2)->nullable();
            $table->decimal('max_discount', 10, 2)->nullable();
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->integer('usage_limit')->nullable();
            $table->integer('used_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // 5. Categories Enhancements
        Schema::table('categories', function (Blueprint $table) {
            if (!Schema::hasColumn('categories', 'image')) {
                $table->string('image')->nullable();
            }
            if (!Schema::hasColumn('categories', 'description')) {
                $table->text('description')->nullable();
            }
            if (!Schema::hasColumn('categories', 'is_featured')) {
                $table->boolean('is_featured')->default(false);
            }
        });

        // 6. Products Enhancements
        Schema::table('products', function (Blueprint $table) {
            if (!Schema::hasColumn('products', 'sku')) {
                $table->string('sku')->nullable()->unique();
            }
            if (!Schema::hasColumn('products', 'barcode')) {
                $table->string('barcode')->nullable();
            }
            if (!Schema::hasColumn('products', 'brand_id')) {
                $table->foreignId('brand_id')->nullable()->constrained()->onDelete('set null');
            }
            if (!Schema::hasColumn('products', 'cost_price')) {
                $table->decimal('cost_price', 10, 2)->nullable();
            }
            if (!Schema::hasColumn('products', 'weight')) {
                $table->decimal('weight', 8, 2)->nullable(); // kg
            }
            if (!Schema::hasColumn('products', 'dimensions')) {
                $table->string('dimensions')->nullable(); // L x W x H
            }
            if (!Schema::hasColumn('products', 'status')) {
                $table->string('status')->default('draft'); // draft, published, out_of_stock
            }
            if (!Schema::hasColumn('products', 'views_count')) {
                $table->integer('views_count')->default(0);
            }
        });

        // 7. Orders Enhancements
        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'subtotal')) {
                $table->decimal('subtotal', 10, 2)->default(0);
            }
            if (!Schema::hasColumn('orders', 'tax_amount')) {
                $table->decimal('tax_amount', 10, 2)->default(0);
            }
            if (!Schema::hasColumn('orders', 'shipping_amount')) {
                $table->decimal('shipping_amount', 10, 2)->default(0);
            }
            if (!Schema::hasColumn('orders', 'discount_amount')) {
                $table->decimal('discount_amount', 10, 2)->default(0);
            }
            if (!Schema::hasColumn('orders', 'coupon_id')) {
                $table->foreignId('coupon_id')->nullable()->constrained('coupons')->onDelete('set null');
            }
            if (!Schema::hasColumn('orders', 'shipping_method')) {
                $table->string('shipping_method')->nullable();
            }
            if (!Schema::hasColumn('orders', 'tracking_number')) {
                $table->string('tracking_number')->nullable();
            }
            if (!Schema::hasColumn('orders', 'notes')) {
                $table->text('notes')->nullable();
            }
            if (!Schema::hasColumn('orders', 'payment_status')) {
                $table->string('payment_status')->default('unpaid'); // unpaid, paid, refunded
            }
        });

        // 8. Order Items Enhancements
        Schema::table('order_items', function (Blueprint $table) {
            if (!Schema::hasColumn('order_items', 'unit_price')) {
                $table->decimal('unit_price', 10, 2)->nullable();
            }
            if (!Schema::hasColumn('order_items', 'total_price')) {
                $table->decimal('total_price', 10, 2)->nullable();
            }
        });

        // 9. Product Reviews Table
        Schema::create('product_reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->tinyInteger('rating')->default(5); // 1-5
            $table->text('comment')->nullable();
            $table->string('status')->default('approved'); // pending, approved, rejected
            $table->timestamps();
        });

        // 10. Attributes and Variations
        Schema::create('attributes', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. Size, Color
            $table->string('name_ar')->nullable();
            $table->timestamps();
        });

        Schema::create('attribute_values', function (Blueprint $table) {
            $table->id();
            $table->foreignId('attribute_id')->constrained()->onDelete('cascade');
            $table->string('value'); // e.g. XL, Red
            $table->string('value_ar')->nullable();
            $table->timestamps();
        });

        Schema::create('product_variations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->string('sku')->nullable()->unique();
            $table->decimal('price', 10, 2)->nullable(); // Optional specific price for variation
            $table->integer('stock')->default(0);
            $table->string('image')->nullable();
            $table->timestamps();
        });

        Schema::create('attribute_value_product_variation', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_variation_id')->constrained('product_variations')->onDelete('cascade');
            $table->foreignId('attribute_value_id')->constrained()->onDelete('cascade');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        // For simplicity in a development environment, down might drop tables and columns,
        // but drop foreign keys first.
        Schema::dropIfExists('attribute_value_product_variation');
        Schema::dropIfExists('product_variations');
        Schema::dropIfExists('attribute_values');
        Schema::dropIfExists('attributes');
        Schema::dropIfExists('product_reviews');
        
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn(['unit_price', 'total_price']);
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['coupon_id']);
            $table->dropColumn([
                'subtotal', 'tax_amount', 'shipping_amount', 'discount_amount',
                'coupon_id', 'shipping_method', 'tracking_number', 'notes', 'payment_status'
            ]);
        });

        Schema::table('products', function (Blueprint $table) {
            $table->dropForeign(['brand_id']);
            $table->dropColumn(['sku', 'barcode', 'brand_id', 'cost_price', 'weight', 'dimensions', 'status', 'views_count']);
        });

        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn(['image', 'description', 'is_featured']);
        });

        Schema::dropIfExists('coupons');
        Schema::dropIfExists('user_addresses');
        
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'avatar', 'is_active']);
        });

        Schema::dropIfExists('brands');
    }
};

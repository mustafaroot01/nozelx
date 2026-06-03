<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'address')) {
                $table->string('address')->nullable();
            }
            if (!Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('customer');
            }
        });

        Schema::table('categories', function (Blueprint $table) {
            if (!Schema::hasColumn('categories', 'name_ar')) {
                $table->string('name_ar')->nullable();
            }
            if (!Schema::hasColumn('categories', 'slug')) {
                $table->string('slug')->nullable();
            }
            if (!Schema::hasColumn('categories', 'is_active')) {
                $table->boolean('is_active')->default(true);
            }
            if (!Schema::hasColumn('categories', 'sort_order')) {
                $table->integer('sort_order')->default(0);
            }
        });

        Schema::table('products', function (Blueprint $table) {
            if (!Schema::hasColumn('products', 'name_ar')) {
                $table->string('name_ar')->nullable();
            }
            if (!Schema::hasColumn('products', 'slug')) {
                $table->string('slug')->nullable();
            }
            if (!Schema::hasColumn('products', 'description_ar')) {
                $table->text('description_ar')->nullable();
            }
            if (!Schema::hasColumn('products', 'sale_price')) {
                $table->decimal('sale_price', 10, 2)->nullable();
            }
            if (!Schema::hasColumn('products', 'images')) {
                $table->json('images')->nullable();
            }
            if (!Schema::hasColumn('products', 'is_active')) {
                $table->boolean('is_active')->default(true);
            }
            if (!Schema::hasColumn('products', 'stock')) {
                $table->integer('stock')->default(0);
            }
        });

        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'shipping_address')) {
                $table->json('shipping_address')->nullable();
            }
        });

        Schema::table('banners', function (Blueprint $table) {
            if (!Schema::hasColumn('banners', 'link')) {
                $table->string('link')->nullable();
            }
            if (!Schema::hasColumn('banners', 'sort_order')) {
                $table->integer('sort_order')->default(0);
            }
        });
    }

    public function down(): void
    {
    }
};

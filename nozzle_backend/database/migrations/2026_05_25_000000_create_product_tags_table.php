<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('product_tags')) {
            Schema::create('product_tags', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->foreignId('subcategory_id')->constrained('categories')->onDelete('cascade');
                $table->string('image_url')->nullable();
                $table->string('icon_emoji')->nullable();
                $table->integer('sort_order')->default(0);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('product_tag_items')) {
            Schema::create('product_tag_items', function (Blueprint $table) {
                $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
                $table->foreignId('tag_id')->constrained('product_tags')->onDelete('cascade');
                $table->primary(['product_id', 'tag_id']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('product_tag_items');
        Schema::dropIfExists('product_tags');
    }
};

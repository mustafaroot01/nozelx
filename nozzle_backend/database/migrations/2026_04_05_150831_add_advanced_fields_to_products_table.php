<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->json('features')->nullable()->after('description_ar');
            $table->json('specifications')->nullable()->after('features');
            $table->string('home_section')->nullable()->after('is_featured'); // e.g., 'featured', 'best_seller', 'new_arrival'
            $table->integer('low_stock_threshold')->default(5)->after('quantity');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn(['features', 'specifications', 'home_section', 'low_stock_threshold']);
        });
    }
};

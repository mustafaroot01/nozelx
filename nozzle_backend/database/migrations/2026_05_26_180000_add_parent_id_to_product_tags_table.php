<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('product_tags', function (Blueprint $table) {
            if (!Schema::hasColumn('product_tags', 'parent_id')) {
                $table->unsignedBigInteger('parent_id')->nullable()->after('subcategory_id');
                $table->foreign('parent_id')->references('id')->on('product_tags')->onDelete('cascade');
            }
        });
    }

    public function down(): void
    {
        Schema::table('product_tags', function (Blueprint $table) {
            if (Schema::hasColumn('product_tags', 'parent_id')) {
                $table->dropForeign(['parent_id']);
                $table->dropColumn('parent_id');
            }
        });
    }
};

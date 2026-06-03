<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('banners', function (Blueprint $table) {
            if (!Schema::hasColumn('banners', 'subtitle')) {
                $table->string('subtitle')->nullable()->after('title');
            }
            if (!Schema::hasColumn('banners', 'link_url')) {
                $table->string('link_url')->nullable()->after('link_id');
            }
            if (!Schema::hasColumn('banners', 'order_index')) {
                $table->integer('order_index')->default(0)->after('is_active');
            }
        });
    }

    public function down(): void
    {
        Schema::table('banners', function (Blueprint $table) {
            $table->dropColumn(['subtitle', 'link_url', 'order_index']);
        });
    }
};

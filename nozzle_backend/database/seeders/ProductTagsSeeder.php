<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\ProductTag;
use App\Models\Product;
use Illuminate\Support\Facades\DB;

class ProductTagsSeeder extends Seeder
{
    public function run()
    {
        // 1. Create a subcategory under "Engine Oils" (Category ID: 1)
        $subCategory = Category::create([
            'parent_id' => 1,
            'name' => 'Synthetic Oils',
            'name_ar' => 'زيوت تخليقية',
            'slug' => 'synthetic-oils',
            'icon' => 'science',
            'color' => '#1E88E5',
            'is_active' => true,
        ]);

        $subCategoryId = $subCategory->id;

        // Associate some products with this new subcategory
        Product::whereIn('id', [1, 2, 3, 4])->update(['category_id' => $subCategoryId]);

        // Truncate tags just in case
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('product_tag_items')->truncate();
        ProductTag::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 2. Create Parent Tags (e.g. Viscosity, Brand/Company)
        $viscosityParent = ProductTag::create([
            'name' => 'اللزوجة',
            'subcategory_id' => $subCategoryId,
            'parent_id' => null,
            'icon_emoji' => '🧪',
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $companyParent = ProductTag::create([
            'name' => 'الشركة المصنعة',
            'subcategory_id' => $subCategoryId,
            'parent_id' => null,
            'icon_emoji' => '🏢',
            'is_active' => true,
            'sort_order' => 2,
        ]);

        // 3. Create Child Tags under "اللزوجة"
        $viscosity5w30 = ProductTag::create([
            'name' => '5W-30',
            'subcategory_id' => $subCategoryId,
            'parent_id' => $viscosityParent->id,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $viscosity10w40 = ProductTag::create([
            'name' => '10W-40',
            'subcategory_id' => $subCategoryId,
            'parent_id' => $viscosityParent->id,
            'is_active' => true,
            'sort_order' => 2,
        ]);

        $viscosity20w50 = ProductTag::create([
            'name' => '20W-50',
            'subcategory_id' => $subCategoryId,
            'parent_id' => $viscosityParent->id,
            'is_active' => true,
            'sort_order' => 3,
        ]);

        // 4. Create Child Tags under "الشركة المصنعة"
        $shellTag = ProductTag::create([
            'name' => 'شل (Shell)',
            'subcategory_id' => $subCategoryId,
            'parent_id' => $companyParent->id,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $castrolTag = ProductTag::create([
            'name' => 'كاسترول (Castrol)',
            'subcategory_id' => $subCategoryId,
            'parent_id' => $companyParent->id,
            'is_active' => true,
            'sort_order' => 2,
        ]);

        // 5. Associate products with child tags
        // Shell Helix Ultra 5W-40 (4L) -> 5W-30 (for testing) & Shell
        $p1 = Product::find(1);
        if ($p1) {
            $p1->tags()->sync([$viscosity5w30->id, $shellTag->id]);
        }

        // Castrol Magnatec 10W-40 (4L) -> 10W-40 & Castrol
        $p2 = Product::find(2);
        if ($p2) {
            $p2->tags()->sync([$viscosity10w40->id, $castrolTag->id]);
        }

        // Nozzle Premium 20W-50 (4L) -> 20W-50
        $p4 = Product::find(4);
        if ($p4) {
            $p4->tags()->sync([$viscosity20w50->id]);
        }

        echo "Seeding completed successfully!\n";
    }
}

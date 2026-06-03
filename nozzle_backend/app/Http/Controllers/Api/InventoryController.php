<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\StockMovement;
use App\Models\AuditLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InventoryController extends Controller
{
    /**
     * Get inventory dashboard statistics and alert lists.
     */
    public function index(Request $request)
    {
        $products = Product::where('is_deleted', false)->get();
        $totalProducts = $products->count();

        $outOfStock = 0;
        $lowStock = 0;
        $criticalStock = 0;
        $lowStockItems = [];

        foreach ($products as $p) {
            $stock = $p->stock_quantity ?? 0;
            $threshold = $p->low_stock_threshold ?? 10;
            $reorder = $p->reorder_point ?? 20;

            if ($stock <= 0) {
                $outOfStock++;
                $lowStockItems[] = [
                    "id" => $p->id,
                    "name" => $p->name,
                    "sku" => $p->sku,
                    "stock" => $stock,
                    "low_stock_threshold" => $threshold,
                    "reorder_point" => $reorder,
                    "max_stock" => $p->max_stock ?? 100,
                    "status" => "out_of_stock"
                ];
            } elseif ($stock <= $threshold) {
                $criticalStock++;
                $lowStockItems[] = [
                    "id" => $p->id,
                    "name" => $p->name,
                    "sku" => $p->sku,
                    "stock" => $stock,
                    "low_stock_threshold" => $threshold,
                    "reorder_point" => $reorder,
                    "max_stock" => $p->max_stock ?? 100,
                    "status" => "critical"
                ];
            } elseif ($stock <= $reorder) {
                $lowStock++;
                $lowStockItems[] = [
                    "id" => $p->id,
                    "name" => $p->name,
                    "sku" => $p->sku,
                    "stock" => $stock,
                    "low_stock_threshold" => $threshold,
                    "reorder_point" => $reorder,
                    "max_stock" => $p->max_stock ?? 100,
                    "status" => "low"
                ];
            }
        }

        $recentMovementsDb = StockMovement::with(['product', 'user'])
            ->orderBy('created_at', 'desc')
            ->limit(20)
            ->get();

        $recentMovements = [];
        foreach ($recentMovementsDb as $m) {
            $recentMovements[] = [
                "id" => $m->id,
                "product_id" => $m->product_id,
                "product_name" => $m->product ? $m->product->name : "منتج محذوف",
                "type" => $m->type,
                "quantity_change" => $m->quantity_change,
                "quantity_before" => $m->quantity_before,
                "quantity_after" => $m->quantity_after,
                "reason" => $m->reason,
                "invoice_number" => $m->invoice_number,
                "created_by" => $m->user ? ($m->user->name ?? $m->user->email) : "نظام",
                "created_at" => $m->created_at ? $m->created_at->toIso8601String() : null
            ];
        }

        return response()->json([
            "status" => "success",
            "data" => [
                "total_products" => $totalProducts,
                "out_of_stock_count" => $outOfStock,
                "critical_stock_count" => $criticalStock,
                "low_stock_count" => $lowStock,
                "low_stock_items" => $lowStockItems,
                "recent_movements" => $recentMovements
            ]
        ]);
    }

    /**
     * Create stock movement (update stock).
     */
    public function updateStock(Request $request)
    {
        $request->validate([
            'product_id' => 'required|integer',
            'type' => 'required|string|in:in,out,adjustment,audit',
            'quantity_change' => 'required|integer',
            'reason' => 'nullable|string',
            'invoice_number' => 'nullable|string'
        ]);

        $productId = $request->input('product_id');
        $type = $request->input('type');
        $quantityChange = $request->input('quantity_change');
        $reason = $request->input('reason');
        $invoiceNumber = $request->input('invoice_number');

        // Mocking user ID for now since we are implementing compatibility
        $userId = auth()->id() ?? 1;

        try {
            return DB::transaction(function () use ($productId, $type, $quantityChange, $reason, $invoiceNumber, $userId) {
                $product = Product::findOrFail($productId);
                $quantityBefore = $product->stock_quantity ?? 0;

                if ($type === "in") {
                    $quantityAfter = $quantityBefore + $quantityChange;
                } elseif ($type === "out") {
                    $quantityAfter = $quantityBefore - $quantityChange;
                    if ($quantityAfter < 0) {
                        return response()->json(['detail' => 'الكمية المطلوبة غير متوفرة في المخزون'], 400);
                    }
                } elseif (in_array($type, ["adjustment", "audit"])) {
                    $quantityAfter = $quantityChange;
                    $quantityChange = $quantityAfter - $quantityBefore;
                } else {
                    return response()->json(['detail' => 'نوع حركة المخزون غير صالح'], 400);
                }

                if ($quantityAfter < 0) {
                    return response()->json(['detail' => 'كمية المخزون بعد العملية لا يمكن أن تكون سالبة'], 400);
                }

                $product->stock_quantity = $quantityAfter;
                $product->save();

                $movement = StockMovement::create([
                    'product_id' => $productId,
                    'type' => $type,
                    'quantity_change' => $quantityChange,
                    'quantity_before' => $quantityBefore,
                    'quantity_after' => $quantityAfter,
                    'reason' => $reason,
                    'invoice_number' => $invoiceNumber,
                    'created_by' => $userId,
                    'created_at' => now()
                ]);

                // Create audit log
                $actionLog = ($type === "in") ? "STOCK_IN" : (($type === "out") ? "STOCK_OUT" : "STOCK_ADJUST");
                AuditLog::create([
                    'user_id' => $userId,
                    'action' => $actionLog,
                    'details' => "Updated stock for product {$product->name} ({$product->sku}): {$quantityBefore} -> {$quantityAfter}",
                    'timestamp' => now()
                ]);

                return response()->json([
                    "status" => "success",
                    "message" => "تم تحديث المخزون بنجاح",
                    "data" => [
                        "id" => $movement->id,
                        "quantity_before" => $quantityBefore,
                        "quantity_after" => $quantityAfter,
                        "quantity_change" => $quantityChange
                    ]
                ]);
            });
        } catch (\Exception $e) {
            return response()->json(['detail' => $e->getMessage()], 400);
        }
    }

    /**
     * Get stock history for a specific product.
     */
    public function history($productId)
    {
        $movements = StockMovement::with('user')
            ->where('product_id', $productId)
            ->orderBy('created_at', 'desc')
            ->limit(100)
            ->get();

        $formatted = [];
        foreach ($movements as $m) {
            $formatted[] = [
                "id" => $m->id,
                "type" => $m->type,
                "quantity_change" => $m->quantity_change,
                "quantity_before" => $m->quantity_before,
                "quantity_after" => $m->quantity_after,
                "reason" => $m->reason,
                "invoice_number" => $m->invoice_number,
                "created_by" => $m->user ? ($m->user->name ?? $m->user->email) : "نظام",
                "created_at" => $m->created_at ? $m->created_at->toIso8601String() : null
            ];
        }

        return response()->json([
            "status" => "success",
            "data" => $formatted
        ]);
    }

    /**
     * Update low stock threshold, reorder point and max stock for a product.
     */
    public function updateThresholds(Request $request, $productId)
    {
        $request->validate([
            'low_stock_threshold' => 'required|integer',
            'reorder_point' => 'required|integer',
            'max_stock' => 'required|integer'
        ]);

        $product = Product::where('id', $productId)->where('is_deleted', false)->firstOrFail();

        $product->low_stock_threshold = $request->input('low_stock_threshold');
        $product->reorder_point = $request->input('reorder_point');
        $product->max_stock = $request->input('max_stock');
        $product->save();

        $userId = auth()->id() ?? 1;
        AuditLog::create([
            'user_id' => $userId,
            'action' => 'UPDATE_THRESHOLDS',
            'details' => "Updated inventory thresholds for {$product->name}",
            'timestamp' => now()
        ]);

        return response()->json([
            "status" => "success",
            "message" => "تم تحديث مستويات التنبيه بنجاح"
        ]);
    }
}

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <title>فاتورة رقم #{{ $order->id }}</title>
    <style>
        body {
            font-family: 'DejaVu Sans', sans-serif;
            direction: rtl;
            text-align: right;
            color: #000;
            line-height: 1.5;
            margin: 0;
            padding: 0;
        }
        @page {
            size: letter;
            margin: 1in;
        }
        table.items-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 0;
            margin-bottom: 20px;
        }
        table.items-table th {
            border: 1px solid #000;
            padding: 6px;
            font-size: 11px;
            font-weight: bold;
            text-align: center;
            background-color: #f2f2f2;
        }
        table.items-table td {
            border: 1px solid #000;
            padding: 6px;
            font-size: 11px;
            text-align: center;
            vertical-align: middle;
        }
        .product-image {
            max-width: 50px;
            max-height: 50px;
            display: block;
            margin: 0 auto;
        }
        table.meta-table {
            width: 100%;
            border-collapse: collapse;
            border: none;
            margin-top: 40px;
        }
        table.meta-table td {
            border: none;
            padding: 5px 0;
            font-size: 13px;
            vertical-align: top;
        }
        .meta-label {
            font-weight: bold;
            text-align: right;
            width: 150px;
        }
        .meta-value {
            text-align: right;
        }
        .stamp-section {
            margin-top: 60px;
            font-size: 13px;
            font-weight: bold;
            text-align: right;
        }
    </style>
</head>
<body>

    @php
        $arabic = new \ArPHP\I18N\Arabic();
        $shape = function($text) use ($arabic) {
            if (empty($text)) return '';
            // If it contains Arabic characters, shape it
            if (preg_match('/[\x{0600}-\x{06FF}]/u', $text)) {
                return $arabic->utf8Glyphs($text);
            }
            return $text;
        };

        $address = $order->customer_address ?? '';
        $governorate = '';
        $detailedAddress = '';
        if ($address) {
            $parts = explode('-', $address, 2);
            $governorate = trim($parts[0]);
            $detailedAddress = isset($parts[1]) ? trim($parts[1]) : '';
        }

        $calculatedSubtotal = 0;
        foreach($order->items as $item) {
            $calculatedSubtotal += ($item->price ?? $item->unit_price ?? 0) * $item->quantity;
        }
        $subtotal = $order->subtotal > 0 ? $order->subtotal : $calculatedSubtotal;
    @endphp

    <table class="items-table">
        <thead>
            <tr>
                <th style="width: 17.5%;">{{ $shape('صورة المنتج') }}</th>
                <th style="width: 14.5%;">{{ $shape('اسم المنتج') }}</th>
                <th style="width: 6.4%;">{{ $shape('العدد') }}</th>
                <th style="width: 11.2%;">{{ $shape('العنوان') }}</th>
                <th style="width: 11.2%;">{{ $shape('رقم الهاتف') }}</th>
                <th style="width: 12.0%;">{{ $shape('السعر') }}</th>
                <th style="width: 15.3%;">{{ $shape('السعر النهائي') }}</th>
                <th style="width: 11.9%;">{{ $shape('ملاحظات') }}</th>
            </tr>
        </thead>
        <tbody>
            @foreach($order->items as $item)
                @php
                    $imagePath = $item->product->image ?? null;
                    $resolvedImageUrl = null;
                    if ($imagePath) {
                        if (str_starts_with($imagePath, 'http://') || str_starts_with($imagePath, 'https://')) {
                            $resolvedImageUrl = $imagePath;
                        } else {
                            $cleanPath = ltrim($imagePath, '/');
                            if (str_starts_with($cleanPath, 'storage/')) {
                                $cleanPath = substr($cleanPath, 8);
                            }
                            $resolvedImageUrl = public_path('storage/' . $cleanPath);
                        }
                    }
                @endphp
                <tr>
                    <td>
                        @if($resolvedImageUrl)
                            <img src="{{ $resolvedImageUrl }}" class="product-image">
                        @else
                            <span style="font-size: 9px; color: #888;">{{ $shape('لا توجد صورة') }}</span>
                        @endif
                    </td>
                    <td>{{ $shape($item->product->name_ar ?? $item->product->name ?? '') }}</td>
                    <td>{{ $item->quantity }}</td>
                    <td>{{ $shape($order->customer_address ?? '') }}</td>
                    <td>{{ $order->customer_phone ?? '' }}</td>
                    <td>{{ number_format($item->price ?? $item->unit_price ?? 0, 0) }} IQD</td>
                    <td>{{ number_format(($item->price ?? $item->unit_price ?? 0) * $item->quantity, 0) }} IQD</td>
                    <td>{{ $shape($order->notes ?? '') }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <table class="meta-table">
        <tbody>
            <tr>
                <td class="meta-label">{{ $shape('اسم الزبون :') }}</td>
                <td class="meta-value">{{ $shape($order->customer_name ?? $order->user->name ?? 'عميل عام') }}</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('رقم الهاتف:') }}</td>
                <td class="meta-value">{{ $order->customer_phone ?? $order->user->phone ?? '' }}</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('رقم الطلب :') }}</td>
                <td class="meta-value">#{{ $order->id }}</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('التاريخ :') }}</td>
                <td class="meta-value">{{ $order->created_at->format('Y-m-d') }}</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('المحافظة :') }}</td>
                <td class="meta-value">{{ $shape($governorate ?: $address) }}</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('العنوان التفصيلي :') }}</td>
                <td class="meta-value">{{ $shape($detailedAddress ?: $address) }}</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('المجموع:') }}</td>
                <td class="meta-value">{{ number_format($subtotal, 0) }} IQD</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('الخصم:') }}</td>
                <td class="meta-value">{{ number_format($order->discount_amount ?? 0, 0) }} IQD</td>
            </tr>
            <tr>
                <td class="meta-label">{{ $shape('كود الخصم:') }}</td>
                <td class="meta-value">{{ $shape($order->coupon_code ?? 'لا يوجد') }}</td>
            </tr>
        </tbody>
    </table>

    <div class="stamp-section">
        {{ $shape('ختم المجهز :') }}
    </div>

</body>
</html>

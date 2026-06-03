<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>لوحة التحكم | نوزل Nozzle</title>
    <!-- Tailwind CSS CDN for Wow factor -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Noto+Kufi+Arabic:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        amber: {
                            50: '#fffbeb',
                            100: '#fef3c7',
                            200: '#fde68a',
                            300: '#fcd34d',
                            400: '#fbbf24',
                            500: '#f59e0b',
                            600: '#d97706',
                            700: '#b45309',
                            800: '#92400e',
                            900: '#78350f',
                        }
                    },
                    fontFamily: {
                        sans: ['Outfit', 'Noto Kufi Arabic', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    <style>
        .glass {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .sidebar-item-active {
            background: linear-gradient(90deg, rgba(245, 158, 11, 0.1) 0%, rgba(245, 158, 11, 0) 100%);
            border-right: 4px solid #f59e0b;
        }
        body {
            background-color: #0f172a; /* Slate 900 */
            color: #f8fafc; /* Slate 50 */
        }
    </style>
</head>
<body class="font-sans antialiased overflow-x-hidden">
    <div class="flex h-screen overflow-hidden">
        
        <!-- Sidebar -->
        <aside class="fixed inset-y-0 right-0 z-50 w-64 bg-slate-900 border-l border-slate-800 transition-transform lg:static lg:translate-x-0 overflow-y-auto">
            <div class="p-6">
                <!-- Logo -->
                <div class="flex items-center gap-3 mb-8">
                    <div class="w-10 h-10 bg-amber-500 rounded-xl flex items-center justify-center shadow-lg shadow-amber-500/20">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                        </svg>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold tracking-tight text-white">نوزل Nozzle</h1>
                        <p class="text-[10px] text-slate-400 uppercase tracking-widest font-semibold">لوحة الإدارة</p>
                    </div>
                </div>

                    <!-- Navigation -->
                <nav class="space-y-1">
                    <p class="px-4 text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">الرئيسية</p>
                    <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'sidebar-item-active text-amber-500' : 'text-slate-300' }} group flex items-center px-4 py-3 text-sm font-medium transition-all hover:bg-slate-800">
                        <svg class="w-5 h-5 ml-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                        </svg>
                        <span>لوحة التحكم</span>
                    </a>

                    <div class="pt-6">
                        <p class="px-4 text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">التجارة الإلكترونية</p>
                        <a href="{{ route('admin.products.index') }}" class="{{ request()->is('bespoke-admin/products*') ? 'sidebar-item-active text-amber-500' : 'text-slate-300' }} group flex items-center px-4 py-3 text-sm font-medium transition-all hover:bg-slate-800 hover:text-white">
                            <svg class="w-5 h-5 ml-3 text-slate-400 group-hover:text-amber-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                            </svg>
                            <span>المنتجات</span>
                        </a>
                        <a href="{{ route('admin.categories.index') }}" class="{{ request()->is('bespoke-admin/categories*') ? 'sidebar-item-active text-amber-500' : 'text-slate-300' }} group flex items-center px-4 py-3 text-sm font-medium transition-all hover:bg-slate-800 hover:text-white">
                            <svg class="w-5 h-5 ml-3 text-slate-400 group-hover:text-amber-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 11h.01M7 15h.01M11 7h.01M11 11h.01M11 15h.01M15 7h.01M15 11h.01M15 15h.01M19 7h.01M19 11h.01M19 15h.01M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2z" />
                            </svg>
                            <span>التصنيفات</span>
                        </a>
                        <a href="{{ route('admin.orders.index') }}" class="{{ request()->is('bespoke-admin/orders*') ? 'sidebar-item-active text-amber-500' : 'text-slate-300' }} group flex items-center px-4 py-3 text-sm font-medium transition-all hover:bg-slate-800 hover:text-white">
                            <svg class="w-5 h-5 ml-3 text-slate-400 group-hover:text-amber-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                            </svg>
                            <span>الطلبيات</span>
                        </a>
                        <a href="{{ route('admin.banners.index') }}" class="{{ request()->is('bespoke-admin/banners*') ? 'sidebar-item-active text-amber-500' : 'text-slate-300' }} group flex items-center px-4 py-3 text-sm font-medium transition-all hover:bg-slate-800 hover:text-white">
                            <svg class="w-5 h-5 ml-3 text-slate-400 group-hover:text-amber-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                            <span>البانرات</span>
                        </a>
                    </div>

                    <div class="pt-6">
                        <p class="px-4 text-[11px] font-bold text-slate-500 uppercase tracking-widest mb-2">النظام</p>
                        <a href="#" class="group flex items-center px-4 py-3 text-sm font-medium text-slate-300 transition-all hover:bg-slate-800 hover:text-white">
                            <svg class="w-5 h-5 ml-3 text-slate-400 group-hover:text-amber-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                            </svg>
                            <span>المستخدمين</span>
                        </a>
                        <a href="#" class="group flex items-center px-4 py-3 text-sm font-medium text-slate-300 transition-all hover:bg-slate-800 hover:text-white">
                            <svg class="w-5 h-5 ml-3 text-slate-400 group-hover:text-amber-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                            </svg>
                            <span>الإعدادات</span>
                        </a>
                    </div>
                </nav>
            </div>
            
            <div class="absolute bottom-0 w-full p-6 border-t border-slate-800">
                <a href="/logout" class="flex items-center gap-3 text-slate-400 hover:text-red-400 transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                    </svg>
                    <span class="text-sm">تسجيل الخروج</span>
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 relative z-0 flex flex-col overflow-y-auto overflow-x-hidden">
            <!-- Header -->
            <header class="glass sticky top-0 z-40 h-16 w-full flex items-center justify-between px-8 border-b border-white/10 shrink-0">
                <div class="flex items-center gap-4">
                    <button class="lg:hidden text-slate-400 hover:text-white transition-colors">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                        </svg>
                    </button>
                    <div class="relative hidden md:block">
                        <input type="text" placeholder="البحث..." class="bg-slate-800/50 border border-slate-700/50 rounded-lg py-2 pr-10 pl-4 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/50 w-64 text-slate-300">
                        <svg class="w-4 h-4 text-slate-500 absolute right-3 top-1/2 -translate-y-1/2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                        </svg>
                    </div>
                </div>

                <div class="flex items-center gap-4">
                    <button class="relative w-10 h-10 flex items-center justify-center rounded-lg hover:bg-slate-800 transition-colors text-slate-400">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                        </svg>
                        <span class="absolute top-2.5 right-2.5 w-2 h-2 bg-amber-500 rounded-full border-2 border-slate-900"></span>
                    </button>
                    
                    <div class="h-8 w-[1px] bg-white/10 mx-2"></div>

                    <div class="flex items-center gap-3">
                        <div class="text-left hidden sm:block">
                            <p class="text-sm font-semibold text-white">مدير النظام</p>
                            <p class="text-[10px] text-slate-400 uppercase tracking-widest font-bold">متصل الآن</p>
                        </div>
                        <img src="https://ui-avatars.com/api/?name=Admin&background=f59e0b&color=fff" class="w-9 h-9 rounded-lg border border-amber-500/50 shadow-lg shadow-amber-500/10" alt="Avatar">
                    </div>
                </div>
            </header>

            <!-- Page Content -->
            <div class="p-8">
                @yield('content')
            </div>

            <!-- Footer -->
            <footer class="mt-auto p-8 border-t border-white/5 text-slate-500 text-sm flex justify-between">
                <p>&copy; 2026 نوزل Nozzle. جميع الحقوق محفوظة.</p>
                <div class="flex gap-4">
                    <a href="#" class="hover:text-amber-500 transition-colors">الدعم</a>
                    <a href="#" class="hover:text-amber-500 transition-colors">سياسة الخصوصية</a>
                </div>
            </footer>
        </main>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // Custom interactive effects could go here
    </script>
</body>
</html>

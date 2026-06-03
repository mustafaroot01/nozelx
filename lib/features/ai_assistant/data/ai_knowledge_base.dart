/// AI Assistant Knowledge Base for AutoLube App
/// Contains comprehensive information about motor oils, car maintenance, and services
library;

class AIKnowledgeBase {
  /// Get response based on user query
  static String getResponse(String query) {
    String lowerQuery = query.toLowerCase();

    // Oil and Lubricants
    if (_containsAny(lowerQuery, [
      'زيت',
      'محرك',
      'oil',
      'lubricant',
      'بنزين',
      'ديزل',
    ])) {
      return _getOilRecommendation(lowerQuery);
    }

    // Car maintenance
    if (_containsAny(lowerQuery, [
      'صيانة',
      'توصية',
      'maintenance',
      'فحص',
      'تغيير',
    ])) {
      return _getMaintenanceTips(lowerQuery);
    }

    // Orders and tracking
    if (_containsAny(lowerQuery, ['طلب', 'تتبع', 'order', 'شحن', 'delivery'])) {
      return _getOrderInfo();
    }

    // Offers and discounts
    if (_containsAny(lowerQuery, [
      'عرض',
      'خصم',
      'offer',
      'sale',
      'كوبون',
      'coupon',
    ])) {
      return _getCurrentOffers();
    }

    // Payment
    if (_containsAny(lowerQuery, [
      'دفع',
      'payment',
      'cash',
      'نقدي',
      'فيزا',
      'visa',
    ])) {
      return _getPaymentInfo();
    }

    // Products and categories
    if (_containsAny(lowerQuery, [
      'منتج',
      'product',
      'فلتر',
      'filter',
      'نوع',
    ])) {
      return _getProductsInfo();
    }

    // Technical issues
    if (_containsAny(lowerQuery, [
      'مشكلة',
      'issue',
      'مش',
      'ضوضاء',
      'صوت',
      'engine',
    ])) {
      return _getTechnicalHelp(lowerQuery);
    }

    // Contact and support
    if (_containsAny(lowerQuery, [
      'تواصل',
      'contact',
      'اتصال',
      'phone',
      'whatsapp',
      'واتساب',
    ])) {
      return _getContactInfo();
    }

    // About the app
    if (_containsAny(lowerQuery, ['تطبيق', 'app', 'من نحن', 'about', 'شركة'])) {
      return _getAppInfo();
    }

    // Greeting
    if (_containsAny(lowerQuery, ['مرحبا', 'hello', 'hi', 'اهلا', 'السلام'])) {
      return _getGreeting();
    }

    // Thank you
    if (_containsAny(lowerQuery, ['شكرا', 'thanks', 'thank', 'جزيل'])) {
      return _getThanksResponse();
    }

    // Bye
    if (_containsAny(lowerQuery, [
      'bye',
      'وداعا',
      'مع السلامة',
      'إلى اللقاء',
    ])) {
      return _getGoodbye();
    }

    // Default - Smart assistant capabilities
    return _getCapabilities();
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  static String _getOilRecommendation(String query) {
    bool isToyota = query.contains('toyota') || query.contains('توتا');
    bool isHonda = query.contains('honda') || query.contains('هوندا');
    bool isHyundai = query.contains('hyundai') || query.contains('هيونداي');
    bool isKia = query.contains('kia') || query.contains('كيا');
    bool isBMW = query.contains('bmw') || query.contains('بي ام');
    bool isMercedes = query.contains('mercedes') || query.contains('مرسيدس');
    bool isFord = query.contains('ford') || query.contains('فورد');
    bool isChevrolet =
        query.contains('chevrolet') || query.contains('شيفروليه');

    String carSpecific = '';
    if (isToyota || isHonda || isHyundai || isKia) {
      carSpecific = '''
🚗 <strong>لسياراتToyota/Honda/Hyundai/Kia:</strong>
• 0W-20: للسيارات الحديثة جداً (أقل من 3 سنوات)
• 5W-30: للسيارات المتوسطة (3-7 سنوات)
• 5W-40: للسيارات القديمة (أكثر من 7 سنوات)
''';
    } else if (isBMW || isMercedes) {
      carSpecific = '''
🚗 <strong>لسيارات BMW/Mercedes:</strong>
• 0W-30 / 0W-40: موصى به من BMW
• 229.5 / 229.6: مواصفات Mercedes-Benz
• استخدم فقط زيوت معتمدة
''';
    } else if (isFord || isChevrolet) {
      carSpecific = '''
🚗 <strong>لسيارات Ford/Chevrolet:</strong>
• 5W-30: معظم الموديلات الحديثة
• 5W-20: بعض موديلات Ford
''';
    }

    return '''
🛢️ <strong>توصيات زيت المحرك</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

$carSpecific

🥇 <strong>أفضل أنواع زيوت المحركات:</strong>

┌─────────────────────────────────────┐
│ 🏆 Mobil 1 ESP 5W-30                │
│    السعر: 45,000 د.ع                │
│    • حماية قصوى للمحرك              │
│    • توفير في الوقود                 │
│    • مثالي للسيارات الحديثة          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🥈 Castrol Edge 5W-30              │
│    السعر: 42,000 د.ع                │
│    • تقنية Titanium                  │
│    • أداء عالي                       │
│    • حماية مزدوجة                   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🥉 Shell Helix Ultra 5W-30         │
│    السعر: 38,000 د.ع                │
│    • تكنولوجيا Gas-to-Liquid        │
│    • اقتصادية وموثوقة                │
│   ة                    │
└─────────────────────────────────────┘ • حماية ممتاز

┌─────────────────────────────────────┐
│ 💎 Valvoline Premium 5W-30          │
│    السعر: 35,000 د.ع                │
│    • جودة أمريكية                   │
│    • سعر مناسب                       │
│    • حماية جيدة                      │
└─────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━

💡 <strong>نصيحة:</strong>
• تحقق من كتيب سيارتك لللزوجة المناسبة
• غيّر الزيت كل 5,000-10,000 كم
• استخدم فلاتر أصلية

🔗 هل تريد إضافة منتج للسلة؟
''';
  }

  static String _getMaintenanceTips(String query) {
    bool isFullService = query.contains('شامل') || query.contains('full');
    bool isOilChange = query.contains('تغيير') || query.contains('oil change');
    bool isTires = query.contains('إطارات') || query.contains('tires');
    bool isBattery = query.contains('بطارية') || query.contains('battery');
    bool isAC =
        query.contains('مكيف') ||
        query.contains('تكييف') ||
        query.contains('ac');
    bool isBrakes = query.contains('فرامل') || query.contains('brakes');

    String specificTips = '';

    if (isOilChange) {
      specificTips = '''
🔧 <strong>تغيير زيت المحرك:</strong>

✓ الفحص كل: 5,000 - 10,000 كم
✓ التغيير الموصى به: كل 7,500 كم
✓ يجب تغيير الفلتر مع الزيت
✓ افحص مستوى الزيت شهرياً

⚠️ <strong>علامات الحاجة للتغيير:</strong>
• تغير لون الزيت إلى الأسود الداكن
• صوت طقطقة من المحرك
• ضعف في الأداء
• زيادة استهلاك الوقود
''';
    } else if (isTires) {
      specificTips = '''
🔧 <strong>صيانة الإطارات:</strong>

✓ فحص الضغط: شهرياً (البار 32-35)
✓ تدوير الإطارات: كل 10,000 كم
✓ فحص التآكل: شهرياً
✓ العمر الافتراضي: 4-5 سنوات

⚠️ <strong>علامات تلف الإطارات:</strong>
• تآكل غير متساوٍ
• شقوق على الجوانب
• انتفاخ في الجنط
''';
    } else if (isBattery) {
      specificTips = '''
🔧 <strong>صيانة البطارية:</strong>

✓ فحص مستوى الماء: شهرياً
✓ تنظيف الأقطاب: كل 3 أشهر
✓ فحص الكابلات: دورياً

⚠️ <strong>أعطال البطارية:</strong>
• صعوبة في التشغيل
• أضواء خافتة
• صدأ على الأقطاب
''';
    } else if (isAC) {
      specificTips = '''
🔧 <strong>صيانة التكييف:</strong>

✓ تغيير فلتر التكييف: كل 20,000 كم
✓ فحص غاز التبريد: سنوياً
✓ تنظيف المبخر: كل سنة

⚠️ <strong>مشاكل التكييف:</strong>
• عدم تبريد الهواء
• روائح كريهة
• صوت غير طبيعي
''';
    } else if (isBrakes) {
      specificTips = '''
🔧 <strong>صيانة الفرامل:</strong>

✓ فحص البطانة: كل 15,000 كم
✓ فحص السائل: كل سنتين
✓ فحص الدوارات: عند الحاجة

⚠️ <strong>تحذيرات الفرامل:</strong>
• صوت صرير عند الضغط
• رجاجة عند الفرملة
• استجابة بطيئة
''';
    } else if (isFullService) {
      specificTips = '''
🔧 <strong>جدول الصيانة الشاملة:</strong>

📅 <strong>شهرياً:</strong>
• فحص مستوى الزيت
• فحص ضغط الإطارات
• فحص السوائل

📅 <strong>كل 5,000 كم:</strong>
• تغيير زيت المحرك
• فحص الفلاتر

📅 <strong>كل 15,000 كم:</strong>
• فحص الفرامل
• تدوير الإطارات
• فحص بطارية

📅 <strong>كل 20,000 كم:</strong>
• تغيير فلتر الهواء
• تغيير فلتر التكييف

📅 <strong>كل 40,000 كم:</strong>
• تغيير شمعات الإTiming
• فحص سير التوقيت
''';
    }

    return '''
🔧 <strong>نصائح الصيانة</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

$specificTips

💰 <strong>توفير في التكاليف:</strong>
• الصيانة الوقائية توفر 30% من تكاليف الإصلاح
• تغيير الزيت بانتظام يطيل عمر المحرك
• فحص الإطارات يوفر الوقود

🛠️ هل تريد حجز موعد صيانة؟
''';
  }

  static String _getOrderInfo() {
    return '''
📦 <strong>معلومات الطلبات والشحن</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

🚚 <strong>طرق الشحن:</strong>
• توصيل سريع: 24-48 ساعة
• توصيل عادي: 3-5 أيام
• استلام من المحل: فوري

💰 <strong>تكلفة الشحن:</strong>
• طلبات أكثر من 50,000 د.ع: مجاني
• طلبات أقل من 50,000 د.ع: 5,000 د.ع

📍 <strong>تتبع الطلب:</strong>
1. اذهب إلى "طلباتي"
2. اختر الطلب المراد
3. شاهد حالة التوصيل:
   🟢 قيد التجهيز
   🟡 قيد التوصيل
   🔴 تم التوصيل

⏰ <strong>أوقات العمل:</strong>
• الطلبات: 24 ساعة
• التوصيل: 9 صباحاً - 9 مساءً

📞 هل تحتاج مساعدة في طلب معين؟
''';
  }

  static String _getCurrentOffers() {
    return '''
🎉 <strong>العروض والخصومات الحالية</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

🔥 <strong>عروض حصرية:</strong>

┌─────────────────────────────────────┐
│ 🎯 خصم 20% على جميع زيوت الموبيل    │
│ ⏰ صالح حتى نهاية الشهر              │
│ 📦 الحد الأدنى: 35,000 د.ع          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🎁 اشتر 2 واحصل على 1 مجاني        │
│    على جميع الفلاتر                 │
│ ⏰ محدود الكمية                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🚚 توصيل مجاني                     │
│    للطلبات فوق 50,000 د.ع          │
│ ✅ في جميع المناطق                  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ ⭐ نقاط ولاء مضاعفة                │
│    هذا الأسبوع فقط                  │
│    2x نقاط على كل شراء             │
└─────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━

🎫 <strong>كوبونات متاحة:</strong>
• NEW10: 10% للطلبات الأولى
• AUTO20: 20% للسيارات القديمة
• MAINTENANCE15: 15% على الخدمات

💡 استخدم كود الخصم في صفحة السلة
''';
  }

  static String _getPaymentInfo() {
    return '''
💳 <strong>طرق الدفع</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

💵 <strong>الدفع عند الاستلام:</strong>
• Cash on delivery
• دفع مباشرة عند الاستلام
• متاح في جميع المناطق

💳 <strong>الدفع الإلكتروني:</strong>
• Visa Card / Mastercard
• كي نت / فورتي
• Apple Pay

📱 <strong>الدفع عبر الهاتف:</strong>
• Vodafone Cash
• InstaPay
• تحويل بنكي

🔒 <strong>الأمان:</strong>
• تشفير SSL للمدفوعات
• بياناتك محمية 100%
• معالجة آمنة

💰 <strong>العملة:</strong>
• الدينار العراقي (د.ع)
• أسعار شاملة الضريبة
''';
  }

  static String _getProductsInfo() {
    return '''
🛒 <strong>المنتجات المتاحة</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

🛢️ <strong>زيوت المحركات:</strong>
• Mobil 1 - 45,000 د.ع
• Castrol Edge - 42,000 د.ع
• Shell Helix - 38,000 د.ع
• Valvoline - 35,000 د.ع

🔧 <strong>الفلاتر:</strong>
• فلتر زيت - 8,000 د.ع
• فلتر هواء - 10,000 د.ع
• فلتر مكيف - 12,000 د.ع

⚡ <strong>البطاريات:</strong>
• بطاريات أصلية
• ضمان سنتان
• تركيب مجاني

🧴 <strong>سوائل الصيانة:</strong>
• سائل الفرامل - 15,000 د.ع
• سائل التبريد - 18,000 د.ع
• سائلdirection - 12,000 د.ع

🔌 <strong>إضافات:</strong>
• إضافات وقود
• إضافات زيت
• منظفات المحرك

📦 هل تريد تصفح المنتجات؟
''';
  }

  static String _getTechnicalHelp(String query) {
    bool isEngine = query.contains('محرك') || query.contains('engine');
    bool isNoise =
        query.contains('ضوضاء') ||
        query.contains('صوت') ||
        query.contains('noise');
    bool isSmoke = query.contains('دخان') || query.contains('smoke');
    bool isStarting = query.contains('تشغيل') || query.contains('start');
    bool isOverheating =
        query.contains('سخونة') ||
        query.contains('حرارة') ||
        query.contains('overheat');

    String help = '';

    if (isSmoke) {
      help = '''
⚠️ <strong>إذا كان هناك دخان:</strong>

🟡 دخان أبيض خفيف:
• عادةً طبيعي (بخار الماء)
• إذا زاد، افحص حلقة piston

🔴 دخان أزرق:
• حرق الزيت
• افحص:
  - حلقات piston
  - صمامات
  - seals

⚫ دخان أسود:
• خليط الهواء والوقود غني
• افحص:
  - فلاتر الهواء
  - حقن الوقود
  - مستشعر O2
''';
    } else if (isNoise) {
      help = '''
⚠️ <strong>إذا كان هناك ضوضاء:</strong>

🔨 صوت طقطقة:
• نقص في الزيت
• مشاكل في التوقيت
• صمامات تحتاج تعديل

🦗 صوت صرير:
• حزام مضخ الماء
• bearing تالف
• نقص في سائل direction

🥁 صوت طنين:
• bearing العجلات
• مشاكل في ABS
• صيانة الفرامل
''';
    } else if (isOverheating) {
      help = '''
⚠️ <strong>إذا كان المحرك يسخن:</strong>

💧 افحص:
• مستوى سائل التبريد
• radiator (المبرد)
• مضخ الماء
• سير المضخة
• thermostaT

💡 نصائح:
• لا تفتح radiator ساخن
• أوقف المحرك واتركه يبرد
• افحص مضخة الماء
''';
    } else if (isStarting) {
      help = '''
⚠️ <strong>مشاكل التشغيل:</strong>

🚗 المحرك لا يدور:
• بطارية ضعيفة
• starter تالف
• مشاكل في keyless

🔋 المحرك يدور لكن لا يشغل:
• شمعات الإشراب
• مضخة الوقود
• مستشعرات

💡 الحل الأول:
• افحص البطارية
• افحص شمعات الإشراب
''';
    } else if (isEngine) {
      help = '''
⚠️ <strong>مشاكل المحرك العامة:</strong>

ضعف في الأداء:
• فلاتر متسخة
• مشاكل في الحقن
• مستشعرات

استهلاك وقود عالي:
• ضغط الإطارات منخفض
• فلةAir متسخة
• مشاكل في التوقيت

اضاءة Check Engine:
• افحص الكود باستخدام scanner
• مستشعر O2
• catalytic converter
''';
    }

    return '''
🔧 <strong>المساعدة الفنية</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

$help

🔧 هل تريد حجز فحص للسيارة؟
''';
  }

  static String _getContactInfo() {
    return '''
📞 <strong>معلومات التواصل</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

📱 <strong>الهاتف:</strong>
• 07701234567
• 07709876543

💬 <strong>WhatsApp:</strong>
• 07701234567
• متاح 24/7

📧 <strong>البريد الإلكتروني:</strong>
• info@autolube.com

🏪 <strong>الموقع:</strong>
• العراق - بغداد
• شارع الرئيسي

⏰ <strong>أوقات العمل:</strong>
• الأحد - الخميس: 9 ص - 9 م
• الجمعة: 4 م - 9 م
• السبت: 10 ص - 6 م

💬 <strong>وسائل التواصل:</strong>
• Facebook: @AutoLubeIQ
• Instagram: @autolube_iq
• TikTok: @autolube

📨 كيف يمكننا مساعدتك؟
''';
  }

  static String _getAppInfo() {
    return '''
🏢 <strong>عن أوتولوب</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

📱 <strong>تطبيق أوتولوب</strong>

نقدم لك أفضل خدمات:
• زيوت المحركات الأصلية
• فلاتر عالية الجودة
• بطاريات معتمدة
• خدمات صيانة احترافية

🌟 <strong>مميزاتنا:</strong>
• توصيل سريع لجميع المناطق
• أسعار تنافسية
• فريق متخصص
• ضمان على جميع المنتجات
• نقاط ولاء ومكافآت

🏆 <strong>إنجازاتنا:</strong>
• +10,000 عميل سعيد
• +50,000 طلب ناجح
• تقييم 4.9 على Google
• +5 سنوات خبرة

💙 <strong>شكراً لثقتكم بنا!</strong>
''';
  }

  static String _getGreeting() {
    return '''
👋 <strong>مرحباً بك في أوتولوب!</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

أنا المساعد الذكي الخاص بك 🚀

أستطيع مساعدتك في:

🔧 <strong>اختيار المنتجات:</strong>
• زيوت المحركات
• الفلاتر
• البطاريات
• سوائل الصيانة

💰 <strong>الخدمات:</strong>
• معلومات العروض والخصومات
• تتبع طلباتك
• حل المشاكل الفنية

🚗 <strong>الصيانة:</strong>
• نصائح الصيانة
• جداول الصيانة
• مواعيد الصيانة

💬 كيف يمكنني خدمتك اليوم؟
''';
  }

  static String _getThanksResponse() {
    return '''
🙏 <strong>العفو!</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

شكراً لك على ثقتكم بنا! 

نحن دائماً في خدمتك 💪

هل هناك أي شيء آخر يمكنني مساعدتك فيه؟

🔄 أو يمكنني مساعدتك في:
• اختيار منتج جديد
• متابعة طلبك
• الاستفسار عن العروض
''';
  }

  static String _getGoodbye() {
    return '''
👋 <strong>إلى اللقاء!</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

شكراً لاستخدامك مساعد أوتولوب!

أتمنى أن تكون قد حصلت على المساعدة المطلوبة 🌟

نراك قريباً! 

💙 فريق أوتولوب
''';
  }

  static String _getCapabilities() {
    return '''
✨ <strong>مساعد أوتولوب الذكي</strong>

━━━━━━━━━━━━━━━━━━━━━━━━

أستطيع مساعدتك في كل ما يلي:

🛢️ <strong>المنتجات:</strong>
• اختيار زيت المحرك المناسب
• الفلاتر وال batteries
• مقارنة الأسعار

🔧 <strong>الصيانة:</strong>
• نصائح الصيانة الدورية
• جداول الصيانة
• تشخيص المشاكل البسيطة

📦 <strong>الطلبات:</strong>
• تتبع طلباتك
• معلومات الشحن
• الاستلام من المحل

💰 <strong>العروض:</strong>
• أحدث الخصومات
• أكواد الخصم
• نقاط الولاء

💳 <strong>الدفع:</strong>
• طرق الدفع المتاحة
• العروض الحالية

📞 <strong>الدعم:</strong>
• معلومات التواصل
• ساعات العمل

💬 ما الذي تريد معرفته؟
''';
  }
}

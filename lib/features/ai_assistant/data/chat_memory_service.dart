import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة ذاكرة المحادثات لكل مستخدم
class ChatMemoryService {
  static const String _chatHistoryKey = 'chat_history_';
  static const int _maxMessages = 50;

  /// حفظ المحادثة للمستخدم الحالي
  static Future<void> saveMessage(
    String userId,
    String message,
    bool isUser,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatHistoryKey + userId;

    List<Map<String, dynamic>> messages = [];
    final existingData = prefs.getString(key);
    if (existingData != null) {
      messages = List<Map<String, dynamic>>.from(jsonDecode(existingData));
    }

    messages.add({
      'text': message,
      'isUser': isUser,
      'time': DateTime.now().toIso8601String(),
    });

    if (messages.length > _maxMessages) {
      messages = messages.sublist(messages.length - _maxMessages);
    }

    await prefs.setString(key, jsonEncode(messages));
  }

  /// استرجاع محادثات المستخدم
  static Future<List<Map<String, dynamic>>> getChatHistory(
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatHistoryKey + userId;

    final data = prefs.getString(key);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  /// مسح محادثات المستخدم
  static Future<void> clearChatHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatHistoryKey + userId;
    await prefs.remove(key);
  }
}

/// محرك فهم اللغة العربية والعراقية
class IraqiLanguageProcessor {
  static String preprocessText(String text) {
    String processed = text.toLowerCase().trim();
    processed = _removeDiacritics(processed);
    processed = _normalizeIraqiWords(processed);
    return processed;
  }

  static String _removeDiacritics(String text) {
    final Map<String, String> arabicDiacritics = {
      'َ': '',
      'ً': '',
      'ُ': '',
      'ٌ': '',
      'ِ': '',
      'ٍ': '',
      'ْ': '',
      'ّ': '',
      'ٰ': '',
      'ٓ': '',
      'ٔ': '',
      'ٖ': '',
    };

    String result = text;
    arabicDiacritics.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  static String _normalizeIraqiWords(String text) {
    final Map<String, List<String>> synonyms = {
      'زيت': ['زيت', 'اويل', 'oil', 'موتور'],
      'سيارة': ['سيارة', 'سياره', 'عربية', 'حافلة'],
      'شنو': ['شنو', 'وش', 'ش', 'ايش', 'إيش', 'what'],
      'كيف': ['كيف', 'شلون', 'كيفية', 'how'],
      'طلب': ['طلب', 'طلبية', 'اوردر', 'order'],
      'تتبع': ['تتبع', 'تتبع طلب', 'استعلام', 'track'],
      'عرض': ['عرض', 'عروض', 'خصم', 'تخفيض', 'offer', 'sale'],
      'صيانة': ['صيانة', 'خدمة', 'فحص', 'maintenance'],
      'مشكلة': ['مشكلة', 'عطل', 'مشكلة', 'problem', 'عطل'],
      'بطارية': ['بطارية', 'بطاريه', 'شحن', 'battery'],
      'مكيف': ['مكيف', 'تكييف', 'ac'],
      'توصيل': ['توصيل', 'شحن', 'delivery'],
      'دفع': ['دفع', 'payment', 'cash', 'فيزا'],
      'زين': ['زين', 'رايع', 'كويس', 'good', 'nice'],
      'ماكو': ['ماكو', 'ما فيه', 'لا يوجد', 'none'],
    };

    String result = text;
    synonyms.forEach((key, words) {
      for (var word in words) {
        if (result.contains(word)) {
          result = result.replaceAll(word, '$word $key');
        }
      }
    });

    return result;
  }

  static String extractIntent(String text) {
    String processed = preprocessText(text);

    if (processed.contains('زيت') ||
        processed.contains('oil') ||
        processed.contains('اويل')) {
      return 'oil';
    }
    if (processed.contains('صيانة') ||
        processed.contains('maintenance') ||
        processed.contains('خدمة')) {
      return 'maintenance';
    }
    if (processed.contains('طلب') ||
        processed.contains('order') ||
        processed.contains('تتبع')) {
      return 'order';
    }
    if (processed.contains('عرض') ||
        processed.contains('خصم') ||
        processed.contains('offer') ||
        processed.contains('كوبون')) {
      return 'offer';
    }
    if (processed.contains('دفع') ||
        processed.contains('payment') ||
        processed.contains('cash') ||
        processed.contains('فيزا')) {
      return 'payment';
    }
    if (processed.contains('منتج') ||
        processed.contains('product') ||
        processed.contains('فلتر')) {
      return 'product';
    }
    if (processed.contains('مشكلة') ||
        processed.contains('problem') ||
        processed.contains('عطل')) {
      return 'technical';
    }
    if (processed.contains('تواصل') ||
        processed.contains('contact') ||
        processed.contains('اتصال')) {
      return 'contact';
    }
    if (processed.contains('تطبيق') ||
        processed.contains('app') ||
        processed.contains('من نحن')) {
      return 'about';
    }
    if (processed.contains('مرحبا') ||
        processed.contains('hello') ||
        processed.contains('اهلا') ||
        processed.contains('السلام')) {
      return 'greeting';
    }
    if (processed.contains('شكرا') ||
        processed.contains('thanks') ||
        processed.contains('جزيل')) {
      return 'thanks';
    }
    if (processed.contains('bye') ||
        processed.contains('وداع') ||
        processed.contains('مع السلامة')) {
      return 'goodbye';
    }
    if (processed.contains('كم') ||
        processed.contains('بكم') ||
        processed.contains('سعر') ||
        processed.contains('price')) {
      return 'price';
    }

    return 'general';
  }
}

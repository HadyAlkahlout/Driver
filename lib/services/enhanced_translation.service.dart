import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedTranslationService {
  static final Dio _dio = Dio();
  static const String _translateApiUrl =
      'https://translate.googleapis.com/translate_a/single';
  static const String _detectApiUrl =
      'https://translate.googleapis.com/translate_a/single';

  // Cache for translations to avoid repeated API calls
  static final Map<String, String> _translationCache = {};
  static final Map<String, String> _languageCache = {};

  // Supported languages with flags
  static const Map<String, Map<String, String>> supportedLanguages = {
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'es': {'name': 'Spanish', 'flag': '🇪🇸'},
    'fr': {'name': 'French', 'flag': '🇫🇷'},
    'de': {'name': 'German', 'flag': '🇩🇪'},
    'it': {'name': 'Italian', 'flag': '🇮🇹'},
    'pt': {'name': 'Portuguese', 'flag': '🇵🇹'},
    'ru': {'name': 'Russian', 'flag': '🇷🇺'},
    'ja': {'name': 'Japanese', 'flag': '🇯🇵'},
    'ko': {'name': 'Korean', 'flag': '🇰🇷'},
    'zh': {'name': 'Chinese', 'flag': '🇨🇳'},
    'ar': {'name': 'Arabic', 'flag': '🇸🇦'},
    'hi': {'name': 'Hindi', 'flag': '🇮🇳'},
    'th': {'name': 'Thai', 'flag': '🇹🇭'},
    'vi': {'name': 'Vietnamese', 'flag': '🇻🇳'},
    'tr': {'name': 'Turkish', 'flag': '🇹🇷'},
    'pl': {'name': 'Polish', 'flag': '🇵🇱'},
    'nl': {'name': 'Dutch', 'flag': '🇳🇱'},
    'sv': {'name': 'Swedish', 'flag': '🇸🇪'},
    'da': {'name': 'Danish', 'flag': '🇩🇰'},
    'no': {'name': 'Norwegian', 'flag': '🇳🇴'},
    'fi': {'name': 'Finnish', 'flag': '🇫🇮'},
    'cs': {'name': 'Czech', 'flag': '🇨🇿'},
    'hu': {'name': 'Hungarian', 'flag': '🇭🇺'},
    'ro': {'name': 'Romanian', 'flag': '🇷🇴'},
    'bg': {'name': 'Bulgarian', 'flag': '🇧🇬'},
    'hr': {'name': 'Croatian', 'flag': '🇭🇷'},
    'sk': {'name': 'Slovak', 'flag': '🇸🇰'},
    'sl': {'name': 'Slovenian', 'flag': '🇸🇮'},
    'et': {'name': 'Estonian', 'flag': '🇪🇪'},
    'lv': {'name': 'Latvian', 'flag': '🇱🇻'},
    'lt': {'name': 'Lithuanian', 'flag': '🇱🇹'},
    'mt': {'name': 'Maltese', 'flag': '🇲🇹'},
    'ga': {'name': 'Irish', 'flag': '🇮🇪'},
    'cy': {'name': 'Welsh', 'flag': '🏴󠁧󠁢󠁷󠁬󠁳󠁿'},
    'eu': {'name': 'Basque', 'flag': '🇪🇸'},
    'ca': {'name': 'Catalan', 'flag': '🇪🇸'},
    'gl': {'name': 'Galician', 'flag': '🇪🇸'},
    'is': {'name': 'Icelandic', 'flag': '🇮🇸'},
    'mk': {'name': 'Macedonian', 'flag': '🇲🇰'},
    'sq': {'name': 'Albanian', 'flag': '🇦🇱'},
    'sr': {'name': 'Serbian', 'flag': '🇷🇸'},
    'bs': {'name': 'Bosnian', 'flag': '🇧🇦'},
    'me': {'name': 'Montenegrin', 'flag': '🇲🇪'},
    'uk': {'name': 'Ukrainian', 'flag': '🇺🇦'},
    'be': {'name': 'Belarusian', 'flag': '🇧🇾'},
    'kk': {'name': 'Kazakh', 'flag': '🇰🇿'},
    'ky': {'name': 'Kyrgyz', 'flag': '🇰🇬'},
    'uz': {'name': 'Uzbek', 'flag': '🇺🇿'},
    'tg': {'name': 'Tajik', 'flag': '🇹🇯'},
    'mn': {'name': 'Mongolian', 'flag': '🇲🇳'},
    'ka': {'name': 'Georgian', 'flag': '🇬🇪'},
    'hy': {'name': 'Armenian', 'flag': '🇦🇲'},
    'az': {'name': 'Azerbaijani', 'flag': '🇦🇿'},
    'he': {'name': 'Hebrew', 'flag': '🇮🇱'},
    'fa': {'name': 'Persian', 'flag': '🇮🇷'},
    'ur': {'name': 'Urdu', 'flag': '🇵🇰'},
    'bn': {'name': 'Bengali', 'flag': '🇧🇩'},
    'ta': {'name': 'Tamil', 'flag': '🇮🇳'},
    'te': {'name': 'Telugu', 'flag': '🇮🇳'},
    'ml': {'name': 'Malayalam', 'flag': '🇮🇳'},
    'kn': {'name': 'Kannada', 'flag': '🇮🇳'},
    'gu': {'name': 'Gujarati', 'flag': '🇮🇳'},
    'pa': {'name': 'Punjabi', 'flag': '🇮🇳'},
    'or': {'name': 'Odia', 'flag': '🇮🇳'},
    'as': {'name': 'Assamese', 'flag': '🇮🇳'},
    'ne': {'name': 'Nepali', 'flag': '🇳🇵'},
    'si': {'name': 'Sinhala', 'flag': '🇱🇰'},
    'my': {'name': 'Myanmar', 'flag': '🇲🇲'},
    'km': {'name': 'Khmer', 'flag': '🇰🇭'},
    'lo': {'name': 'Lao', 'flag': '🇱🇦'},
    'id': {'name': 'Indonesian', 'flag': '🇮🇩'},
    'ms': {'name': 'Malay', 'flag': '🇲🇾'},
    'tl': {'name': 'Filipino', 'flag': '🇵🇭'},
    'sw': {'name': 'Swahili', 'flag': '🇰🇪'},
    'am': {'name': 'Amharic', 'flag': '🇪🇹'},
    'yo': {'name': 'Yoruba', 'flag': '🇳🇬'},
    'ig': {'name': 'Igbo', 'flag': '🇳🇬'},
    'ha': {'name': 'Hausa', 'flag': '🇳🇬'},
    'zu': {'name': 'Zulu', 'flag': '🇿🇦'},
    'af': {'name': 'Afrikaans', 'flag': '🇿🇦'},
    'xh': {'name': 'Xhosa', 'flag': '🇿🇦'},
    'st': {'name': 'Sesotho', 'flag': '🇱🇸'},
    'tn': {'name': 'Setswana', 'flag': '🇧🇼'},
    'ss': {'name': 'Siswati', 'flag': '🇸🇿'},
    've': {'name': 'Venda', 'flag': '🇿🇦'},
    'ts': {'name': 'Tsonga', 'flag': '🇿🇦'},
    'nr': {'name': 'Ndebele', 'flag': '🇿🇦'},
  };

  /// Initialize the translation service
  static Future<void> initialize() async {
    try {
      // Configure Dio with timeout and retry logic
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      );

      // Add interceptor for retry logic
      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (error, handler) async {
            if (error.response?.statusCode == 429) {
              // Rate limited, wait and retry
              await Future.delayed(const Duration(seconds: 2));
              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, continue with original error
              }
            }
            handler.next(error);
          },
        ),
      );

      debugPrint('Enhanced Translation Service initialized');
    } catch (e) {
      debugPrint('Error initializing Enhanced Translation Service: $e');
    }
  }

  /// Detect the language of the given text
  static Future<String> detectLanguage(String text) async {
    try {
      if (text.trim().isEmpty) return 'en';

      // Check cache first
      if (_languageCache.containsKey(text)) {
        return _languageCache[text]!;
      }

      final response = await _dio.get(
        _detectApiUrl,
        queryParameters: {
          'client': 'gtx',
          'sl': 'auto',
          'tl': 'en',
          'dt': 't',
          'q': text,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List && data.isNotEmpty && data[2] != null) {
          final detectedLang = data[2] as String;
          _languageCache[text] = detectedLang;
          return detectedLang;
        }
      }

      return 'en'; // Default to English if detection fails
    } catch (e) {
      debugPrint('Language detection error: $e');
      return 'en';
    }
  }

  /// Translate text from auto-detected language to target language
  static Future<String> translateText({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    try {
      if (text.trim().isEmpty) return text;

      // Check cache first
      final cacheKey = '${text}_${sourceLanguage}_$targetLanguage';
      if (_translationCache.containsKey(cacheKey)) {
        return _translationCache[cacheKey]!;
      }

      final response = await _dio.get(
        _translateApiUrl,
        queryParameters: {
          'client': 'gtx',
          'sl': sourceLanguage,
          'tl': targetLanguage,
          'dt': 't',
          'q': text,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List && data.isNotEmpty && data[0] is List) {
          final translations = data[0] as List;
          final translatedText = translations
              .map((item) => item[0] as String)
              .join('');

          // Cache the translation
          _translationCache[cacheKey] = translatedText;

          return translatedText;
        }
      }

      return text; // Return original text if translation fails
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  /// Get user's preferred language from shared preferences
  static Future<String> getPreferredLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('preferred_translation_language') ?? 'en';
    } catch (e) {
      debugPrint('Error getting preferred language: $e');
      return 'en';
    }
  }

  /// Set user's preferred language in shared preferences
  static Future<void> setPreferredLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_translation_language', languageCode);
    } catch (e) {
      debugPrint('Error setting preferred language: $e');
    }
  }

  /// Check if auto-translate is enabled
  static Future<bool> isAutoTranslateEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('auto_translate_enabled') ?? false;
    } catch (e) {
      debugPrint('Error checking auto-translate setting: $e');
      return false;
    }
  }

  /// Set auto-translate enabled/disabled
  static Future<void> setAutoTranslateEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_translate_enabled', enabled);
    } catch (e) {
      debugPrint('Error setting auto-translate: $e');
    }
  }

  /// Clear translation cache
  static void clearCache() {
    _translationCache.clear();
    _languageCache.clear();
  }

  /// Get language name from code
  static String getLanguageName(String code) {
    return supportedLanguages[code]?['name'] ?? code.toUpperCase();
  }

  /// Check if language is supported
  static bool isLanguageSupported(String code) {
    return supportedLanguages.containsKey(code);
  }

  /// Get all supported language codes
  static List<String> getSupportedLanguageCodes() {
    return supportedLanguages.keys.toList();
  }

  /// Batch translate multiple texts
  static Future<List<String>> translateBatch({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    final results = <String>[];

    for (final text in texts) {
      final translated = await translateText(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      results.add(translated);
    }

    return results;
  }

  /// Get the selected language for translation
  static Future<String> getSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language') ?? 'en';
    } catch (e) {
      debugPrint('Error getting selected language: $e');
      return 'en';
    }
  }

  /// Set the selected language for translation
  static Future<void> setSelectedLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
    } catch (e) {
      debugPrint('Error setting selected language: $e');
    }
  }
}

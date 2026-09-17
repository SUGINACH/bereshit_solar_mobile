import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';

/// שכבת התקשורת היחידה מול code.js. חשוב: Google Apps Script Web Apps תמיד
/// מחזירים HTTP 200 בפועל (אין להם API לקבוע קוד סטטוס מותאם) - לכן הבדיקה
/// היחידה למי אם הבקשה הצליחה היא שדה ok בתוך גוף ה-JSON, לא סטטוס ה-HTTP.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const _prefsUrlKey = 'webAppUrl';
  static const _prefsKeyKey = 'apiKey';

  String? _baseUrl;
  String? _apiKey;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_prefsUrlKey);
    _apiKey = prefs.getString(_prefsKeyKey);
  }

  Future<bool> get isConfigured async {
    await loadSettings();
    return (_baseUrl != null && _baseUrl!.isNotEmpty && _apiKey != null && _apiKey!.isNotEmpty);
  }

  Future<void> saveSettings({required String webAppUrl, required String apiKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsUrlKey, webAppUrl.trim());
    await prefs.setString(_prefsKeyKey, apiKey.trim());
    _baseUrl = webAppUrl.trim();
    _apiKey = apiKey.trim();
  }

  Future<String?> get webAppUrl async {
    await loadSettings();
    return _baseUrl;
  }

  Uri _buildUri(String api, [Map<String, String>? extra]) {
    if (_baseUrl == null || _apiKey == null) {
      throw ApiException('לא הוגדרו כתובת השרת/מפתח ה-API. יש להגדיר במסך ההגדרות.');
    }
    final params = <String, String>{'api': api, 'apiKey': _apiKey!};
    if (extra != null) params.addAll(extra);
    return Uri.parse(_baseUrl!).replace(queryParameters: params);
  }

  Future<Map<String, dynamic>> _get(String api, [Map<String, String>? extra]) async {
    await loadSettings();
    final uri = _buildUri(api, extra);
    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw ApiException('שגיאת רשת: לא ניתן להגיע לשרת. ודאו חיבור לאינטרנט ושכתובת ה-Web App נכונה.\n($e)');
    }
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('תשובת שרת לא תקינה (לא JSON). ייתכן שכתובת ה-Web App שגויה, או שגרסת הפריסה ישנה.');
    }
    if (body['ok'] != true) {
      throw ApiException(body['error'] as String? ?? 'שגיאה לא ידועה מהשרת.');
    }
    return body;
  }

  Future<List<Customer>> fetchCustomers() async {
    final body = await _get('customers');
    final list = (body['customers'] as List<dynamic>? ?? []);
    return list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// פרטי לקוח מלאים - מפתחות עבריים גולמיים (כמו שהם בגיליון), בדיוק כמו
  /// mapServerCustomerToQuoteData ב-PrintQuote.html. לא ממופה למודל Dart נפרד
  /// כי המסך היחיד שצריך את זה (CustomerDetailScreen) רק מציג שדות בודדים.
  Future<Map<String, dynamic>> fetchCustomerDetail(String clientId) async {
    final body = await _get('customer', {'id': clientId});
    return body['customer'] as Map<String, dynamic>;
  }
}

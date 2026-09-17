/// מודל לקוח קליל - תואם בדיוק לצורת התשובה של apiCustomerList() ב-code.js.
/// בכוונה לא מכיל את כל 32 העמודות (JSON כבדים של שלבי הצריכה/ההמלצה/הפיננסי) -
/// אלה נצפים דרך ה-WebView (אותם דפים מדויקים שכבר קיימים), לא משוכפלים כאן.
class Customer {
  final String clientId;
  final String clientName;
  final String clientAddress;
  final String clientPhone;
  final String projectTitle;
  final bool hasStage1;
  final bool hasStage2;
  final bool hasStage3;

  Customer({
    required this.clientId,
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    required this.projectTitle,
    required this.hasStage1,
    required this.hasStage2,
    required this.hasStage3,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      clientId: json['clientId'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientAddress: json['clientAddress'] as String? ?? '',
      clientPhone: json['clientPhone'] as String? ?? '',
      projectTitle: json['projectTitle'] as String? ?? '',
      hasStage1: json['hasStage1'] as bool? ?? false,
      hasStage2: json['hasStage2'] as bool? ?? false,
      hasStage3: json['hasStage3'] as bool? ?? false,
    );
  }

  /// תיאור קצר של השלב הבא, לתצוגה ברשימה - אותה לוגיקה בדיוק כמו renderStageButtons ב-Index.html
  String get nextStageLabel {
    if (!hasStage1) return 'טרם בוצע ניתוח צריכה';
    if (!hasStage2) return 'ממתין להמלצת גודל מערכת';
    if (!hasStage3) return 'ממתין למודל פיננסי';
    return 'כל השלבים הושלמו';
  }
}

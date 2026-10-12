import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'webview_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  final ApiService apiService;

  const CustomerDetailScreen({super.key, required this.customer, required this.apiService});

  Future<void> _openStage(BuildContext context, String page, String title) async {
    final baseUrl = await apiService.webAppUrl;
    if (baseUrl == null) return;
    final url = '$baseUrl?page=$page&clientId=${Uri.encodeComponent(customer.clientId)}';

    // במחשבי ווינדוס: פותח ישירות בדפדפן הרגיל של המחשב (מונע קריסה ומאפשר עבודה נוחה)
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // בטלפונים (אנדרואיד / אייפון): ממשיך כרגיל בתוך ה-WebView המובנה
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WebViewScreen(url: url, title: title),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(customer.clientName.isEmpty ? customer.clientId : customer.clientName)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('מזהה', customer.clientId),
                    _infoRow('כתובת', customer.clientAddress),
                    _infoRow('טלפון', customer.clientPhone),
                    _infoRow('פרויקט', customer.projectTitle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(customer.nextStageLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            if (!customer.hasStage1)
              _stageButton(context, '🔍 התחל ניתוח צריכה (שלב 1)', Colors.blue,
                  () => _openStage(context, 'consumption', 'שלב 1 - ניתוח צריכה'))
            else if (!customer.hasStage2) ...[
              _stageButton(context, '➡️ המשך להמלצת גודל מערכת (שלב 2)', Colors.purple,
                  () => _openStage(context, 'sizing', 'שלב 2 - המלצת גודל')),
              _stageButton(context, '✏️ ערוך ניתוח צריכה', Colors.blue.shade100,
                  () => _openStage(context, 'consumption', 'שלב 1 - ניתוח צריכה'),
                  textColor: Colors.blue),
            ] else if (!customer.hasStage3) ...[
              _stageButton(context, '➡️ המשך למודל פיננסי (שלב 3)', Colors.green,
                  () => _openStage(context, 'finance', 'שלב 3 - מודל פיננסי')),
              _stageButton(context, '✏️ ערוך המלצת גודל', Colors.purple.shade100,
                  () => _openStage(context, 'sizing', 'שלב 2 - המלצת גודל'),
                  textColor: Colors.purple),
            ] else ...[
              _stageButton(context, '📈 פתח מודל פיננסי (שלב 3)', Colors.green,
                  () => _openStage(context, 'finance', 'שלב 3 - מודל פיננסי')),
              _stageButton(context, '🖨️ פתח הצעת מחיר', Colors.orange,
                  () => _openStage(context, 'print', 'הצעת מחיר')),
            ],

            const Divider(height: 32),
            _stageButton(context, '📝 פתח את הטופס לשליחה ללקוח', Colors.grey.shade300,
                () => _openStage(context, 'form', 'טופס נתוני צריכה'),
                textColor: Colors.black87),
            _stageButton(context, '🖥️ פתח את כרטיס הלקוח המלא (CRM)', Colors.grey.shade300,
                () async {
              final baseUrl = await apiService.webAppUrl;
              if (baseUrl == null) return;
              final url = '$baseUrl?clientId=${Uri.encodeComponent(customer.clientId)}';

              if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
                return;
              }

              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WebViewScreen(
                  url: url,
                  title: 'כרטיס לקוח מלא',
                ),
              ));
            }, textColor: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _stageButton(BuildContext context, String label, Color color, VoidCallback onPressed, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onPressed,
          child: Text(label),
        ),
      ),
    );
  }
}

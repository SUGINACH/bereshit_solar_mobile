import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onSaved;

  const SettingsScreen({super.key, required this.apiService, required this.onSaved});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final url = await widget.apiService.webAppUrl;
    if (url != null) setState(() => _urlController.text = url);
  }

  Future<void> _save() async {
    if (_urlController.text.trim().isEmpty || _keyController.text.trim().isEmpty) {
      setState(() => _error = 'יש למלא גם כתובת וגם מפתח.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await widget.apiService.saveSettings(
        webAppUrl: _urlController.text,
        apiKey: _keyController.text,
      );
      // בדיקת חיבור מיידית - מוודאים שההגדרות תקינות לפני שממשיכים
      await widget.apiService.fetchCustomers();
      if (mounted) widget.onSaved();
    } on ApiException catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('הגדרות חיבור')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'הזינו את כתובת ה-Web App של בראשית סולאר (מ-Apps Script: Deploy → Manage deployments), '
                'ואת מפתח ה-API שהוגדר שם ע"י setApiKey_oneTime().',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'כתובת ה-Web App',
                  hintText: 'https://script.google.com/macros/s/.../exec',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'מפתח API',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('שמור ובדוק חיבור'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

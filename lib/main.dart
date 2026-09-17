import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/customer_list_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const BereshitSolarApp());
}

class BereshitSolarApp extends StatelessWidget {
  const BereshitSolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'בראשית סולאר',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3A5F)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A3A5F), foregroundColor: Colors.white),
      ),
      home: const _StartupGate(),
    );
  }
}

/// בעליית האפליקציה בודקים אם כבר הוגדרו כתובת ה-Web App ומפתח ה-API -
/// אם לא, מפנים ישר למסך ההגדרות (הרצה ראשונה); אם כן, ישר לרשימת הלקוחות.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  final _apiService = ApiService();
  bool _checking = true;
  bool _configured = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final configured = await _apiService.isConfigured;
    setState(() {
      _configured = configured;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_configured) {
      return SettingsScreen(
        apiService: _apiService,
        onSaved: () => setState(() => _configured = true),
      );
    }
    return CustomerListScreen(apiService: _apiService);
  }
}

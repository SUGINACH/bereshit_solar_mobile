import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import 'customer_detail_screen.dart';
import 'settings_screen.dart';

class CustomerListScreen extends StatefulWidget {
  final ApiService apiService;

  const CustomerListScreen({super.key, required this.apiService});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> _all = [];
  List<Customer> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final customers = await widget.apiService.fetchCustomers();
      setState(() {
        _all = customers;
        _filtered = customers;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchController.text.trim();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((c) =>
              c.clientName.contains(q) ||
              c.clientId.contains(q) ||
              c.clientPhone.contains(q)).toList();
    });
  }

  Color _stageColor(Customer c) {
    if (!c.hasStage1) return Colors.grey;
    if (!c.hasStage2) return Colors.blue;
    if (!c.hasStage3) return Colors.purple;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('בראשית סולאר - לקוחות'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsScreen(apiService: widget.apiService, onSaved: () {
                  Navigator.of(context).pop();
                  _load();
                }),
              )),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'חיפוש לפי שם, מזהה או טלפון...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('נסה שוב')),
            ],
          ),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(child: Text('לא נמצאו לקוחות התואמים לחיפוש.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = _filtered[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: _stageColor(c), child: const Icon(Icons.person, color: Colors.white)),
            title: Text(c.clientName.isEmpty ? c.clientId : c.clientName),
            subtitle: Text('${c.clientId} · ${c.nextStageLabel}'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CustomerDetailScreen(customer: c, apiService: widget.apiService),
            )),
          );
        },
      ),
    );
  }
}

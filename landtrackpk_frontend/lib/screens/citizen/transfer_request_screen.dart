import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class TransferRequestScreen extends StatefulWidget {
  const TransferRequestScreen({super.key});

  @override
  State<TransferRequestScreen> createState() => _TransferRequestScreenState();
}

class _TransferRequestScreenState extends State<TransferRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plotController = TextEditingController();
  final _toCnicController = TextEditingController();
  final _reasonController = TextEditingController();
  String _fromCnic = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCnic();
  }

  Future<void> _loadCnic() async {
    final cnic = await SessionService.getCnic() ?? '';
    if (mounted) setState(() => _fromCnic = cnic);
  }

  @override
  void dispose() {
    _plotController.dispose();
    _toCnicController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.createTransferRequest(
        plotNumber: _plotController.text.trim(),
        fromCnic: _fromCnic,
        toCnic: _toCnicController.text.trim(),
        reason: _reasonController.text.trim(),
      );
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Transfer request submitted! ID: ${result['transfer_id']}'),
          backgroundColor: const Color(0xFF1A5C2A), behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Error'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Request (Intiqal)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Transfer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _fromCnic, readOnly: true,
                  decoration: const InputDecoration(labelText: 'From CNIC (You)', prefixIcon: Icon(Icons.credit_card_rounded), filled: true, fillColor: Color(0xFFF5F5F5)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plotController,
                  decoration: const InputDecoration(labelText: 'Plot Number', hintText: 'e.g. LHR-2024-001', prefixIcon: Icon(Icons.landscape_rounded)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Plot number is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _toCnicController, keyboardType: TextInputType.number, maxLength: 13,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'To CNIC (New Owner)', prefixIcon: Icon(Icons.person_add_rounded), counterText: ''),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'CNIC is required';
                    if (v.length != 13) return 'CNIC must be exactly 13 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController, maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Reason for Transfer', prefixIcon: Icon(Icons.description_rounded), alignLabelWithHint: true),
                  validator: (v) => (v == null || v.isEmpty) ? 'Reason is required' : null,
                ),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 52, child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('SUBMIT TRANSFER REQUEST'),
            )),
          ]),
        ),
      ),
    );
  }
}

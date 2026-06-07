import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bilingual_label.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/step_progress_indicator.dart';

class TransferRequestScreen extends StatefulWidget {
  const TransferRequestScreen({super.key});

  @override
  State<TransferRequestScreen> createState() => _TransferRequestScreenState();
}

class _TransferRequestScreenState extends State<TransferRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  final _plotController = TextEditingController();
  final _toCnicController = TextEditingController();
  final _reasonController = TextEditingController();
  
  String _fromCnic = '';
  bool _isLoading = false;

  final List<String> _stepLabels = ['Plot', 'Buyer', 'Docs', 'Review'];

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
    _pageController.dispose();
    _plotController.dispose();
    _toCnicController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_currentStep == 0 && _plotController.text.trim().isEmpty) {
        _showSnackBar('Plot number is required', AppColors.error);
        return;
      }
      if (_currentStep == 1 && _toCnicController.text.trim().length != 15) {
        _showSnackBar('Valid CNIC is required', AppColors.error);
        return;
      }
      if (_currentStep == 2 && _reasonController.text.trim().isEmpty) {
        _showSnackBar('Reason is required', AppColors.error);
        return;
      }

      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
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
        _showSuccessDialog(result['transfer_id'].toString());
      } else {
        _showSnackBar(result['message'] ?? 'Error', AppColors.error);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String transferId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: AppSpacing.md),
            const BilingualLabel(
              englishText: 'TRANSFER SUBMITTED',
              urduText: 'انتقال جمع ہو گیا',
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Request ID: $transferId', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('DONE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Request (Intiqal)')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.edgeMargin),
              child: StepProgressIndicator(
                totalSteps: 4,
                currentStep: _currentStep,
                stepLabels: _stepLabels,
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.edgeMargin),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        child: const Text('BACK'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _nextStep,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.onPrimary))
                          : Text(_currentStep == 3 ? 'SUBMIT REQUEST' : 'NEXT'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
      child: CertificateCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BilingualLabel(englishText: 'SELECT PROPERTY', urduText: 'جائیداد منتخب کریں'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _plotController,
              decoration: const InputDecoration(
                labelText: 'Plot Number',
                hintText: 'e.g. LHR-2024-001',
                prefixIcon: Icon(Icons.landscape_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Only properties registered to $_fromCnic can be transferred.', style: const TextStyle(fontSize: 12))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
      child: CertificateCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BilingualLabel(englishText: 'BUYER DETAILS', urduText: 'خریدار کی تفصیلات'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _toCnicController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CnicFormatter()],
              decoration: const InputDecoration(
                labelText: 'Buyer CNIC Number',
                hintText: '00000-0000000-0',
                prefixIcon: Icon(Icons.person_add_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
      child: CertificateCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BilingualLabel(englishText: 'TRANSFER REASON', urduText: 'انتقال کی وجہ'),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason for Transfer',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const BilingualLabel(englishText: 'UPLOAD DOCUMENTS', urduText: 'دستاویزات اپ لوڈ کریں'),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _showSnackBar('Simulated upload', AppColors.primary),
              icon: const Icon(Icons.upload_file),
              label: const Text('CHOOSE FILE (PDF/JPG)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edgeMargin),
      child: CertificateCard(
        hasGuilloche: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BilingualLabel(englishText: 'REVIEW REQUEST', urduText: 'درخواست کا جائزہ'),
            const Divider(),
            _buildReviewRow('Property', _plotController.text),
            _buildReviewRow('From (You)', _fromCnic),
            _buildReviewRow('To (Buyer)', _toCnicController.text),
            _buildReviewRow('Reason', _reasonController.text),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'By submitting this request, you declare that all provided information is accurate and legally binding. False claims may result in legal action.',
                style: TextStyle(fontSize: 12, color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _CnicFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 5 == 0 && nonZeroIndex != text.length && nonZeroIndex < 6) {
        buffer.write('-');
      } else if (nonZeroIndex == 12 && nonZeroIndex != text.length) {
        buffer.write('-');
      }
    }

    var string = buffer.toString();
    if (string.length > 15) return oldValue;

    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

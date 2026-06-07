import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bilingual_label.dart';
import '../../widgets/certificate_card.dart';

class BookAppointmentScreen extends StatefulWidget {
  final int citizenId;
  const BookAppointmentScreen({super.key, required this.citizenId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCenter = 'DMM Nankana Sahib';
  String _selectedTehsil = 'Nankana Sahib';
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 am';
  bool _isLoading = false;

  final List<String> _centers = [
    'DMM Nankana Sahib',
    'Lahore Model Town',
    'Rawalpindi Cantt',
    'Faisalabad City',
    'Multan Central',
    'Peshawar City',
  ];

  final List<String> _tehsils = [
    'Nankana Sahib',
    'Lahore Model Town',
    'Rawalpindi',
    'Sammundri',
    'Shujabad',
    'Peshawar City',
  ];

  final List<String> _timeSlots = [
    '09:00 am', '10:00 am', '11:00 am', '12:00 pm',
    '01:00 pm', '02:00 pm', '03:00 pm', '04:00 pm',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final result = await ApiService.bookAppointment(
        citizenId: widget.citizenId,
        serviceCenter: _selectedCenter,
        tehsil: _selectedTehsil,
        reason: _reasonController.text.trim(),
        appointmentDate: dateStr,
        appointmentTime: _selectedTime,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        _showTokenDialog(result['token_number'] ?? '');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTokenDialog(String token) {
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
              englishText: 'APPOINTMENT CONFIRMED',
              urduText: 'وقت مقرر ہو گیا',
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Your Token Number', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                token,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onPrimary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$_selectedCenter\n${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at $_selectedTime',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Form(
          key: _formKey,
          child: CertificateCard(
            hasGuilloche: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BilingualLabel(
                  englishText: 'APPOINTMENT DETAILS',
                  urduText: 'تفصیلات',
                ),
                const Divider(color: AppColors.tertiary),
                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<String>(
                  value: _selectedCenter,
                  decoration: const InputDecoration(
                    labelText: 'Service Center',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: _centers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCenter = v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<String>(
                  value: _selectedTehsil,
                  decoration: const InputDecoration(
                    labelText: 'Tehsil',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: _tehsils.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTehsil = v);
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: _reasonController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Visit',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Reason is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                GestureDetector(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Appointment Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<String>(
                  value: _selectedTime,
                  decoration: const InputDecoration(
                    labelText: 'Time Slot',
                    prefixIcon: Icon(Icons.access_time_outlined),
                  ),
                  items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTime = v);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary),
                          )
                        : const Text('BOOK APPOINTMENT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

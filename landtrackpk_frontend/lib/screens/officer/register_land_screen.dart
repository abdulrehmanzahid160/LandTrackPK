import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/bilingual_label.dart';

class RegisterLandScreen extends StatefulWidget {
  const RegisterLandScreen({super.key});

  @override
  State<RegisterLandScreen> createState() => _RegisterLandScreenState();
}

class _RegisterLandScreenState extends State<RegisterLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plotNumberController = TextEditingController();
  final _areaController = TextEditingController();
  final _districtController = TextEditingController();
  final _tehsilController = TextEditingController();
  final _ownerCnicController = TextEditingController();

  String _selectedAreaUnit = 'Marla';
  String _selectedLandType = 'Residential';
  bool _isLoading = false;

  @override
  void dispose() {
    _plotNumberController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _tehsilController.dispose();
    _ownerCnicController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final area = double.parse(_areaController.text.trim());
      final result = await ApiService.registerLand(
        plotNumber: _plotNumberController.text.trim(),
        area: area,
        areaUnit: _selectedAreaUnit,
        landType: _selectedLandType,
        district: _districtController.text.trim(),
        tehsil: _tehsilController.text.trim(),
        ownerCnic: _ownerCnicController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['message']} (Plot: ${_plotNumberController.text.trim()})'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Land')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.edgeMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CertificateCard(
                  hasGuilloche: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BilingualLabel(englishText: 'LAND REGISTRY INFORMATION', urduText: 'اراضی کی معلومات'),
                      const Divider(color: AppColors.tertiary),
                      const SizedBox(height: AppSpacing.md),

                      // Plot Number
                      TextFormField(
                        controller: _plotNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Plot Number',
                          hintText: 'e.g. LHR-2024-001',
                          prefixIcon: Icon(Icons.tag_outlined),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Plot Number is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Area & Unit Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _areaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Area',
                                prefixIcon: Icon(Icons.straighten_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                if (double.tryParse(value) == null) return 'Invalid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedAreaUnit,
                              decoration: const InputDecoration(labelText: 'Unit'),
                              items: const [
                                DropdownMenuItem(value: 'Marla', child: Text('Marla')),
                                DropdownMenuItem(value: 'Kanal', child: Text('Kanal')),
                              ],
                              onChanged: (value) {
                                if (value != null) setState(() => _selectedAreaUnit = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Land Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedLandType,
                        decoration: const InputDecoration(
                          labelText: 'Land Type',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Agricultural', child: Text('Agricultural')),
                          DropdownMenuItem(value: 'Residential', child: Text('Residential')),
                          DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedLandType = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // District
                      TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(
                          labelText: 'District',
                          hintText: 'e.g. Lahore',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'District is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Tehsil
                      TextFormField(
                        controller: _tehsilController,
                        decoration: const InputDecoration(
                          labelText: 'Tehsil',
                          hintText: 'e.g. Shalimar',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Tehsil is required'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Owner CNIC
                      TextFormField(
                        controller: _ownerCnicController,
                        keyboardType: TextInputType.number,
                        maxLength: 13,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Owner CNIC',
                          hintText: '13-digit CNIC of active owner',
                          prefixIcon: Icon(Icons.person_outlined),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Owner CNIC is required';
                          if (value.length != 13) return 'CNIC must be exactly 13 digits';
                          return null;
                        },
                      ),
                    ],
                  ),
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
                        : const Text('REGISTER LAND'),
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

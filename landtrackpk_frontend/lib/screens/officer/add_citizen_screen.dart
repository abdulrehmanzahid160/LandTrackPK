import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/certificate_card.dart';

class AddCitizenScreen extends StatefulWidget {
  const AddCitizenScreen({super.key});

  @override
  State<AddCitizenScreen> createState() => _AddCitizenScreenState();
}

class _AddCitizenScreenState extends State<AddCitizenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Citizen';
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.addCitizen(
        fullName: _fullNameController.text.trim(),
        cnic: _cnicController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Citizen registered successfully! ID: ${result['citizen_id']}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add citizen'),
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
      appBar: AppBar(title: const Text('Add Citizen Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.edgeMargin),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CertificateCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Full Name is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // CNIC
                    TextFormField(
                      controller: _cnicController,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'CNIC',
                        hintText: '13-digit CNIC number',
                        prefixIcon: Icon(Icons.credit_card_outlined),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'CNIC is required';
                        if (value.length != 13) return 'CNIC must be exactly 13 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g. 03211234567',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Phone number is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    const Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    // Street
                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Street address is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // City & Postal Code Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'City is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _postalCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Postal Code',
                              prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                            ),
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Postal code is required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // District
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'District is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    const Text(
                      'Security & Role',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Citizen', child: Text('Citizen')),
                        DropdownMenuItem(value: 'Officer', child: Text('Officer')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
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
                      : const Text('CREATE PROFILE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

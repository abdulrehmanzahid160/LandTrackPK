import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

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
            backgroundColor: const Color(0xFF1A5C2A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Land Registry Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Plot Number
                    TextFormField(
                      controller: _plotNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Plot Number',
                        hintText: 'e.g. LHR-2024-001',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Plot Number is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

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
                              prefixIcon: Icon(Icons.straighten_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedAreaUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Marla', child: Text('Marla')),
                              DropdownMenuItem(value: 'Kanal', child: Text('Kanal')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedAreaUnit = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Land Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedLandType,
                      decoration: const InputDecoration(
                        labelText: 'Land Type',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Agricultural', child: Text('Agricultural')),
                        DropdownMenuItem(value: 'Residential', child: Text('Residential')),
                        DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLandType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // District
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        hintText: 'e.g. Lahore',
                        prefixIcon: Icon(Icons.location_city_rounded),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'District is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Tehsil
                    TextFormField(
                      controller: _tehsilController,
                      decoration: const InputDecoration(
                        labelText: 'Tehsil',
                        hintText: 'e.g. Shalimar',
                        prefixIcon: Icon(Icons.map_rounded),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Tehsil is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Owner CNIC
                    TextFormField(
                      controller: _ownerCnicController,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Owner CNIC',
                        hintText: '13-digit CNIC of active owner',
                        prefixIcon: Icon(Icons.person_rounded),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Owner CNIC is required';
                        }
                        if (value.length != 13) {
                          return 'CNIC must be exactly 13 digits';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('REGISTER LAND'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

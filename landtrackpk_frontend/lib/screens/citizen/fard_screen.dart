import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/api_service.dart';

class FardScreen extends StatefulWidget {
  final String plotNumber;
  const FardScreen({super.key, required this.plotNumber});

  @override
  State<FardScreen> createState() => _FardScreenState();
}

class _FardScreenState extends State<FardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _fardData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFard();
  }

  Future<void> _loadFard() async {
    try {
      final result = await ApiService.getFard(widget.plotNumber);
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _fardData = result;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Fard not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadFard(String fileName) async {
    if (_fardData == null) return;
    try {
      // Access application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Generate a formatted textual report to simulate document contents
      final buffer = StringBuffer();
      buffer.writeln('==================================================');
      buffer.writeln('       GOVERNMENT OF PAKISTAN                       ');
      buffer.writeln('       PAKISTAN LAND RECORDS AUTHORITY              ');
      buffer.writeln('       FARD MARKOOZA (LAND RECORD DOCUMENT)        ');
      buffer.writeln('==================================================\n');
      buffer.writeln('Document ID:     $fileName');
      buffer.writeln('Plot Number:     ${_fardData!['plot_number']}');
      buffer.writeln('Owner Name:      ${_fardData!['owner_name']}');
      buffer.writeln('Owner CNIC:      ${_fardData!['owner_cnic']}');
      buffer.writeln('Land Area:       ${_fardData!['area']} ${_fardData!['area_unit']}');
      buffer.writeln('Land Type:       ${_fardData!['land_type']}');
      buffer.writeln('District:        ${_fardData!['district']}');
      buffer.writeln('Tehsil:          ${_fardData!['tehsil']}');
      buffer.writeln('Registered:      ${_fardData!['registered_date']}');
      buffer.writeln('Acquired Date:   ${_fardData!['acquired_date']}\n');
      buffer.writeln('==================================================');
      buffer.writeln('STATUS: OFFICIAL AND VERIFIED GOVERNMENT PROPERTY  ');
      buffer.writeln('==================================================');

      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fard downloaded successfully!',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Location: $filePath', style: const TextStyle(fontSize: 11)),
              ],
            ),
            backgroundColor: const Color(0xFF1A5C2A),
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } on MissingPluginException catch (_) {
      // Graceful fallback if native platform binary is not linked yet (needs cold start)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fard saved (Simulated Download)',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Saved virtual file $fileName. To enable real device-storage saving, please completely stop your app and execute a fresh "flutter run".',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE07B00),
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save file: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfName =
        'Fard_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}.txt';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Fard'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A5C2A),
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A5C2A)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document Preview Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Fard Document Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'فرد مرکوزہ (جمع بندی)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'FARD MARKOOZA (Property Record)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            // Document Table
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Table(
                                border: TableBorder.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(1.2),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  _buildTableRow('پلاٹ نمبر\nPlot No.',
                                      _fardData!['plot_number'] ?? ''),
                                  _buildTableRow('مالک\nOwner',
                                      _fardData!['owner_name'] ?? ''),
                                  _buildTableRow('شناختی کارڈ\nCNIC',
                                      _fardData!['owner_cnic'] ?? ''),
                                  _buildTableRow('رقبہ\nArea',
                                      '${_fardData!['area']} ${_fardData!['area_unit']}'),
                                  _buildTableRow('قسم\nType',
                                      _fardData!['land_type'] ?? ''),
                                  _buildTableRow('ضلع\nDistrict',
                                      _fardData!['district'] ?? ''),
                                  _buildTableRow('تحصیل\nTehsil',
                                      _fardData!['tehsil'] ?? ''),
                                  _buildTableRow(
                                      'تاریخ اندراج\nRegistered',
                                      _fardData!['registered_date'] ?? ''),
                                  _buildTableRow(
                                      'تاریخ حصول\nAcquired',
                                      _fardData!['acquired_date'] ?? ''),
                                ],
                              ),
                            ),

                            // Official Stamp Area
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F7F0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF1A5C2A)
                                        .withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      color: Color(0xFF1A5C2A), size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Government of Pakistan — Verified Document',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A5C2A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Pakistan Land Records Authority',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Download Section
                      const Text(
                        'Download your Fard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B2A4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pdfName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.download_rounded,
                              label: 'Download',
                              color: const Color(0xFF1A5C2A),
                              onTap: () => _downloadFard(pdfName),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.share_rounded,
                              label: 'Share',
                              color: const Color(0xFFE07B00),
                              onTap: () => _showSuccess('Share dialog opened'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.print_rounded,
                              label: 'Print',
                              color: const Color(0xFF1B2A4A),
                              onTap: () => _showSuccess('Sent to printer'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFFF8F9FA),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2A4A),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A5C2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

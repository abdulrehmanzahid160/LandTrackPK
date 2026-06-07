import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/bilingual_label.dart';
import '../../widgets/verified_seal.dart';
import '../../utils/image_helpers.dart';

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
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

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
        _showSnackBar('Fard downloaded to: $filePath', AppColors.success);
      }
    } on MissingPluginException catch (_) {
      if (mounted) {
        _showSnackBar('Simulated Download: $fileName', AppColors.tertiary);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save file: $e', AppColors.error);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfName = 'Fard_${widget.plotNumber}_${DateTime.now().millisecondsSinceEpoch}.txt';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fard Document'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                    child: Column(
                      children: [
                        CertificateCard(
                          hasGuilloche: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const BilingualLabel(
                                englishText: 'FARD MARKOOZA',
                                urduText: 'فرد مرکوزہ',
                              ),
                              const Divider(color: AppColors.tertiary),
                              const SizedBox(height: AppSpacing.md),
                              
                              Table(
                                border: TableBorder.all(color: AppColors.outlineVariant),
                                children: [
                                  _buildRow('Plot No.', 'پلاٹ نمبر', _fardData!['plot_number'] ?? ''),
                                  _buildRow('Owner', 'مالک', _fardData!['owner_name'] ?? ''),
                                  _buildRow('CNIC', 'شناختی کارڈ', _fardData!['owner_cnic'] ?? ''),
                                  _buildRow('Area', 'رقبہ', '${_fardData!['area']} ${_fardData!['area_unit']}'),
                                  _buildRow('Land Type', 'قسم', _fardData!['land_type'] ?? ''),
                                  _buildRow('District', 'ضلع', _fardData!['district'] ?? ''),
                                  _buildRow('Tehsil', 'تحصیل', _fardData!['tehsil'] ?? ''),
                                  _buildRow('Registered', 'تاریخ اندراج', _fardData!['registered_date'] ?? ''),
                                  _buildRow('Acquired', 'تاریخ حصول', _fardData!['acquired_date'] ?? ''),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: ImageHelpers.qrCode('LandTrackPK-FARD-${_fardData!['plot_number']}-OWNER-${_fardData!['owner_cnic']}-VERIFIED', size: 80),
                                    width: 70,
                                    height: 70,
                                    placeholder: (_, __) => const SizedBox(width: 70, height: 70, child: Center(child: CircularProgressIndicator())),
                                    errorWidget: (_, __, ___) => const Icon(Icons.qr_code, size: 70),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  const VerifiedSeal(size: 60),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      'VERIFIED BY PAKISTAN LAND RECORDS AUTHORITY',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.tertiary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _downloadFard(pdfName),
                                icon: const Icon(Icons.download),
                                label: const Text('DOWNLOAD'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  TableRow _buildRow(String eng, String urdu, String val) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eng, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(urdu, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Text(val, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

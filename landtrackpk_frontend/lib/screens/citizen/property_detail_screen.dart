import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_service.dart';
import '../../models/land_parcel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/bilingual_label.dart';
import '../../widgets/stamp_badge.dart';
import '../../utils/image_helpers.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String plotNumber;
  const PropertyDetailScreen({super.key, required this.plotNumber});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isLoading = true;
  LandParcel? _parcel;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final result = await ApiService.getProperty(widget.plotNumber);
      if (mounted) {
        if (result['success'] == true) {
          setState(() { _parcel = LandParcel.fromJson(result); _isLoading = false; });
        } else {
          setState(() { _error = result['message'] ?? 'Plot not found'; _isLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Connection error: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(_error!, style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // satellite plot view
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: ImageHelpers.propertyPhoto(w: 800, h: 400, keywords: 'satellite,map,farmland,agriculture'),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(height: 180, color: Colors.white),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 180,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.map, size: 48, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildInfoCard(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildOwnerCard(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildVerificationCard(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildHistorySection(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final p = _parcel!;
    return CertificateCard(
      hasGuilloche: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.plotNumber,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const StampBadge(status: StampStatus.verified, customText: 'ACTIVE'),
            ],
          ),
          const Divider(height: AppSpacing.xl, color: AppColors.tertiary),
          _detailRow(Icons.straighten_outlined, 'Area', '${p.area} ${p.areaUnit}'),
          _detailRow(Icons.category_outlined, 'Land Type', p.landType),
          _detailRow(Icons.location_city_outlined, 'District', p.district),
          _detailRow(Icons.map_outlined, 'Tehsil', p.tehsil),
          _detailRow(Icons.calendar_today_outlined, 'Registered', p.registeredDate),
        ],
      ),
    );
  }

  Widget _buildOwnerCard() {
    final p = _parcel!;
    return CertificateCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BilingualLabel(englishText: 'CURRENT OWNER', urduText: 'موجودہ مالک'),
          const Divider(color: AppColors.tertiary),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryContainer,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: ImageHelpers.avatar(p.ownerName ?? 'Owner', size: 100),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.ownerName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('CNIC: ${p.ownerCnic ?? 'N/A'}', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _detailRow(Icons.date_range_outlined, 'Acquired', p.acquiredDate ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    final p = _parcel!;
    return CertificateCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BilingualLabel(englishText: 'SECURE VERIFICATION', urduText: 'محفوظ تصدیق'),
          const Divider(color: AppColors.tertiary),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: ImageHelpers.qrCode('LandTrackPK-Plot-${p.plotNumber}-Owner-${p.ownerCnic}-VERIFIED', size: 100),
                width: 90,
                height: 90,
                placeholder: (_, __) => const SizedBox(width: 90, height: 90, child: Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => const Icon(Icons.qr_code, size: 90),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sovereign Ledger Record', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      'This QR Code contains the cryptographically signed record hash from the state land ledger registry.',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final history = _parcel!.history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BilingualLabel(englishText: 'OWNERSHIP HISTORY', urduText: 'ملکیت کی تاریخ'),
        const SizedBox(height: AppSpacing.md),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: AppDecorations.officialCard,
            child: const Column(
              children: [
                Icon(Icons.history, size: 40, color: AppColors.outline),
                SizedBox(height: AppSpacing.sm),
                Text('No transfer history found'),
              ],
            ),
          )
        else
          ...history.map((h) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.officialCard,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.swap_horiz, color: AppColors.tertiary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${h['previous_owner']} → ${h['new_owner']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            h['transfer_date'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

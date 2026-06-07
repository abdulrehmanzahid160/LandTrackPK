import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/bilingual_label.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final int complaintId;
  final String citizenName;
  const ComplaintDetailsScreen({super.key, required this.complaintId, required this.citizenName});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _complaint;
  List<Map<String, dynamic>> _comments = [];
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      final result = await ApiService.getComplaintDetails(widget.complaintId);
      if (mounted && result['success'] == true) {
        setState(() {
          _complaint = result['complaint'];
          _comments = List<Map<String, dynamic>>.from(result['comments'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ApiService.addComplaintComment(
        complaintId: widget.complaintId,
        senderType: 'Complainant',
        senderName: widget.citizenName,
        commentText: text,
      );
      _commentController.clear();
      await _loadDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _complaint != null
              ? 'Complaint No. ${_complaint!['complaint_id']}'
              : 'Complaint Details',
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _complaint == null
                ? const Center(child: Text('Complaint not found'))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.edgeMargin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CertificateCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const BilingualLabel(englishText: 'COMPLAINT INFO', urduText: 'شکایت کی تفصیل'),
                                    const Divider(color: AppColors.tertiary),
                                    const SizedBox(height: AppSpacing.sm),
                                    
                                    Text('Complaint Type', style: Theme.of(context).textTheme.labelSmall),
                                    Text(_complaint!['complaint_type'] ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: AppSpacing.md),

                                    Text('Complaint Details', style: Theme.of(context).textTheme.labelSmall),
                                    Text(_complaint!['details'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(height: AppSpacing.md),

                                    Text(
                                      'Submitted on: ${(_complaint!['submitted_date'] ?? '').toString().split('.').first}',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xl),
                              
                              const BilingualLabel(englishText: 'UPLOADED FILES', urduText: 'منسلک فائلیں'),
                              const SizedBox(height: AppSpacing.md),
                              
                              Row(
                                children: [
                                  if ((_complaint!['attachment_path'] ?? '').toString().isNotEmpty)
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.outlineVariant),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.picture_as_pdf_outlined, color: AppColors.error, size: 28),
                                          Text('PDF', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8)),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.outlineVariant),
                                    ),
                                    child: const Icon(Icons.add, color: AppColors.outline, size: 28),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              const BilingualLabel(englishText: 'COMMENTS', urduText: 'تبصرے'),
                              const SizedBox(height: AppSpacing.md),

                              ..._comments.map((c) {
                                final isComplainant = c['sender_type'] == 'Complainant';
                                return _ChatBubble(
                                  senderName: isComplainant ? 'Complainant' : 'Service Rep',
                                  message: c['comment_text'] ?? '',
                                  date: (c['comment_date'] ?? '').toString().split('.').first,
                                  isComplainant: isComplainant,
                                );
                              }),

                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Comment Input
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                                  ),
                                  onSubmitted: (_) => _sendComment(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Material(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  onTap: _isSending ? null : _sendComment,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    child: _isSending
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                                          )
                                        : const Icon(Icons.send, color: AppColors.onPrimary, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String senderName;
  final String message;
  final String date;
  final bool isComplainant;

  const _ChatBubble({
    required this.senderName,
    required this.message,
    required this.date,
    required this.isComplainant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: AppSpacing.sm,
        left: isComplainant ? 0 : 40,
        right: isComplainant ? 40 : 0,
      ),
      child: Column(
        crossAxisAlignment: isComplainant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: isComplainant ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Text(
                  senderName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isComplainant ? AppColors.primary : AppColors.tertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(date, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isComplainant ? AppColors.surface : AppColors.tertiaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isComplainant ? 4 : 16),
                topRight: Radius.circular(isComplainant ? 16 : 4),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              border: isComplainant ? Border.all(color: AppColors.outlineVariant) : null,
            ),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isComplainant ? AppColors.onSurface : AppColors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

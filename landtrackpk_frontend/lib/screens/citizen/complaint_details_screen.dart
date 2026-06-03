import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final int complaintId;
  final String citizenName;
  const ComplaintDetailsScreen(
      {super.key, required this.complaintId, required this.citizenName});

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
      final result =
          await ApiService.getComplaintDetails(widget.complaintId);
      if (mounted && result['success'] == true) {
        setState(() {
          _complaint = result['complaint'];
          _comments =
              List<Map<String, dynamic>>.from(result['comments'] ?? []);
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          _complaint != null
              ? 'Complaint No. ${_complaint!['complaint_id']}'
              : 'Complaint Details',
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A5C2A),
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A5C2A)))
          : _complaint == null
              ? const Center(child: Text('Complaint not found'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Complaint Info Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Complaint Type
                                  Text(
                                    'Complaint Type',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _complaint!['complaint_type'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Complaint Details
                                  Text(
                                    'Complaint Details',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _complaint!['details'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Submitted date
                                  Text(
                                    'Complaint submitted on: ${(_complaint!['submitted_date'] ?? '').toString().split('.').first}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Uploaded Files Section
                            const Text(
                              'Uploaded Files',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2A4A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // PDF file icon
                                if ((_complaint!['attachment_path'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.picture_as_pdf_rounded,
                                            color: Colors.red.shade700,
                                            size: 28),
                                        Text('PDF',
                                            style: TextStyle(
                                                fontSize: 8,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                // Add file button
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade300,
                                        style: BorderStyle.solid),
                                  ),
                                  child: Icon(Icons.add_rounded,
                                      color: Colors.grey.shade500, size: 28),
                                ),
                              ],
                            ),

                            // Delete button
                            if ((_complaint!['attachment_path'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Icon(Icons.delete_rounded,
                                  color: Colors.red.shade600, size: 22),
                            ],

                            const SizedBox(height: 24),

                            // Comments Section
                            const Text(
                              'Comments',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B2A4A),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Chat bubbles
                            ..._comments.map((c) {
                              final isComplainant =
                                  c['sender_type'] == 'Complainant';
                              return _ChatBubble(
                                senderName: isComplainant
                                    ? 'Complainant'
                                    : 'Service Rep',
                                message: c['comment_text'] ?? '',
                                date: (c['comment_date'] ?? '')
                                    .toString()
                                    .split('.')
                                    .first,
                                isComplainant: isComplainant,
                              );
                            }),

                            const SizedBox(height: 16),

                            // Return to Complaints button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00897B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Return to Complaints',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Comment Input
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF1A5C2A), width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                                onSubmitted: (_) => _sendComment(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: const Color(0xFF1A5C2A),
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
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded,
                                          color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        bottom: 12,
        left: isComplainant ? 0 : 40,
        right: isComplainant ? 40 : 0,
      ),
      child: Column(
        crossAxisAlignment:
            isComplainant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Sender + Date row
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: isComplainant
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isComplainant
                        ? const Color(0xFF1B2A4A)
                        : const Color(0xFF00897B),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isComplainant
                  ? Colors.white
                  : const Color(0xFF00897B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isComplainant ? 4 : 16),
                topRight: Radius.circular(isComplainant ? 16 : 4),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              border: isComplainant
                  ? Border.all(color: Colors.grey.shade200)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isComplainant ? const Color(0xFF1B2A4A) : Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

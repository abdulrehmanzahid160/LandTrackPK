class Dispute {
  final int disputeId;
  final String plotNumber;
  final String filedBy;
  final String description;
  final String status;
  final String filedDate;

  Dispute({
    required this.disputeId,
    required this.plotNumber,
    required this.filedBy,
    required this.description,
    required this.status,
    required this.filedDate,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      disputeId: json['dispute_id'] ?? 0,
      plotNumber: json['plot_number'] ?? '',
      filedBy: json['filed_by'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      filedDate: json['filed_date'] ?? '',
    );
  }
}

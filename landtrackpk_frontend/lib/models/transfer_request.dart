class TransferRequest {
  final int transferId;
  final String plotNumber;
  final String fromOwner;
  final String toOwner;
  final String reason;
  final String requestDate;

  TransferRequest({
    required this.transferId,
    required this.plotNumber,
    required this.fromOwner,
    required this.toOwner,
    required this.reason,
    required this.requestDate,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      transferId: json['transfer_id'] ?? 0,
      plotNumber: json['plot_number'] ?? '',
      fromOwner: json['from_owner'] ?? '',
      toOwner: json['to_owner'] ?? '',
      reason: json['reason'] ?? '',
      requestDate: json['request_date'] ?? '',
    );
  }
}

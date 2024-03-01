class PaymentResult {
  final String status;
  final String? errorMessage;

  PaymentResult({required this.status, this.errorMessage});

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      status: json['status'],
      errorMessage: json['error'] != null ? json['error']['message'] : null,
    );
  }
}

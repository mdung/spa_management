class Transaction {
  final int bookingId;
  final double amount;
  final int paymentId;
  final String status;

  Transaction({
    required this.bookingId,
    required this.amount,
    required this.paymentId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'amount': amount,
      'payment_id': paymentId,
      'status': status,
    };
  }
}

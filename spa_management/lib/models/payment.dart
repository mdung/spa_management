class Payment {
  final int bookingId;
  final double amount;
  final String date;
  final String paymentType;

  Payment({
    required this.bookingId,
    required this.amount,
    required this.date,
    required this.paymentType, required String paymentMethodId, required int id, required String status, required int transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'amount': amount,
      'date': date,
      'payment_type': paymentType,
    };
  }
}

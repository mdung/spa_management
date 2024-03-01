class StaffPerformance {
  final int id;
  final int staffId;
  final String metricName;
  final int metricValue;
  final String createdAt;
  final String updatedAt;

  StaffPerformance({
    required this.id,
    required this.staffId,
    required this.metricName,
    required this.metricValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffPerformance.fromJson(Map<String, dynamic> json) {
    return StaffPerformance(
      id: json['id'],
      staffId: json['staff_id'],
      metricName: json['metric_name'],
      metricValue: json['metric_value'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'metric_name': metricName,
      'metric_value': metricValue,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

import 'package:intl/intl.dart';

class RewardHistory {
  final int id;
  final int userId;
  final String rewardName;
  final int pointsRedeemed;
  final String redeemedDate;

  RewardHistory({
    required this.id,
    required this.userId,
    required this.rewardName,
    required this.pointsRedeemed,
    required this.redeemedDate,
  });

  static RewardHistory fromJson(json) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    final redeemedDate = DateTime.parse(json['date_redeemed']);
    final formattedRedeemedDate = dateFormat.format(redeemedDate);

    return RewardHistory(
      id: json['id'] ?? -1,
      userId: json['user_id'] ?? -1,
      rewardName: json['reward_category'].toString(),
      pointsRedeemed: json['points'] ?? -1,
      redeemedDate: formattedRedeemedDate,
    );
  }
}

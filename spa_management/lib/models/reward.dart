class Reward {
  final int id;
  final int userId;
  final String rewardCategory;
  final int points;

  Reward({
    required this.id,
    required this.userId,
    required this.rewardCategory,
    required this.points,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      userId: json['user_id'],
      rewardCategory: json['reward_category'],
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_category': rewardCategory,
      'points': points,
    };
  }
}

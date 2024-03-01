import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spa_management/models/reward.dart';
import 'package:spa_management/models/reward_history.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';

class RewardsHistoryScreen extends StatefulWidget {
  final int id;
  final bool isLoggedIn;

  const RewardsHistoryScreen({
    Key? key,
    required this.isLoggedIn,
    required this.id,
  }) : super(key: key);

  @override
  _RewardsHistoryScreenState createState() => _RewardsHistoryScreenState();
}

class _RewardsHistoryScreenState extends State<RewardsHistoryScreen> {
  final _apiService = ApiService();
  List<RewardHistory> _rewardHistoryList = [];
  List<Reward> _availableRewardsList = [];

  @override
  void initState() {
    super.initState();
    _fetchRewardHistory();
    _fetchAvailableRewards();
  }

  Future<void> _fetchRewardHistory() async {
    await ApiAuth.checkTokenAndNavigate(context);
    List<dynamic> rewardHistoryList =
    await _apiService.fetchRewardHistory(widget.id);
    setState(() {
      _rewardHistoryList = rewardHistoryList.cast<RewardHistory>();
    });
  }

  Future<void> _fetchAvailableRewards() async {
    List<Reward> availableRewardsList =
    await _apiService.fetchAvailableRewards(widget.id);
    setState(() {
      _availableRewardsList = availableRewardsList;
    });
  }

  Future<void> _redeemReward(Reward reward) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    bool result =
    await _apiService.redeemReward(reward.id, widget.id, formattedDate);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward redeemed successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchRewardHistory();
      _fetchAvailableRewards();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to redeem reward'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards History'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            'Reward History',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _rewardHistoryList.length,
              itemBuilder: (BuildContext context, int index) {
                RewardHistory rewardHistory = _rewardHistoryList[index];
                return ListTile(
                  title: Text(rewardHistory.rewardName),
                  subtitle: Text(rewardHistory.redeemedDate.toString()),
                  trailing: Text(rewardHistory.pointsRedeemed.toString()),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Available Rewards',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _availableRewardsList.length,
              itemBuilder: (BuildContext context, int index) {
                Reward reward = _availableRewardsList[index];
                return ListTile(
                  title: Text(reward.rewardCategory),
                  subtitle: Text('${reward.points} points'),
                  trailing: ElevatedButton(
                    child: Text('Redeem'),
                    onPressed: () => _redeemReward(reward),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

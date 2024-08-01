import 'package:flutter/material.dart';
import 'package:spa_management/models/reward.dart';
import 'package:spa_management/services/api_service.dart';

import '../services/api_auth.dart';
import '../widgets/menu_block.dart';

class RewardsScreen extends StatefulWidget {
  final String? helloMessage;
  final bool isLoggedIn;
  final int id;
  const RewardsScreen({Key? key, this.helloMessage, required this.isLoggedIn, required this.id}) : super(key: key);


  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String? _helloMessage;
  bool _loggedIn = false;
  final _apiService = ApiService();

  List<Reward> _rewards = [];

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    await ApiAuth.checkTokenAndNavigate(context);
    try {
      final rewards = await _apiService.getRewards();
      setState(() {
        _rewards = rewards;
      });
    } catch (e) {
      print('Failed to load rewards: $e');
      throw Exception('Failed to load rewards: $e');
    }
  }

  Future<void> _showRedeemDialog(BuildContext context, Reward reward) async {
    final user_id = widget.id;
    final date = DateTime.now().toUtc().toString();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Redeem Reward'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to redeem this reward?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Redeem'),
              onPressed: () async {
                // call API to redeem reward
                await _apiService.redeemReward(reward.id, user_id, date);
                // show confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reward redeemed successfully.'),
                    duration: Duration(seconds: 3),
                  ),
                );
                // refresh the rewards list
                await _loadRewards();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards'),
      ),

      body: _rewards.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _rewards.length,
        itemBuilder: (BuildContext context, int index) {
          final reward = _rewards[index];
          return ListTile(
            title: Text(reward.rewardCategory),
            subtitle: Text('${reward.points} points'),
            trailing: ElevatedButton(
              onPressed: () {
                _showRedeemDialog(context, reward);
              },
              child: Text('Redeem'),
            ),
          );
        },
      ),
    );
  }
}

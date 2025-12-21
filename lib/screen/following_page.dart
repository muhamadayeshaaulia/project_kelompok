import 'package:flutter/material.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, dynamic>> users = [
    {
      "name": "name",
      "username": "@username",
      "isFollowing": false,
    },
    {
      "name": "name",
      "username": "@username",
      "isFollowing": true,
    },
    {
      "name": "name",
      "username": "@username",
      "isFollowing": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Following"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(user["name"]),
            subtitle: Text(user["username"]),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    user["isFollowing"] ? Colors.grey[300] : Colors.purple,
                foregroundColor:
                    user["isFollowing"] ? Colors.black : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  user["isFollowing"] = !user["isFollowing"];
                });
              },
              child: Text(
                user["isFollowing"] ? "Following" : "Follow",
              ),
            ),
          );
        },
      ),
    );
  }
}

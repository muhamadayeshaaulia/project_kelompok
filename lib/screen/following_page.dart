import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';

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
      "isLiked": false,
    },
    {
      "name": "name",
      "username": "@username",
      "isFollowing": true,
      "isLiked": true,
    },
    {
      "name": "name",
      "username": "@username",
      "isFollowing": false,
      "isLiked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Following"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user["name"]),
            subtitle: Text(user["username"]),

            /// 👉 LIKE + FOLLOW BUTTON
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ❤️ Like Button
                IconButton(
                  icon: Icon(
                    user["isLiked"] ? Icons.favorite : Icons.favorite_border,
                    color: user["isLiked"] ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      user["isLiked"] = !user["isLiked"];
                    });
                  },
                ),

                /// ➕ Follow Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user["isFollowing"]
                        ? Colors.grey[300]
                        : Colors.purple,
                    foregroundColor: user["isFollowing"]
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      user["isFollowing"] = !user["isFollowing"];
                    });
                  },
                  child: Text(user["isFollowing"] ? "Following" : "Follow"),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 1),
    );
  }
}

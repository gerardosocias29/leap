import 'package:flutter/material.dart';
import 'package:leap/_screens/achievements_screen.dart';
import 'package:leap/_screens/leaderboard_screen.dart';
import 'package:leap/_screens/user_list_screen.dart';
import 'package:leap/providers/storage.dart';
import 'package:leap/reusable_widgets/reusable_widget.dart';

import '_screens/createprofile_screen.dart';
import '_screens/grammar_list_screen.dart';
import '_screens/signin_screen.dart';
import 'auth_service.dart';

class NavBar extends StatefulWidget {
  final userDetails;
  const NavBar({Key? key, required this.userDetails}) : super(key: key);
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final userStorage = StorageProvider().userStorage();

  @override
  Widget build(BuildContext context) {
    var loadingContext = context;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("${widget.userDetails['first_name']} ${widget.userDetails['last_name']}", style: const TextStyle(color: Colors.white),),
            accountEmail: Text("${widget.userDetails['email']}", style: const TextStyle(color: Colors.white)),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://www.gravatar.com/avatar/0?s=200&d=mp',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('Profile'),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CreateProfileScreen(userDetails: widget.userDetails,)), (route) => true ),
          ),
          ListTile(
            leading: const Icon(Icons.star_border_outlined),
            title: const Text('Achievements'),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AchievementScreen()), (route) => true ),
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard_outlined),
            title: const Text('Leaderboards'),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LeaderboardScreen()), (route) => true ),
          ),
          if(widget.userDetails['role_id'] == 0) ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Users'),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const UserListScreen()), (route) => true ),
          ),
          // const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => null,
          ),
          // const Divider(),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => {
              progressDialogue(loadingContext),
              AuthService().signOut().then((value) {
                Navigator.pop(loadingContext);
                StorageProvider().storageRemoveItem(userStorage, 'user_id');
                StorageProvider().storageRemoveItem(userStorage, 'user_details');
                print('Sign out');
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignInScreen()), (route) => false );
              })
            },
          ),
        ],
      ),
    );
  }
}
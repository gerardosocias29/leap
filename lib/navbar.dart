import 'package:flutter/material.dart';
import 'package:leap/providers/storage.dart';
import 'package:leap/reusable_widgets/reusable_widget.dart';

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
            leading: const Icon(Icons.star_border_outlined),
            title: const Text('Achievements'),
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Friends'),
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => null,
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Request'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => null,
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Policies'),
            onTap: () => null,
          ),
          const Divider(),
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
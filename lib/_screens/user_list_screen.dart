import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import '../providers/storage.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late final userDetails;
  late final userLists;
  late var _isloading = false;
  final userStorage = StorageProvider().userStorage();
  final commonDataStorage = StorageProvider().commonDataStorage();


  Future _initRetrieval() async {
    setState(() {
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });
  }

  getUserLists() async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/users/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );

    setState(() {
      StorageProvider().storageRemoveItem(commonDataStorage, 'user_lists');
      StorageProvider().storageAddItem(commonDataStorage, 'user_lists', response.body);
      userLists = jsonDecode(StorageProvider().storageGetItem(commonDataStorage, 'user_lists'));
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isloading = true;
    });
    getUserLists();
    _initRetrieval();

  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        'Users List',
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
    ),
    body: _isloading ?
      const Center(
        child: CircularProgressIndicator(),
      )
      :
      Center(
        child: ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: userLists.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (BuildContext context, index) {
            // final items = userLists);
            final item = userLists[index];
            print(item);
            return ListTile(
              title: Text("${item['first_name']} ${item['last_name']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outlined,
                      size: 20.0,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      //   _onDeleteItemPressed(index);
                    },
                  ),
                ],
              ),
              onTap: () {

              }
            );
          }
        ),
      )
  );
}

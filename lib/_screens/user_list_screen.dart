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
  late var filteredUserLists = [];
  late var _isloading = false;
  final userStorage = StorageProvider().userStorage();
  final commonDataStorage = StorageProvider().commonDataStorage();

  Icon customIcon = const Icon(Icons.search);
  late Widget customSearchBar = Text('Users List', style: TextStyle(color: Theme.of(context).primaryColor));
  bool isSearch = true;

  Future _initRetrieval() async {
    setState(() {
      userDetails = jsonDecode(StorageProvider().storageGetItem(userStorage, 'user_details'));
    });
  }

  getUserLists() async {
    var backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.186:8081';
    final uri = Uri.parse("$backendUrl/api/scored_users_list/all");
    final headers = {'content-type': 'application/json'};
    Response response = await get(
        uri,
        headers: headers
    );

    setState(() {
      userLists = jsonDecode(response.body);
      filteredUserLists = userLists;
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
      title: customSearchBar,
      elevation: 0,
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
      automaticallyImplyLeading: isSearch,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (customIcon.icon == Icons.search) {
                // Perform set of instructions.
                isSearch = false;
                customIcon = const Icon(Icons.cancel);
                customSearchBar = ListTile(
                  leading: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  title: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search User',
                      hintStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (text) {
                      print('First text field: $text');
                      setState(() {
                        filteredUserLists = userLists.where((item) {
                          return (item['first_name'].toString().toLowerCase().contains(text.toLowerCase()) || item['last_name'].toString().toLowerCase().contains(text.toLowerCase()));
                        }).toList();
                      });

                    },
                  ),
                );
              } else {
                isSearch = true;
                customIcon = const Icon(Icons.search);
                customSearchBar = Text('Users List', style: TextStyle(color: Theme.of(context).primaryColor));
              }
            });
          },
          icon: customIcon,
        )
      ],

    ),
    body: _isloading ?
      Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5, 0.7, 1],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )
      :
      Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.5, 0.7, 1],
            colors: [
              Color(0xffffffff),
              Color(0xfffafdff),
              Color(0xffE7FFFF),
              Color(0xffE7FFFF),
            ],
          ),
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          // Let the ListView know how many items it needs to build.
          itemCount: filteredUserLists.length,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (BuildContext context, index) {
            // final items = userLists);
            final item = filteredUserLists[index];
            print(item);
            return ListTile(
              title: Text("${item['first_name']} ${item['last_name']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(item['score'])
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

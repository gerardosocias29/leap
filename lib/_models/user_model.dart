import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String address;
  final String birthday;
  final String course;
  final int deleted_at;
  final String email;
  final String first_name;
  final String gender;
  final String last_name;
  final String phone;
  final int role_id;
  final int school_id;
  final String username;
  final String year;
  final String photoURL;

  User({
    required this.id,
    required this.address,
    required this.birthday,
    required this.course,
    required this.deleted_at,
    required this.email,
    required this.first_name,
    required this.gender,
    required this.last_name,
    required this.phone,
    required this.role_id,
    required this.school_id,
    required this.username,
    required this.year,
    required this.photoURL,
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'address' : address,
      'birthday' : birthday,
      'course' : course,
      'deleted_at' : deleted_at,
      'email' : email,
      'first_name' : first_name,
      'gender' : gender,
      'last_name' : last_name,
      'phone' : phone,
      'role_id' : role_id,
      'school_id' : school_id,
      'username' : username,
      'year' : year,
      'photoURL' : photoURL
    };
  }

  @override
  String toString() {
    return "{'id' : ${id}, 'email' : ${email}, 'first_name' : ${first_name}, 'gender' : ${gender}, 'school_id' : ${school_id}, 'username' : ${username}, 'year' : ${year} }";
  }

  User.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> userMap)
    : id = userMap.id,
      address = userMap.data()!["address"],
      birthday = userMap.data()!["birthday"],
      course = userMap.data()!["course"],
      deleted_at = userMap.data()!["deleted_at"],
      email = userMap.data()!["email"],
      first_name = userMap.data()!["first_name"],
      gender = userMap.data()!["gender"],
      last_name = userMap.data()!["last_name"],
      phone = userMap.data()!["phone"],
      role_id = userMap.data()!["role_id"],
      school_id = userMap.data()!["school_id"],
      username = userMap.data()!["username"],
      year = userMap.data()!["year"],
      photoURL = userMap.data()!["photoURL"];
}

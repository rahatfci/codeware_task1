import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> createUser(String name, String job, BuildContext context) async {
  dynamic postBody = jsonEncode({"name": name, "send_code_by": job});

  final res =
      await http.post(Uri.parse("https://reqres.in/api/users"), body: postBody);
  return res.statusCode;
}

Future<int> updateUser(
    String name, String job, int id, BuildContext context) async {
  dynamic postBody = jsonEncode({"name": name, "send_code_by": job});

  final res = await http.put(Uri.parse("https://reqres.in/api/users/$id"),
      body: postBody);

  return res.statusCode;
}

Future<int> deleteUser(int id, BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) =>
        const AlertDialog(title: Center(child: CircularProgressIndicator())),
  );
  final res = await http.delete(Uri.parse("https://reqres.in/api/users/$id"));

  return res.statusCode;
}

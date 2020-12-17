import 'dart:async';
import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<Photo> _postList = new List<Photo>();

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response = await client.get(
      'https://api.thedogapi.com/v1/breeds?api_key=0874c65c-2093-4bac-b843-9035fea6dca0');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    List<dynamic> values = new List<dynamic>();
    values = json.decode(response.body);
    if (values.length > 0) {
      for (int i = 0; i < values.length; i++) {
        if (values[i] != null) {
          Map<String, dynamic> map = values[i];
          _postList.add(Photo.fromJson(map));
          suggestions.add(Photo.fromJson(map).albumId);
        }
      }
    }
    return _postList;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Photo {
  final String albumId;
  final int id;

  Photo({
    this.albumId,
    this.id,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['name'] as String,
      id: json['id'] as int,
    );
  }
}

class HomeScreenT1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

List<String> suggestions = ["Raushan"];

class _MyHomePageState extends State<HomeScreenT1> {
  List<String> added = [];
  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  SimpleAutoCompleteTextField textField;
  bool showWhichErrorText = false;

  @override
  void initState() {
    super.initState();
  }

  _MyHomePageState() {
    textField = SimpleAutoCompleteTextField(
      key: key,
      controller: TextEditingController(text: "Please enter text here"),
      suggestions: suggestions,
      textChanged: (text) => currentText = text,
      clearOnSubmit: true,
      textSubmitted: (text) => setState(() {
        if (text != "") {
          added.add(text);
        }
      }),
    );
  }

  void getdara(List<Photo> photos) {
    for (int i = 0; i < photos.length; i++) {}
  }

  @override
  Widget build(BuildContext context) {
    Column body = new Column(children: [
      new Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50),
        child: ListTile(
          title: textField,
        ),
      )
    ]);

    body.children.addAll(added.map((item) {
      return new ListTile(title: new Text(item));
    }));

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? body
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
